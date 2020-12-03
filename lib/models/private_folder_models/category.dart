import 'package:flutter/cupertino.dart';
import 'package:swe496/Database/private_folder_collection.dart';

class Category {
  String _categoryId;
  String _categoryName;

  String get categoryId => _categoryId;

  String get categoryName => _categoryName;

  Category(this._categoryId, this._categoryName);

  Category.fromJson(Map<String, dynamic> json) {
    _categoryId = json['categoryId'];
    _categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['categoryId'] = this._categoryId;
    data['categoryName'] = this._categoryName;
    return data;
  }

  Future<void> createCategory(String userId, String categoryName) async {
    await PrivateFolderCollection().createCategory(userId, categoryName);
  }

  Future<void> deleteCategory({
    @required String userId,
    @required String categoryId,
  }) async {
    await PrivateFolderCollection()
        .deleteCategory(userId: userId, categoryId: categoryId);
  }

  Future<void> changeCategoryName({
    @required String userId,
    @required String categoryId,
    @required String newCategoryName,
  }) async {

    await PrivateFolderCollection()
        .changeCategoryName(userId: userId, categoryId: categoryId, newCategoryName: newCategoryName);
  }
}
