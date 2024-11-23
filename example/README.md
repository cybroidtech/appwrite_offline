# Appwrite Offline Example

This example demonstrates how to use the appwrite_offline package to add offline support to your Flutter app with Appwrite backend.

## Getting Started

1. Update the `config.dart` file with your Appwrite credentials:
```dart
class Config {
  static const String projectId = 'your_project_id';
  static const String databaseId = 'your_database_id';
  static const String endpoint = 'https://your-appwrite-instance.com/v1';
}
```

2. Create two collections in your Appwrite database:
   - `categories` with the following attributes:
     - name (string, required)
   - `products` with the following attributes:
     - name (string, required)
     - price (double, required)
     - description (string, required)
     - category (relationship to categories)

3. Run the build runner to generate necessary files:
```bash
dart run build_runner build -d
```

4. Run the app:
```bash
flutter run
```

## Features Demonstrated

- Offline data persistence
- Real-time updates
- CRUD operations
- Relationships (BelongsTo)
- Error handling
- Loading states
- Permissions handling

## Structure

- `lib/models/` - Data models
- `lib/screens/` - UI screens
- `config.dart` - Configuration
- `main.dart` - App initialization

## Additional Notes

This example uses Material Design 3 and demonstrates best practices for:
- State management with Riverpod
- Error handling
- Loading states
- Real-time updates
- Offline data synchronization