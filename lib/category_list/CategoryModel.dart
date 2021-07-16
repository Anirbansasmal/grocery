class CategoryModel {
  String status;
  String message;
  List<CategoryData> categorydata;

  CategoryModel({this.status, this.message, this.categorydata});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['categorydata'] != null) {
      categorydata = new List<CategoryData>();
      json['categorydata'].forEach((v) {
        categorydata.add(new CategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.categorydata != null) {
      data['categorydata'] = this.categorydata.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryData {
  String catId;
  String name;
  String uniqueName;
  String categoryImage;
  String description;
  String parentId;
  String status;
  String catPriority;
  String metaTitle;
  String metaKeyword;
  String metaDescription;
  String dateAdded;
  String parentcatname;
  String categoryimgstat;

  CategoryData(
      {this.catId,
      this.name,
      this.uniqueName,
      this.categoryImage,
      this.description,
      this.parentId,
      this.status,
      this.catPriority,
      this.metaTitle,
      this.metaKeyword,
      this.metaDescription,
      this.dateAdded,
      this.parentcatname,
      this.categoryimgstat});

  CategoryData.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'];
    name = json['name'];
    uniqueName = json['unique_name'];
    categoryImage = json['category_image'];
    description = json['description'];
    parentId = json['parent_id'];
    status = json['status'];
    catPriority = json['cat_priority'];
    metaTitle = json['meta_title'];
    metaKeyword = json['meta_keyword'];
    metaDescription = json['meta_description'];
    dateAdded = json['date_added'];
    parentcatname = json['parentcatname'];
    categoryimgstat = json['categoryimgstat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cat_id'] = this.catId;
    data['name'] = this.name;
    data['unique_name'] = this.uniqueName;
    data['category_image'] = this.categoryImage;
    data['description'] = this.description;
    data['parent_id'] = this.parentId;
    data['status'] = this.status;
    data['cat_priority'] = this.catPriority;
    data['meta_title'] = this.metaTitle;
    data['meta_keyword'] = this.metaKeyword;
    data['meta_description'] = this.metaDescription;
    data['date_added'] = this.dateAdded;
    data['parentcatname'] = this.parentcatname;
    return data;
  }
}
