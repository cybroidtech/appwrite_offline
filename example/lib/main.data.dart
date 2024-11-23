

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering, top_level_function_literal_block, depend_on_referenced_packages

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appwrite_offline_example/models/category.dart';
import 'package:appwrite_offline_example/models/product.dart';

// ignore: prefer_function_declarations_over_variables
ConfigureRepositoryLocalStorage configureRepositoryLocalStorage = ({FutureFn<String>? baseDirFn, List<int>? encryptionKey, LocalStorageClearStrategy? clear}) {
  if (!kIsWeb) {
    baseDirFn ??= () => getApplicationDocumentsDirectory().then((dir) => dir.path);
  } else {
    baseDirFn ??= () => '';
  }
  
  return hiveLocalStorageProvider.overrideWith(
    (ref) => HiveLocalStorage(
      hive: ref.read(hiveProvider),
      baseDirFn: baseDirFn,
      encryptionKey: encryptionKey,
      clear: clear,
    ),
  );
};

final repositoryProviders = <String, Provider<Repository<DataModelMixin>>>{
  'categories': categoriesRepositoryProvider,
'products': productsRepositoryProvider
};

final repositoryInitializerProvider =
  FutureProvider<RepositoryInitializer>((ref) async {
    DataHelpers.setInternalType<Category>('categories');
    DataHelpers.setInternalType<Product>('products');
    final adapters = <String, RemoteAdapter>{'categories': ref.watch(internalCategoriesRemoteAdapterProvider), 'products': ref.watch(internalProductsRemoteAdapterProvider)};
    final remotes = <String, bool>{'categories': true, 'products': true};

    await ref.watch(graphNotifierProvider).initialize();

    // initialize and register
    for (final type in repositoryProviders.keys) {
      final repository = ref.read(repositoryProviders[type]!);
      repository.dispose();
      await repository.initialize(
        remote: remotes[type],
        adapters: adapters,
      );
      internalRepositories[type] = repository;
    }

    return RepositoryInitializer();
});
extension RepositoryWidgetRefX on WidgetRef {
  Repository<Category> get categories => watch(categoriesRepositoryProvider)..remoteAdapter.internalWatch = watch;
  Repository<Product> get products => watch(productsRepositoryProvider)..remoteAdapter.internalWatch = watch;
}

extension RepositoryRefX on Ref {

  Repository<Category> get categories => watch(categoriesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
  Repository<Product> get products => watch(productsRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
}