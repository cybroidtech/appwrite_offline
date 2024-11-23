import 'dart:convert';

import 'package:appwrite_offline_example/main.data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'product_details_screen.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.products.watchAll(
      syncLocal: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Builder(
        builder: (context) {
          if (productsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (productsState.hasException) {
          //   return Center(
          //     child: Text('Error: ${productsState.exception}'),
          //   );
          // }

          final products = productsState.model;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(
                        productId: product.id!,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Product(
            name: 'New Product',
            price: 99.99,
            description: 'A new product',
          ).save(
            params: {
              'permissions': jsonEncode([
                {
                  'action': 'read',
                  'role': {'type': 'any'}
                }
              ]),
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
