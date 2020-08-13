import 'dart:io';

import 'package:avaliacao_desenvolvedor/db/food_helper.dart';
import 'package:avaliacao_desenvolvedor/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';

class AddFood extends StatefulWidget {
  final FoodModel food;

  AddFood({this.food});

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final picker = ImagePicker();

  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _priceFocus = FocusNode();

  bool _userEdited = false;
  FoodModel _editedFood;
  DbHelper helper = DbHelper();
  List<CategoryModel> categoryList = List();
  int _selectedDropMenu = 0;

  @override
  void initState() {
    super.initState();
    _getAllCategory();

    ///Utiliza a mesma pagina para adicionar ou editar uma comida.
    if (widget.food == null) {
      _editedFood = FoodModel();
    } else {
      _editedFood = FoodModel.fromMap(widget.food.toMap());
      _nameController.text = _editedFood.name;
      _descriptionController.text = _editedFood.description;
      _priceController.updateValue(_editedFood.price);

    }
  }

  ///pegando todas as categorias
  void _getAllCategory() {
    helper.getAllCategory().then((list) {
      setState(() {
        categoryList = list;
        _selectedDropMenu = categoryList[0].id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(_editedFood.name ?? "Nova Comida"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedFood.name != null && _editedFood.name.isNotEmpty) {
              Navigator.pop(context, _editedFood);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: _editedFood.img != null &&
                                _editedFood.img.isNotEmpty
                            ? FileImage(File(_editedFood.img))
                            : AssetImage("lib/resources/images/default.jpg"),
                        fit: BoxFit.cover),
                  ),
                ),
                onTap: () {
                  picker.getImage(source: ImageSource.camera).then(((file) {
                    if (file == null) return;
                    setState(() {
                      _editedFood.img = file.path;
                    });
                  }));
                },
              ),
              _dropButtonCategory(),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome da Comida"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedFood.name = text;
                  });
                },
              ),
              TextField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                decoration: InputDecoration(labelText: "Descrição"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedFood.description = text;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 4,
              ),
              TextField(
                controller: _priceController,
                focusNode: _priceFocus,
                decoration: InputDecoration(labelText: "Preço"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedFood.price = _priceController.numberValue;
                },
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropButtonCategory() {
    return DropdownButton<int>(
      value: _selectedDropMenu,
      icon: Icon(Icons.arrow_downward),
      iconSize: 20,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      underline: Container(
        height: 1,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (value) {
        setState(() {
          _selectedDropMenu = value;
          _editedFood.categoryId = value;
        });
      },
      items: categoryList.map((item) {
        return DropdownMenuItem(
          value: item.id,
          child: Text(item.name),
        );
      }).toList(),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
