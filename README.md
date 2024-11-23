# Appwrite Offline

A Flutter Data adapter for Appwrite that provides offline support, real-time updates, and seamless integration with Flutter Data's powerful features.

## Features

- 🔄 **Automatic Synchronization**: Seamlessly sync data between local storage and Appwrite
- 📱 **Offline Support**: Work with your data even when offline
- ⚡ **Real-time Updates**: Listen to changes in your Appwrite collections in real-time
- 🔍 **Advanced Querying**: Supported operators: '==', '!=', '>', '>=', '<', '<=', 'startsWith', 'endsWith', 'contains', 'search', 'between', 'in', 'isNull', 'isNotNull'.
- 🎯 **Type-safe**: Fully typed models and queries
- 🪄 **Easy Integration**: Simple setup process with minimal configuration

## Prerequisites

Before using this package, make sure you:

1. Have a working Appwrite backend setup
2. Understand and follow [Flutter Data's setup guide](https://flutterdata.dev) carefully
3. Are using Riverpod for state management

This package only handles the Appwrite integration with Flutter Data. All other Flutter Data configurations must be properly set up.

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  appwrite_offline: ^0.0.1
```

## Setup

1. Initialize Appwrite Offline in your app:

```dart
void main() {
  // Initialize Appwrite Offline
  AppwriteOffline.initialize(
    projectId: 'your_project_id',
    databaseId: 'your_database_id',
    endpoint: 'https://your-appwrite-instance.com/v1',
    jwt: 'optional-jwt-token', // If using authentication
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```
2. Create your model class:

```dart
@DataRepository([AppwriteAdapter])
@JsonSerializable()
class Product extends DataModel<Product> {
  @override
  @JsonKey(readValue: $)
  final String? id;
  final String name;
  final double price;
  final BelongsTo<Category>? category;
  final HasMany<Review>? reviews;
  @JsonKey(readValue: $)
  final DateTime? createdAt;
  @JsonKey(readValue: $)
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.category,
    this.reviews,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => 
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
```

3. Run the code generator:

```bash
dart run build_runner build -d
```

## Usage

### Basic Operations

```dart
class ProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all products with offline support
    final productsState = ref.products.watchAll(
      syncLocal: true,
    );

    if (productsState.isLoading) {
      return CircularProgressIndicator();
    }

    if (productsState.hasException) {
      return Text('Error: ${productsState.exception}');
    }

    final products = productsState.model;
    
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('\$${product.price}'),
        );
      },
    );
  }
}
```
### Creating and Updating

```dart
class ProductFormScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Create new product
        final newProduct = await Product(
          name: 'New Product',
          price: 99.99,
        ).save();

        // Update existing product
        final updatedProduct = await Product(
          name: 'Updated Product',
          price: 149.99,
        ).withKeyOf(existingProduct).save();
      },
      child: Text('Save Product'),
    );
  }
}
```

### Watching with Relationships

```dart
class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.products.watchOne(
      productId,
      syncLocal: true,
      alsoWatch: (prod) => [
        prod.category,
        prod.reviews,
      ],
    );

    if (productState.isLoading) {
      return CircularProgressIndicator();
    }

    if (productState.hasException) {
      return Text('Error: ${productState.exception}');
    }

    if (!productState.hasModel) {
      return Text('Product not found');
    }

    final product = productState.model;
    final category = product.category?.value;
    final reviews = product.reviews?.toList() ?? [];

    return Column(
      children: [
        Text(product.name),
        if (category != null)
          Text('Category: ${category.name}'),
        Text('Reviews (${reviews.length}):'),
        ...reviews.map((review) => Text(review.text)),
      ],
    );
  }
}
```
### Real-time Updates

```dart
class ProductUpdatesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<RealtimeMessage>(
      stream: ref.products.appwriteAdapter.subscribe(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final message = snapshot.data!;
          return ListTile(
            title: Text('Collection Update'),
            subtitle: Text('Event: ${message.event}'),
          );
        }
        return SizedBox();
      },
    );
  }
}
```

### Advanced Queries

```dart
class FilteredProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.products.watchAll(
      syncLocal: true,
      params: {
        'where': {
          'price': {'>=', 100},
          'name': {'contains': 'Premium'}
        },
        'order': 'price:DESC,name:ASC',
        'limit': 10,
        'offset': 0,
      },
    );

    if (productsState.isLoading) {
      return CircularProgressIndicator();
    }

    if (productsState.hasException) {
      return Text('Error: ${productsState.exception}');
    }

    final products = productsState.model;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('\$${product.price}'),
        );
      },
    );
  }
}
```
### Working with Permissions

Appwrite permissions can be set when creating or updating documents by passing them as params to the save method.

```dart
class ProductFormScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Create product with permissions
        final newProduct = await Product(
          name: 'New Product',
          price: 99.99,
        ).save(
          params: {
            'permissions': jsonEncode([
              {
                'action': 'read',
                'role': {
                  'type': 'any',
                }
              },
              {
                'action': 'write',
                'role': {
                  'type': 'user',
                  'value': 'user_id',
                }
              },
              {
                'action': 'update',
                'role': {
                  'type': 'team',
                  'value': 'team_id',
                }
              },
              {
                'action': 'delete',
                'role': {
                  'type': 'team:*', // All teams
                }
              },
            ]),
          },
        );
      },
      child: Text('Save Product'),
    );
  }
}
```

Available permission configurations:
- Actions: 'read', 'write', 'create', 'update', 'delete'
- Role Types:
  - 'any': Any user
  - 'users': All authenticated users
  - 'user': Specific user (requires value)
  - 'team': Specific team (requires value)
  - 'team:*': All teams

### Working with HasMany Relationships

```dart
class ProductReviewsScreen extends ConsumerWidget {
  final String productId;

  const ProductReviewsScreen({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.products.watchOne(
      productId,
      syncLocal: true,
      alsoWatch: (prod) => [prod.reviews],
    );

    if (productState.isLoading) {
      return CircularProgressIndicator();
    }

    if (productState.hasException) {
      return Text('Error: ${productState.exception}');
    }

    if (!productState.hasModel) {
      return Text('Product not found');
    }

    final product = productState.model;
    // Always use toList() for HasMany relationships
    final reviews = product.reviews?.toList() ?? [];

    return Column(
      children: [
        Text('${product.name} - Reviews'),
        if (reviews.isEmpty)
          Text('No reviews yet'),
        ...reviews.map((review) => ReviewCard(review)),
      ],
    );
  }
}
```
## Important Notes

### DataState Handling
Always handle all DataState conditions in your widgets:
- `isLoading`: Initial loading state
- `hasException`: Error state with `exception` details
- `hasModel`: Whether the model is available
- `model`: The actual data

### Relationship Best Practices
1. Always use `toList()` when accessing HasMany relationships:
   ```dart
   // Correct
   final reviews = product.reviews?.toList() ?? [];
   
   // Incorrect
   final reviews = product.reviews?.value; // Don't use .value for HasMany
   ```

2. Use `alsoWatch` for efficient relationship loading:
   ```dart
   final productState = ref.products.watchOne(
     productId,
     syncLocal: true,
     alsoWatch: (prod) => [
       prod.category,  // BelongsTo relationship
       prod.reviews,   // HasMany relationship
     ],
   );
   ```

### Offline Synchronization
1. Always use `syncLocal: true` when watching data to enable offline support:
   ```dart
   ref.products.watchAll(syncLocal: true);
   ref.products.watchOne(id, syncLocal: true);
   ```

2. Data will be automatically synchronized when the connection is restored

## Convention Guidelines

1. Collection IDs should be the plural form of the model name (e.g., "products" for Product model)
2. Model names should be in PascalCase (e.g., ProductVariant)
3. All required Appwrite collection attributes should be defined in the model class
4. Use `@JsonKey(readValue: $)` for Appwrite metadata fields (id, createdAt, updatedAt)
5. Follow Flutter Data's relationship conventions for BelongsTo and HasMany

## Common Issues and Solutions

1. **Collection Not Found**: Ensure your Appwrite collection ID matches the plural form of your model name
2. **Permission Denied**: Check if permissions are properly set in the save method params
3. **Relationship Loading Issues**: Make sure to use `alsoWatch` and `toList()` appropriately
4. **Offline Data Not Syncing**: Verify `syncLocal: true` is set when watching data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Here's how you can contribute:
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Additional Resources

- [Flutter Data Documentation](https://flutterdata.dev)
- [Appwrite Documentation](https://appwrite.io/docs)
- [Example Project](https://github.com/cybroidtech/appwrite_offline/tree/main/example)
- [GitHub Repository](https://github.com/cybroidtech/appwrite_offline)

## Support

If you find this package helpful, please give it a ⭐️ on [GitHub](https://github.com/cybroidtech/appwrite_offline)!

For bugs or feature requests, please [create an issue](https://github.com/cybroidtech/appwrite_offline/issues).

## Acknowledgments

- Thanks to the Flutter Data team for their excellent work
- Thanks to the Appwrite team for their fantastic backend solution
- Thanks to all contributors who help improve this package