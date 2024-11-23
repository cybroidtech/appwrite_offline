import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:appwrite_offline/appwrite_offline.dart';
import 'category.dart';

part 'product.g.dart';

@JsonSerializable()
@DataRepository([AppwriteAdapter])
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
