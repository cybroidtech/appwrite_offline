import 'package:appwrite_offline_example/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite_offline_example/main.data.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.products.watchOne(
      productId,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Builder(
        builder: (context) {
          if (productState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!productState.hasModel) {
            return const Center(
              child: Text('Product not found'),
            );
          }

          final product = productState.model;
          final category = product?.category?.value;

          return StreamBuilder(
            stream: ref.products.appwriteAdapter.subscribe(id: productId),
            builder: (context, snapshot) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    product?.name ?? "",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  if (category != null) ...[
                    Text(
                      'Category: ${category.name}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    '\$${product?.price}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product?.description ?? "",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.hasData) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Real-time update received: ${snapshot.data?.events.first}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (productState.hasModel) {
            final product = productState.model;
            await Product(
              name: '${product!.name} (Updated)',
              price: product.price + 10,
              description: '${product.description}\nUpdated!',
              category: product.category,
            ).withKeyOf(product).save();
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
