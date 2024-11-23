import 'package:appwrite_offline_example/main.data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite_offline/appwrite_offline.dart';
import 'config.dart';
import 'screens/products_screen.dart';

void main() {
  // Initialize Appwrite Offline
  AppwriteOffline.initialize(
    projectId: Config.projectId,
    databaseId: Config.databaseId,
    endpoint: Config.endpoint,
  );

  runApp(
    ProviderScope(
      overrides: [configureRepositoryLocalStorage()],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appwrite Offline Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RepositoryInitializer(
        child: ProductsScreen(),
      ),
    );
  }
}

// Add a splash screen while repositories initialize
class RepositoryInitializer extends ConsumerWidget {
  final Widget child;

  const RepositoryInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(repositoryInitializerProvider).when(
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          data: (_) => child,
        );
  }
}