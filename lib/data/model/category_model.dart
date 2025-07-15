import 'package:an3am/utils/api.dart';

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
}

class CategoryModel {
  final int? id;
  final String? name;
  final String? url;
  final List<CategoryModel>? children;
  final String? description;

  final int? subcategoriesCount;

  CategoryModel({
    this.id,
    this.name,
    this.url,
    this.description,
    this.children,
    this.subcategoriesCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      int subCatCount = 0;
      List<dynamic> childData = json['subcategories'] ?? [];
      List<CategoryModel> children =
          childData.map((child) => CategoryModel.fromJson(child)).toList();


      if (json['subcategories_count'].runtimeType == String) {
        subCatCount = int.parse(json['subcategories_count']);
      } else {
        subCatCount = json['subcategories_count'] ?? 0;
      }

      return CategoryModel(
          id: json['id'],
          name: json['translated_name'],
          url: json['image'],
          subcategoriesCount: subCatCount,
          children: children,
          description: json['description'] ?? "");
    } catch (e) {

      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'translated_name': name,
      'image': url,
      'subcategories_count': subcategoriesCount,
      "description": description,
      'subcategories': children!.map((child) => child.toJson()).toList(),
    };
    return data;
  }

  @override
  String toString() {
    return 'CategoryModel( id: $id, translated_name:$name, url: $url, descrtiption:$description, children: $children,subcategories_count:$subcategoriesCount)';
  }
}
