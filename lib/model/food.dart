
class FoodModel {
  static String foodTable = "foodTable";
  static String idFoodColumn = "idFoodColumn";
  static String nameFoodColumn = "nameFoodColumn";
  static String descriptionFoodColumn = "descriptionFoodColumn";
  static String priceFoodColumn = "priceFoodColumn";
  static String categoryFoodColumn = "idCategoryFoodColumn";
  static String imgFoodColumn = "imgFoodColumn";

  int id;
  String name;
  String description;
  double price;
  int categoryId;
  String img;

  FoodModel();

  FoodModel.initial()
      : name = "",
        description = "",
        price = 0.0,
        categoryId = 1,
        img = null;

  FoodModel.fromMap(Map map)
  : id = map[idFoodColumn],
  name = map[nameFoodColumn],
  description = map[descriptionFoodColumn],
  price = map[priceFoodColumn],
  categoryId = map[categoryFoodColumn],
  img = map[imgFoodColumn];

  FoodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nome'];
    description = json['descricao'];
    img = json['foto'];
    price = json['preco'];
    categoryId = json['categoria_id'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      nameFoodColumn: name,
      descriptionFoodColumn: description,
      priceFoodColumn: price,
      categoryFoodColumn: categoryId,
      imgFoodColumn: img
    };
    if (id != null) {
      map[idFoodColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Comida (id: $id, name: $name, descrição: $description, preço: $price, Categoria id: $categoryId, image path: $img)";
  }
}
