#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating Appwrite Offline Example Project Structure...${NC}"

# Create main directory structure
mkdir -p example/lib/models example/lib/screens

# Create pubspec.yaml
echo -e "${GREEN}Creating pubspec.yaml...${NC}"
cat > example/pubspec.yaml << 'EOF'
name: appwrite_offline_example
description: Example app for appwrite_offline package
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  appwrite_offline:
    path: ../
  flutter_data: ^1.6.0
  flutter_riverpod: ^2.4.9
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
EOF

# Create config.dart
echo -e "${GREEN}Creating config.dart...${NC}"
cat > example/lib/config.dart << 'EOF'
class Config {
  static const String projectId = 'your_project_id';
  static const String databaseId = 'your_database_id';
  static const String endpoint = 'https://cloud.appwrite.io/v1';
}
EOF

# Create models
echo -e "${GREEN}Creating models...${NC}"
cat > example/lib/models/category.dart << 'EOF'
import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:appwrite_offline/appwrite_offline.dart';

part 'category.g.dart';

@DataRepository([AppwriteAdapter])
@JsonSerializable()
class Category extends DataModel<Category> {
  @override
  @JsonKey(readValue: $)
  final String? id;
  final String name;
  @JsonKey(readValue: $)
  final DateTime? createdAt;
  @JsonKey(readValue: $)
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => 
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
EOF

cat > example/lib/models/product.dart << 'EOF'
import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:appwrite_offline/appwrite_offline.dart';
import 'category.dart';

part 'product.g.dart';

@DataRepository([AppwriteAdapter])
@JsonSerializable()
class Product extends DataModel<Product> {
  @override
  @JsonKey(readValue: $)
  final String? id;
  final String name;
  final double price;
  final String description;
  final BelongsTo<Category>? category;
  @JsonKey(readValue: $)
  final DateTime? createdAt;
  @JsonKey(readValue: $)
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => 
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
EOF

# Create screens
echo -e "${GREEN}Creating screens...${NC}"
cat > example/lib/screens/products_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'product_details_screen.dart';

class ProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.products.watchAll(
      syncLocal: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Builder(
        builder: (context) {
          if (productsState.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (productsState.hasException) {
            return Center(
              child: Text('Error: ${productsState.exception}'),
            );
          }

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
        child: Icon(Icons.add),
      ),
    );
  }
}
EOF

cat > example/lib/screens/product_details_screen.dart << 'EOF'
[Previous product_details_screen.dart content]
EOF

# Create main.dart
echo -e "${GREEN}Creating main.dart...${NC}"
cat > example/lib/main.dart << 'EOF'
[Previous main.dart content]
EOF

# Create README.md
echo -e "${GREEN}Creating README.md...${NC}"
cat > example/README.md << 'EOF'
[Previous README.md content]
EOF

# Make the script executable
chmod +x example/lib/main.dart

echo -e "${GREEN}Example project structure created successfully!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Update config.dart with your Appwrite credentials"
echo "2. Run: dart run build_runner build -d"
echo "3. Run: flutter run"
