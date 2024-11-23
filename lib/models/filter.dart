/// A utility class that represents a filter condition for database queries.
/// 
/// This class is used to convert Flutter Data's filter syntax into Appwrite's query format.
/// It handles both simple equality filters and complex operator-based filters.
class Filter {
  /// The field name to filter on
  final String field;

  /// The value to compare against
  final dynamic value;

  /// The operator to use for comparison
  /// 
  /// Supported operators:
  /// - '==' (equality)
  /// - '!=' (inequality)
  /// - '>' (greater than)
  /// - '>=' (greater than or equal)
  /// - '<' (less than)
  /// - '<=' (less than or equal)
  /// - 'startsWith'
  /// - 'endsWith'
  /// - 'contains'
  /// - 'search'
  /// - 'between'
  /// - 'in'
  /// - 'isNull'
  /// - 'isNotNull'
  final String operator;

  /// Creates a new filter with the specified field, value, and operator
  Filter(this.field, this.value, this.operator);

  /// Creates a Filter instance from a JSON map.
  /// 
  /// Handles two formats:
  /// 1. Simple equality: `{"fieldName": value}`
  /// 2. Operator-based: `{"fieldName": {"$operator": value}}`
  /// 
  /// Example:
  /// ```dart
  /// // Simple equality
  /// Filter.fromJson({"name": "John"}); // Creates equality filter
  /// 
  /// // Operator-based
  /// Filter.fromJson({
  ///   "age": {">=": 18}
  /// }); // Creates "greater than" filter
  /// ```
  factory Filter.fromJson(Map<String, dynamic> json) {
    final entry = json.entries.first;
    if (entry.value is Map) {
      final opEntry = (entry.value as Map).entries.first;
      return Filter(entry.key, opEntry.value, opEntry.key.replaceAll(r'$', ''));
    } else {
      return Filter(entry.key, entry.value, '==');
    }
  }
}