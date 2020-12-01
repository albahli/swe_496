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
}
