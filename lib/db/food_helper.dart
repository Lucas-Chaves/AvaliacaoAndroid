import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:avaliacao_desenvolvedor/model/model.dart';

///Criando um singleton para fazer as operaçoes no banco
class DbHelper {
  static final DbHelper _instance = DbHelper.internal();

  factory DbHelper() => _instance;

  DbHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  ///iniciando o banco
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "food13.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE ${CategoryModel.categoryTable} (${CategoryModel.idCategoryColumn} INTEGER PRIMARY KEY, ${CategoryModel.nameCategoryColumn} TEXT); "
      );
      await db.execute(
        "CREATE TABLE ${FoodModel.foodTable} (${FoodModel.idFoodColumn} INTEGER PRIMARY KEY, ${FoodModel.nameFoodColumn} TEXT, ${FoodModel.descriptionFoodColumn} TEXT, "
        "${FoodModel.priceFoodColumn} REAL, ${FoodModel.categoryFoodColumn} INT, ${FoodModel.imgFoodColumn} TEXT,   FOREIGN KEY(${FoodModel.categoryFoodColumn}) REFERENCES ${CategoryModel.categoryTable}(${CategoryModel.idCategoryColumn}));",
      );
    });
  }

  ///Operacoes de CRUD para categoria
  Future<CategoryModel> saveCategory(CategoryModel category) async {
    Database dbFood = await db;
    category.id =
        await dbFood.insert(CategoryModel.categoryTable, category.toMap());
    return category;
  }

  Future<CategoryModel> getCategory(int id) async {
    Database dbFood = await db;
    List<Map> maps = await dbFood.query(CategoryModel.categoryTable,
        columns: [
          CategoryModel.idCategoryColumn,
          CategoryModel.nameCategoryColumn
        ],
        where: "${CategoryModel.idCategoryColumn} = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return CategoryModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteCategory(int id) async {
    Database dbFood = await db;
    return await dbFood.delete(CategoryModel.categoryTable,
        where: "${CategoryModel.idCategoryColumn} = ?", whereArgs: [id]);
  }

  Future<int> updateCategory(CategoryModel category) async {
    Database dbFood = await db;
    return await dbFood.update(CategoryModel.categoryTable, category.toMap(),
        where: "${CategoryModel.idCategoryColumn} = ?",
        whereArgs: [category.id]);
  }

  Future<List<CategoryModel>> getAllCategory() async {
    Database dbFood = await db;
    List listMap =
        await dbFood.rawQuery("SELECT * FROM ${CategoryModel.categoryTable}");
    List<CategoryModel> listCategory = List();
    for (Map m in listMap) {
      listCategory.add(CategoryModel.fromMap(m));
    }
    return listCategory;
  }

  ///Operacoes de CRUD para comida
  Future<FoodModel> saveFood(FoodModel food) async {
    Database dbFood = await db;
    food.id = await dbFood.insert(FoodModel.foodTable, food.toMap());
    return food;
  }

  Future<FoodModel> getFood(int id) async {
    Database dbFood = await db;
    List<Map> maps = await dbFood.query(FoodModel.foodTable,
        columns: [
          FoodModel.nameFoodColumn,
          FoodModel.descriptionFoodColumn,
          FoodModel.priceFoodColumn,
          FoodModel.categoryFoodColumn,
          FoodModel.imgFoodColumn,
        ],
        where: "${FoodModel.idFoodColumn} = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return FoodModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteFood(int id) async {
    Database dbFood = await db;
    return await dbFood.delete(FoodModel.foodTable,
        where: "${FoodModel.idFoodColumn} = ?", whereArgs: [id]);
  }

  Future<int> updateFood(FoodModel food) async {
    Database dbFood = await db;
    return await dbFood.update(FoodModel.foodTable, food.toMap(),
        where: "${FoodModel.idFoodColumn} = ?", whereArgs: [food.id]);
  }

  Future<List<FoodModel>> getAllFoods() async {
    Database dbFood = await db;
    List listMap =
        await dbFood.rawQuery("SELECT * FROM ${FoodModel.foodTable}");
    List<FoodModel> listFood = List();
    for (Map m in listMap) {
      listFood.add(FoodModel.fromMap(m));
    }
    return listFood;
  }

  Future close() async {
    Database dbFood = await db;
    await dbFood.close();
  }
}
