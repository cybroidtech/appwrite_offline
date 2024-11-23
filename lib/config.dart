import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

/// Configuration class for AppwriteAdapter
class AppwriteOffline {
  /// Initializes the AppwriteAdapter configuration and sets up Appwrite services
  ///
  /// Parameters:
  /// - [projectId]: Your Appwrite project ID
  /// - [databaseId]: Your Appwrite database ID
  /// - [endpoint]: Appwrite API endpoint (defaults to 'https://cloud.appwrite.io/v1')
  /// - [selfSigned]: Whether to allow self-signed certificates (defaults to false)
  /// - [jwt]: Optional JWT token for authenticated requests
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   AppwriteOffline.initialize(
  ///     projectId: 'your_project_id',
  ///     databaseId: 'your_database_id',
  ///     endpoint: 'https://your-appwrite-instance.com/v1',
  ///     jwt: 'your-jwt-token', // Optional JWT for authenticated requests
  ///   );
  /// }
  /// ```
  static void initialize({
    required String projectId,
    required String databaseId,
    String endpoint = 'https://cloud.appwrite.io/v1',
    bool selfSigned = false,
    String? jwt,
  }) {
    // Create Appwrite client
    final client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId)
      ..setSelfSigned(status: selfSigned);

    // Set JWT if provided
    if (jwt != null) {
      client.setJWT(jwt);
    }

    // Register Appwrite client
    locator.registerSingleton<Client>(client);

    // Register Appwrite services
    locator.registerSingleton<Databases>(
      Databases(client),
    );

    locator.registerSingleton<Realtime>(
      Realtime(client),
    );

    // Register configuration
    locator.registerSingleton<AppwriteOffline>(
      AppwriteOffline._(
        projectId: projectId,
        databaseId: databaseId,
        endpoint: endpoint,
      ),
    );
  }

  /// Updates the JWT token for the current client
  /// Useful when you need to update authentication after initialization
  static void updateJWT(String jwt) {
    client.setJWT(jwt);
  }

  final String projectId;
  final String databaseId;
  final String endpoint;

  AppwriteOffline._({
    required this.projectId,
    required this.databaseId,
    required this.endpoint,
  });

  /// Get the current configuration
  static AppwriteOffline get instance => locator<AppwriteOffline>();

  /// Get the registered Appwrite client
  static Client get client => locator<Client>();

  /// Get the registered Databases service
  static Databases get databases => locator<Databases>();

  /// Get the registered Realtime service
  static Realtime get realtime => locator<Realtime>();

  /// Disposes all registered services
  /// Useful when you need to reinitialize the configuration
  static void dispose() {
    if (locator.isRegistered<Client>()) {
      locator.unregister<Client>();
    }
    if (locator.isRegistered<Databases>()) {
      locator.unregister<Databases>();
    }
    if (locator.isRegistered<Realtime>()) {
      locator.unregister<Realtime>();
    }
    if (locator.isRegistered<AppwriteOffline>()) {
      locator.unregister<AppwriteOffline>();
    }
  }

  /// Checks if all required services are properly initialized
  static bool get isInitialized {
    try {
      return locator.isRegistered<Client>() &&
          locator.isRegistered<Databases>() &&
          locator.isRegistered<Realtime>() &&
          locator.isRegistered<AppwriteOffline>();
    } catch (_) {
      return false;
    }
  }
}
