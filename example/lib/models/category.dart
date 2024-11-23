import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:appwrite_offline/appwrite_offline.dart';

part 'category.g.dart';

@JsonSerializable()
@DataRepository([AppwriteAdapter])
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
