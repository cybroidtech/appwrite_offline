library appwrite_offline;

import 'dart:async';
import 'dart:convert';

import 'package:appwrite_offline/config.dart';
import 'package:appwrite_offline/extensions/framework.dart';
import 'package:appwrite_offline/models.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_data/flutter_data.dart';
import 'package:appwrite/appwrite.dart';

/// AppwriteAdapter is a Flutter Data adapter that provides seamless integration with Appwrite Backend.
/// It handles CRUD operations, real-time updates, and offline synchronization for Appwrite collections.
///
/// To use this adapter:
/// 1. Create a model class extending [DataModel]
/// 2. Add the [DataRepository] annotation with AppwriteAdapter
/// 3. Ensure your Appwrite collection ID matches the plural form of your model name
///
/// Example:
/// ```dart
/// @DataRepository([AppwriteAdapter])
/// class Product extends DataModel<Product> {
///   // ... model implementation
/// }
///
mixin AppwriteAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  AppwriteOffline get _instance => AppwriteOffline.instance;

  /// Appwrite Databases instance
  Databases get _databases => AppwriteOffline.databases;

  /// Appwrite Realtime instance
  Realtime get _realtime => AppwriteOffline.realtime;

  /// Base URL for the adapter (required by Flutter Data)
  @override
  String get baseUrl => _instance.endpoint;

  /// Appwrite Database ID
  String get databaseId => _instance.databaseId;

  /// Subscribes to real-time updates for this model's collection
  ///
  /// Parameters:
  /// - [id]: Optional document ID to listen to specific document changes
  /// - [event]: Optional event type to filter specific events
  ///
  /// Returns a Stream of [RealtimeMessage] containing real-time updates
  ///
  /// Example:
  /// ```dart
  /// // Listen to all changes
  /// ref.products.appwriteAdapter.subscribe();
  ///
  /// // Listen to specific document
  /// ref.products.appwriteAdapter.subscribe(id: 'doc123');
  ///
  /// // Listen to specific event
  /// ref.products.appwriteAdapter.subscribe(event: 'create');
  ///
  Stream<RealtimeMessage> subscribe({Object? id, String? event}) {
    String channel = 'databases.$databaseId.collections.$type.documents';
    if (id != null && event != null) {
      channel = '$channel.$id.$event';
    } else if (event != null) {
      channel = '$channel.*.$event';
    } else if (id != null) {
      channel = '$channel.$id';
    }
    return _realtime.subscribe([channel]).stream;
  }

  /// Converts Flutter Data filter to Appwrite query
  ///
  /// Supported operators:
  /// - == (equal)
  /// - != (not equal)
  /// - > (greater than)
  /// - >= (greater than or equal)
  /// - < (less than)
  /// - <= (less than or equal)
  /// - startsWith
  /// - endsWith
  /// - contains
  /// - search
  /// - between
  /// - in
  /// - isNull
  /// - isNotNull
  List<String> convertFilter(Filter filter) {
    final field = filter.field;
    final value = filter.value;
    final operator = filter.operator;

    switch (operator) {
      case '==':
        return [Query.equal(field, value)];
      case '!=':
        return [Query.notEqual(field, value)];
      case '>':
        return [Query.greaterThan(field, value)];
      case '>=':
        return [Query.greaterThanEqual(field, value)];
      case '<':
        return [Query.lessThan(field, value)];
      case '<=':
        return [Query.lessThanEqual(field, value)];
      case 'startsWith':
        return [Query.startsWith(field, value)];
      case 'endsWith':
        return [Query.endsWith(field, value)];
      case 'contains':
        return [Query.contains(field, value)];
      case 'search':
        return [Query.search(field, value)];
      case 'between':
        if (value is List && value.length == 2) {
          return [Query.between(field, value[0], value[1])];
        }
        throw UnsupportedError(
            'Between operator requires a list of two values');
      case 'in':
        return [
          Query.equal(field, value)
        ]; // Appwrite uses equal for 'in' queries
      case 'isNull':
        return [Query.isNull(field)];
      case 'isNotNull':
        return [Query.isNotNull(field)];
      default:
        throw UnsupportedError('Unsupported operator: $operator');
    }
  }

  /// Converts a Where clause containing multiple filters to Appwrite queries
  List<String> convertWhere(Where where) {
    final queries = <String>[];
    for (final filter in where.filters) {
      queries.addAll(convertFilter(filter));
    }
    return queries;
  }

  /// Handles all HTTP requests between Flutter Data and Appwrite
  ///
  /// This method translates Flutter Data's standard REST-like operations into
  /// corresponding Appwrite SDK calls:
  ///
  /// - GET: listDocuments/getDocument
  /// - POST: createDocument
  /// - PUT/PATCH: updateDocument
  /// - DELETE: deleteDocument
  ///
  /// The method also handles:
  /// - Query parameters conversion
  /// - Pagination
  /// - Sorting
  /// - Document metadata ($id, $createdAt, $updatedAt)
  @override
  Future<R?> sendRequest<R>(
    final Uri uri, {
    DataRequestMethod method = DataRequestMethod.GET,
    Map<String, String>? headers,
    Object? body,
    FutureOr<R?> Function(DataException, DataRequestLabel)? onError,
    FutureOr<R?> Function(DataResponse, DataRequestLabel)? onSuccess,
    bool omitDefaultParams = false,
    bool returnBytes = false,
    DataRequestLabel? label,
    bool closeClientAfterRequest = true,
  }) async {
    label ??= DataRequestLabel('custom', type: internalType);
    onSuccess ??= this.onSuccess;
    onError ??= this.onError;
    try {
      final collectionId = type;
      final documentId =
          uri.pathSegments.length > 2 ? uri.pathSegments[2] : null;

      dynamic response;
      Map? bodyData = body != null ? json.decode(body as String) : null;
      Set<String> keysToRemove = {'id', 'createdAt', 'updatedAt'};
      bodyData?.removeWhere(
          (key, value) => value == null || keysToRemove.contains(key));

      switch (method) {
        case DataRequestMethod.GET:
          if (documentId == null || documentId == 'all') {
            final queries = <String>[];
            final params = uri.queryParameters;
            if (params.containsKey('where')) {
              final where = Where.fromJson(jsonDecode(params['where']!));
              queries.addAll(convertWhere(where));
            }
            if (params.containsKey('limit')) {
              queries.add(Query.limit(int.parse(params['limit']!)));
            }
            if (params.containsKey('offset')) {
              queries.add(Query.offset(int.parse(params['offset']!)));
            }
            if (params.containsKey('order')) {
              final orderBy = params['order']!.split(',');
              for (final order in orderBy) {
                final parts = order.split(':');
                final field = parts[0];
                final direction =
                    parts.length > 1 && parts[1] == 'DESC' ? 'DESC' : 'ASC';
                queries.add(direction == 'ASC'
                    ? Query.orderAsc(field)
                    : Query.orderDesc(field));
              }
            }
            if (params.containsKey('cursorAfter')) {
              queries.add(Query.cursorAfter(params['cursorAfter']!));
            }
            if (params.containsKey('cursorBefore')) {
              queries.add(Query.cursorBefore(params['cursorBefore']!));
            }
            final docs = await _databases.listDocuments(
                databaseId: databaseId,
                collectionId: collectionId,
                queries: queries);

            response = docs.documents.map((doc) {
              doc.data.addAll({
                "id": doc.$id,
                "createdAt": doc.$createdAt,
                "updatedAt": doc.$updatedAt,
              });
              return doc.data;
            }).toList();
          } else {
            final doc = await _databases.getDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: documentId,
            );
            doc.data.addAll({
              "id": doc.$id,
              "createdAt": doc.$createdAt,
              "updatedAt": doc.$updatedAt,
            });
            response = doc.data;
          }
          break;
        case DataRequestMethod.POST:
          final permissions = _parsePermissions(uri.queryParameters);
          final newDoc = await _databases.createDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: ID.unique(),
            data: bodyData ?? {},
            permissions: permissions,
          );
          newDoc.data.addAll({
            "id": newDoc.$id,
            "createdAt": newDoc.$createdAt,
            "updatedAt": newDoc.$updatedAt,
          });
          response = newDoc.data;
          break;
        case DataRequestMethod.PUT:
        case DataRequestMethod.PATCH:
          if (documentId == null || bodyData == null) {
            throw Exception('Document ID is required for PATCH operations');
          }
          final updateData = _parsePartialUpdate(
              queryParams: uri.queryParameters, body: bodyData);
          final updatedDoc = await _databases.updateDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: updateData,
          );
          updatedDoc.data.addAll({
            "id": updatedDoc.$id,
            "createdAt": updatedDoc.$createdAt,
            "updatedAt": updatedDoc.$updatedAt,
          });
          response = updatedDoc.data;
          break;
        case DataRequestMethod.DELETE:
          if (documentId == null) {
            throw Exception('Document ID is required for DELETE operations');
          }
          await _databases.deleteDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
          );
          response = {'id': documentId};
          break;
        default:
          throw Exception('Unsupported method: $method');
      }
      final data = DataResponse(
        body: response,
        statusCode: 200,
      );
      return onSuccess(data, label);
    } on AppwriteException catch (error) {
      // AppwriteException thrown
      // Check Offline Error
      if (isOfflineError(error)) {
        // queue a new operation if:
        //  - this is a network error and we're offline
        //  - the request was not a find
        if (method != DataRequestMethod.GET) {
          OfflineOperation<T>(
            httpRequest: '${method.toShortString()} $uri',
            label: label,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            body: body?.toString(),
            headers: headers,
            onSuccess: onSuccess as OnSuccessGeneric<T>,
            onError: onError as OnErrorGeneric<T>,
            adapter: this as RemoteAdapter<T>,
          ).add();
        }

        // wrap error in an OfflineException
        final offlineException = OfflineException(error: error);

        // call error handler but do not return it
        // (this gives the user the chance to present
        // a UI element to retry fetching, for example)
        onError(offlineException, label);

        // instead return a fallback model from local storage
        switch (label.kind) {
          case 'findAll':
            return findAll(remote: false) as Future<R?>;
          case 'findOne':
          case 'save':
            return label.model as R?;
          default:
            return null;
        }
      }
      return onError(DataException(error), label);
    } catch (e) {
      // Other Exception thrown
      return onError(DataException(e), label);
    }
  }

  @override
  bool isOfflineError(Object? error) {
    final commonExceptions = [
      // timeouts via http's `connectionTimeout` are also socket exceptions
      'SocketException',
      'HttpException',
      'HandshakeException',
      'TimeoutException',
    ];

    // we check exceptions with strings to avoid importing `dart:io`
    final err = error is AppwriteException
        ? error.message ?? error.toString()
        : error.runtimeType.toString();
    return commonExceptions.any(err.contains);
  }

  /// Parses updatedFields from query parameters
  ///
  /// And Returns only a new request body with only updated fields
  Map _parsePartialUpdate(
      {required Map<String, String> queryParams, required Map body}) {
    if (!queryParams.containsKey('updatedFields')) {
      return body;
    }

    List updatedFields = json.decode(queryParams['updatedFields']!);
    Set keysToRemove =
        body.keys.where((key) => !updatedFields.contains(key)).toSet();
    body.removeWhere(
        (key, value) => value == null || keysToRemove.contains(key));
    return body;
  }

  /// Parses permission rules from query parameters
  ///
  /// Supported permission types:
  /// - any
  /// - users
  /// - user
  /// - team
  /// - team:*
  ///
  /// Supported actions:
  /// - write
  /// - create
  /// - read
  /// - update
  /// - delete
  List<String> _parsePermissions(Map<String, String> queryParams) {
    if (!queryParams.containsKey('permissions')) {
      return [];
    }

    final permissionsJson = json.decode(queryParams['permissions']!);
    final List<String> permissions = [];

    for (var perm in permissionsJson) {
      final action = perm['action'];
      final role = perm['role'];
      final type = role['type'];
      final value = role['value'];

      String permission, roleObject;

      switch (type) {
        case 'any':
          roleObject = Role.any();
          break;
        case 'users':
          roleObject = Role.users();
          break;
        case 'user':
          roleObject = Role.user(value);
          break;
        case 'team':
          roleObject = Role.team(value);
          break;
        case 'team:*':
          roleObject = Role.team('*');
          break;
        default:
          continue; // Skip invalid role types
      }

      switch (action) {
        case 'write':
          permission = Permission.write(roleObject);
          break;
        case 'create':
          permission = Permission.create(roleObject);
          break;
        case 'read':
          permission = Permission.read(roleObject);
          break;
        case 'update':
          permission = Permission.update(roleObject);
          break;
        case 'delete':
          permission = Permission.delete(roleObject);
          break;
        default:
          continue; // Skip invalid action types
      }

      permissions.add(permission);
    }

    return permissions;
  }
}
