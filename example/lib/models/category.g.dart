// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $CategoryLocalAdapter on LocalAdapter<Category> {
  static final Map<String, RelationshipMeta> _kCategoryRelationshipMetas = {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kCategoryRelationshipMetas;

  @override
  Category deserialize(map) {
    map = transformDeserialize(map);
    return Category.fromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = model.toJson();
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _categoriesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $CategoryHiveLocalAdapter = HiveLocalAdapter<Category>
    with $CategoryLocalAdapter;

class $CategoryRemoteAdapter = RemoteAdapter<Category>
    with AppwriteAdapter<Category>;

final internalCategoriesRemoteAdapterProvider =
    Provider<RemoteAdapter<Category>>((ref) => $CategoryRemoteAdapter(
        $CategoryHiveLocalAdapter(ref), InternalHolder(_categoriesFinders)));

final categoriesRepositoryProvider =
    Provider<Repository<Category>>((ref) => Repository<Category>(ref));

extension CategoryDataRepositoryX on Repository<Category> {
  AppwriteAdapter<Category> get appwriteAdapter =>
      remoteAdapter as AppwriteAdapter<Category>;
}

extension CategoryRelationshipGraphNodeX on RelationshipGraphNode<Category> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: $(json, 'id') as String?,
      name: json['name'] as String,
      createdAt: $(json, 'createdAt') == null
          ? null
          : DateTime.parse($(json, 'createdAt') as String),
      updatedAt: $(json, 'updatedAt') == null
          ? null
          : DateTime.parse($(json, 'updatedAt') as String),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
