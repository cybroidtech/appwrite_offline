// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $ProductLocalAdapter on LocalAdapter<Product> {
  static final Map<String, RelationshipMeta> _kProductRelationshipMetas = {
    'category': RelationshipMeta<Category>(
      name: 'category',
      type: 'categories',
      kind: 'BelongsTo',
      instance: (_) => (_ as Product).category,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kProductRelationshipMetas;

  @override
  Product deserialize(map) {
    map = transformDeserialize(map);
    return Product.fromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = model.toJson();
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _productsFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $ProductHiveLocalAdapter = HiveLocalAdapter<Product>
    with $ProductLocalAdapter;

class $ProductRemoteAdapter = RemoteAdapter<Product>
    with AppwriteAdapter<Product>;

final internalProductsRemoteAdapterProvider = Provider<RemoteAdapter<Product>>(
    (ref) => $ProductRemoteAdapter(
        $ProductHiveLocalAdapter(ref), InternalHolder(_productsFinders)));

final productsRepositoryProvider =
    Provider<Repository<Product>>((ref) => Repository<Product>(ref));

extension ProductDataRepositoryX on Repository<Product> {
  AppwriteAdapter<Product> get appwriteAdapter =>
      remoteAdapter as AppwriteAdapter<Product>;
}

extension ProductRelationshipGraphNodeX on RelationshipGraphNode<Product> {
  RelationshipGraphNode<Category> get category {
    final meta = $ProductLocalAdapter._kProductRelationshipMetas['category']
        as RelationshipMeta<Category>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: $(json, 'id') as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] == null
          ? null
          : BelongsTo<Category>.fromJson(
              json['category'] as Map<String, dynamic>),
      createdAt: $(json, 'createdAt') == null
          ? null
          : DateTime.parse($(json, 'createdAt') as String),
      updatedAt: $(json, 'updatedAt') == null
          ? null
          : DateTime.parse($(json, 'updatedAt') as String),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'category': instance.category,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
