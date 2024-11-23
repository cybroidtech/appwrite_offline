import 'package:appwrite_offline/models/filter.dart';

/// A class that represents a collection of filters to be applied in a database query.
/// 
/// This class is used to group multiple [Filter] conditions together for complex queries.
class Where {
  /// List of filters to be applied
  final List<Filter> filters;

  /// Creates a new Where clause with the specified filters
  Where(this.filters);

  /// Creates a Where instance from a JSON map.
  /// 
  /// The JSON map should contain field-value pairs or field-operator-value pairs.
  /// 
  /// Example:
  /// ```dart
  /// Where.fromJson({
  ///   "age": {">=": 18},
  ///   "status": "active",
  ///   "type": {"\$in": ["user", "admin"]}
  /// });
  /// ```
  factory Where.fromJson(Map<String, dynamic> json) {
    return Where(
        json.entries.map((e) => Filter.fromJson({e.key: e.value})).toList());
  }
}