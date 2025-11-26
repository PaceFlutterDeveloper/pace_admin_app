// lib/UI/employee/tickets/models/form_config_model.dart

import 'dart:convert';

class FormConfigModel {
  final bool status;
  final List<FormType> types;
  final List<Category> categories;
  final List<Priority> priorities;
  final List<Block> blocks;
  final List<Location> locations;

  FormConfigModel({
    required this.status,
    required this.types,
    required this.categories,
    required this.priorities,
    required this.blocks,
    required this.locations,
  });

  /// Decode from raw JSON string
  factory FormConfigModel.fromRawJson(String str) =>
      FormConfigModel.fromJson(json.decode(str) as Map<String, dynamic>);

  /// Encode to raw JSON string
  String toRawJson() => json.encode(toJson());

  factory FormConfigModel.fromJson(Map<String, dynamic> json) =>
      FormConfigModel(
        status: json['status'] as bool,
        types: (json['types'] as List<dynamic>)
            .map((e) => FormType.fromJson(e as Map<String, dynamic>))
            .toList(),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
        priorities: (json['priorities'] as List<dynamic>)
            .map((e) => Priority.fromJson(e as Map<String, dynamic>))
            .toList(),
        blocks: (json['blocks'] as List<dynamic>)
            .map((e) => Block.fromJson(e as Map<String, dynamic>))
            .toList(),
        locations: (json['locations'] as List<dynamic>)
            .map((e) => Location.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'types': types.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'priorities': priorities.map((e) => e.toJson()).toList(),
        'blocks': blocks.map((e) => e.toJson()).toList(),
        'locations': locations.map((e) => e.toJson()).toList(),
      };
}

class FormType {
  final String typeId;
  final String typeName;

  FormType({
    required this.typeId,
    required this.typeName,
  });

  factory FormType.fromJson(Map<String, dynamic> json) => FormType(
        typeId: json['type_id'] as String,
        typeName: json['type_name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'type_id': typeId,
        'type_name': typeName,
      };
}

class Category {
  final String categoryId;
  final String typeId;
  final String name;

  Category({
    required this.categoryId,
    required this.typeId,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json['category_id'] as String,
        typeId: json['type_id'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'type_id': typeId,
        'name': name,
      };
}

class Priority {
  final String priorityId;
  final String priorityName;

  Priority({
    required this.priorityId,
    required this.priorityName,
  });

  factory Priority.fromJson(Map<String, dynamic> json) => Priority(
        priorityId: json['priority_id'] as String,
        priorityName: json['priority_name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'priority_id': priorityId,
        'priority_name': priorityName,
      };
}

class Block {
  final String blockId;
  final String blockName;

  Block({
    required this.blockId,
    required this.blockName,
  });

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        blockId: json['block_id'] as String,
        blockName: json['block_name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'block_id': blockId,
        'block_name': blockName,
      };
}

class Location {
  final String locationId;
  final String blockId;
  final String locationName;

  Location({
    required this.locationId,
    required this.blockId,
    required this.locationName,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        locationId: json['location_id'] as String,
        blockId: json['block_id'] as String,
        locationName: json['location_name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'location_id': locationId,
        'block_id': blockId,
        'location_name': locationName,
      };
}
