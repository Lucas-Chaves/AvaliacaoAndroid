class CategoryModel {
  //nomes usados para construçao do sqlite;
  static String categoryTable = "categoryTable";
  static String idCategoryColumn = "idCategoryColumn";
  static String nameCategoryColumn = "nameCategoryColumn";

  int id;
  String name;

  CategoryModel();

  CategoryModel.initial() : name = "Comidinhas";

  CategoryModel.fromMap(Map map)
      : id = map[idCategoryColumn],
        name = map[nameCategoryColumn];

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nome'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameCategoryColumn: name,
    };
    if (id != null) {
      map[idCategoryColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Categoria (id: $id, name: $name)";
  }
}
