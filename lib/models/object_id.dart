/// A utility function to safely access document metadata fields from Appwrite responses.
///
/// This function handles both normal field access and Appwrite's metadata fields
/// (prefixed with $). It's particularly useful for accessing fields like id,
/// createdAt, and updatedAt which can come in both normal and $ prefixed forms.
///
/// Parameters:
/// - [map]: The document map to access
/// - [string]: The field name to retrieve
///
/// Returns the value of the field or null if not found
///
/// Example:
/// ```dart
/// // Accessing a document's ID
/// final id = $(document, 'id'); // Will return either document['id'] or document['$id']
///
/// // Accessing creation timestamp
/// final createdAt = $(document, 'createdAt'); // Returns document['createdAt'] or document['$createdAt']
/// ```
Object? $(map, string) {
  return map[string] ?? map['\$$string'];
}
