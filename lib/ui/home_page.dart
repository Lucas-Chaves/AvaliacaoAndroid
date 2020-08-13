import 'dart:convert';
import 'dart:io';

import 'package:avaliacao_desenvolvedor/db/food_helper.dart';
import 'package:avaliacao_desenvolvedor/model/model.dart';
import 'package:avaliacao_desenvolvedor/ui/add_Food.dart';
import 'package:avaliacao_desenvolvedor/ui/add_category.dart';
import 'package:avaliacao_desenvolvedor/ui/show_food.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

///Enum para trabalhar melhor com categorias.
enum TypeOperation {
  CREATEFOOD,
  CREATECATEGORY,
  EDITFOOD,
  DELETEFOOD,
  IMPORTJSON,
  DEFAULT
}

class _HomePageState extends State<HomePage> {
  ///Key para poder exibir snackbar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  DbHelper helper = DbHelper();
  CategoryModel test = CategoryModel.initial();
  FoodModel test1 = FoodModel.initial();
  List<FoodModel> foods = List();
  List<CategoryModel> categories = List();

  @override
  void initState() {
    super.initState();
    _getAllFoods();
    _getAllCategories();
//    helper.saveCategory(CategoryModel.initial());
//    helper.saveFood(FoodModel.initial());
//    init();
  }

  init() async {
    test = await helper.getCategory(1);
    test1 = await helper.getFood(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Food Buy"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: foods.length,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
        ),
        itemBuilder: (context, index) {
          return _foodCard(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {},
        child: PopupMenuButton<TypeOperation>(
          icon: Icon(Icons.add),
          itemBuilder: (context) => <PopupMenuEntry<TypeOperation>>[
            PopupMenuItem<TypeOperation>(
              child: Text("Adicionar comida"),
              value: TypeOperation.CREATEFOOD,
            ),
            PopupMenuItem<TypeOperation>(
              child: Text("Adicionar categoria"),
              value: TypeOperation.CREATECATEGORY,
            ),
            PopupMenuItem<TypeOperation>(
              child: Text("Importar Json"),
              value: TypeOperation.IMPORTJSON,
            ),
          ],
          onSelected: _selectedSave,
        ),
      ),
    );
  }

  /// Card sobre os dados da comida
  Widget _foodCard(BuildContext context, int index) {
    return GestureDetector(
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Edit',
            color: Colors.black87,
            icon: Icons.edit,
            onTap: () => _dismissSelection(
                TypeOperation.EDITFOOD, foods[index].id, index),
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => _dismissSelection(
                TypeOperation.DELETEFOOD, foods[index].id, index),
          ),
        ],
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: foods[index].img != null &&
                                foods[index].img != ""
                            ? FileImage(File(foods[index].img))
                            : AssetImage("lib/resources/images/default.jpg"),
                        fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          foods[index].name ?? "",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          foods[index].description ?? "",
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Text(
                        "R\$ " + foods[index].price.toString() ?? "",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        _showFood(foods[index]);
      },
    );
  }

  ///funcao do snackbar
  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: Colors.red,
    ));
  }

  ///Apagar uma comida ou editar a mesma
  void _dismissSelection(
      TypeOperation typeOperation, int foodId, int index) async {
    switch (typeOperation) {
      case TypeOperation.DELETEFOOD:
        await helper.deleteFood(foodId);
        setState(() {
          foods.removeAt(index);
        });
        _showInSnackBar("Alimento deletado");
        break;
      case TypeOperation.EDITFOOD:
        _createFood(food: foods[index]);
        break;
      default:
        break;
    }
  }

  ///Pagina para os dados da comida
  void _showFood(FoodModel food) {
    final showFood =
        MaterialPageRoute(builder: (context) => ShowFood(food: food));
    Navigator.push(context, showFood);
    return;
  }

  /// Funcao para validar quando tu escolher salvar categoria ou comida
  void _selectedSave(TypeOperation result) {
    switch (result) {
      case TypeOperation.CREATEFOOD:
        if (categories.isNotEmpty) {
          _createFood();
          break;
        } else {
          _showInSnackBar("Primeiro cadastre alguma categoria de comida");
          break;
        }
        break;
      case TypeOperation.CREATECATEGORY:
        _createCategory();
        break;
      case TypeOperation.IMPORTJSON:
        _importJson();
        break;
      default:
        break;
    }
  }

  ///Importação de por arquivo JSon
  Future<void> _importJson() async {
    List<CategoryModel> listCategories = List();
    List<FoodModel> listFoods = List();
    File file;

    /// Le o arquivo do celular
    try {
      file = await FilePicker.getFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      ///Pega o array em json e colocar na lista de comidas e categorias.
      String json = file.readAsStringSync();
      final jsonMap = jsonDecode(json);
      jsonMap["categorias"].forEach((map) {
        listCategories.add(CategoryModel.fromJson(map));
      });
      jsonMap["produtos"].forEach((map) {
        listFoods.add(FoodModel.fromJson(map));
      });

      ///Verifica se existe alguma coisa no banco se existir ele vai substituir pelos dados em json.
      if (categories.isNotEmpty) {
        listCategories.forEach((element) {
          helper.updateCategory(element);
        });
        listFoods.forEach((element) {
          helper.updateFood(element);
        });
        _getAllFoods();
        return;
      } else {
        listCategories.forEach((element) {
          helper.saveCategory(element);
        });
        listFoods.forEach((element) {
          helper.saveFood(element);
        });
        _getAllFoods();
        return;
      }
    } catch (e) {
      _showInSnackBar("Import Json cancelado");
    }
  }

  ///Funcao de ir para pagina de criar Food
  void _createFood({FoodModel food}) async {
    final foodRoute = MaterialPageRoute(
        builder: (context) => AddFood(
              food: food,
            ));
    final foodResponse = await Navigator.push(context, foodRoute);

    if (foodResponse != null) {
      if (food != null) {
        await helper.updateFood(foodResponse);
        _getAllFoods();
      } else {
        await helper.saveFood(foodResponse);
      }
      _getAllFoods();
    }
  }

  ///Funcao de ir para pagina de criar categoria
  void _createCategory({CategoryModel category}) async {
    final categoryRoute = MaterialPageRoute(
        builder: (context) => AddCategory(
              category: category,
            ));
    final categoryResponse = await Navigator.push(context, categoryRoute);

    if (categoryResponse != null) {
      if (category != null) {
        await helper.updateCategory(categoryResponse);
        _getAllFoods();
      } else {
        await helper.saveCategory(categoryResponse);
      }
      _getAllFoods();
    }
  }

  /// Retorna todas as comidas
  void _getAllFoods() {
    helper.getAllFoods().then((list) {
      setState(() {
        foods = list;
      });
    });
  }

  /// Retorna todas as categorias
  void _getAllCategories() {
    helper.getAllCategory().then((list) {
      setState(() {
        categories = list;
      });
    });
  }
}
