import 'dart:io';

import 'package:avaliacao_desenvolvedor/db/food_helper.dart';
import 'package:avaliacao_desenvolvedor/model/food.dart';
import 'package:flutter/material.dart';

class ShowFood extends StatefulWidget {
  final FoodModel food;

  ShowFood({@required this.food});

  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  FoodModel food;
  String typeFood;

  DbHelper db = DbHelper();

  @override
  void initState() {
    food = widget.food;
    _getTypeFood();
    super.initState();
  }

  void _getTypeFood() async {
    final cate = await db.getCategory(food.categoryId);
    typeFood = cate.name;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          food.name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03, vertical: screenHeight * 0.02),
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: food.img != null && food.img != ""
                          ? FileImage(File(food.img))
                          : AssetImage("lib/resources/images/default.jpg"),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: screenHeight * 0.12,
                child: Text(
                  food.name ?? "",
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  food.description ?? "",
                  style: TextStyle(fontSize: 14.0),
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: "R\$ ",
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            TextSpan(
                              text: food.price.toString() ?? "",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: " \n ",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: "Categoria: ",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w800),
                            ),
                            TextSpan(
                              text: "$typeFood",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.normal),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
