import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:vente_vitment/view/components/button_profil.dart';
import 'package:vente_vitment/view/screens/home_page_screen.dart';
import 'package:vente_vitment/view/sections/user_profil_section.dart';
import 'package:vente_vitment/view_model/current_page_view_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vente_vitment/view_model/vetement_view_model.dart';

class AddClotheScreen extends StatefulWidget {
  const AddClotheScreen({super.key});

  @override
  State<AddClotheScreen> createState() => _AddClotheScreenState();
}

class _AddClotheScreenState extends State<AddClotheScreen> {
  TextEditingController _imageController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _tailleController = TextEditingController();
  TextEditingController _marqueController = TextEditingController();
  TextEditingController _prixController = TextEditingController();

  late List _outputs;
  late File _image;
  late bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        Fluttertoast.showToast(msg: "load Model");
      });
    });
  }

  pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    File imageTemp = File(image.path);
    setState(() {
      _loading = true;

      _image = imageTemp;
      Fluttertoast.showToast(msg: "Image loaded");
    });
    await classifyImage(imageTemp);
  }

  classifyImage(File image) async {
    try {
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
        asynch: true,
      );
      setState(() {
        _loading = false;
        _outputs = output!;
        _categoryController.text = output[0]['label'];
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
      print("$e");
    }
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CurrentPageViewModel currentPage =
        Provider.of<CurrentPageViewModel>(context);
    VetementViewModel vetementViwModel =
        Provider.of<VetementViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "CHETVTMNT",
            style: TextStyle(
              color: Color(0xFFfC9B92),
              fontSize: 27,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(37, 252, 155, 146),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          currentPage.setCurrentScreen(const HomePageScreen());
          currentPage.setCurrentSelectedIndex(2);
        },
        backgroundColor: const Color(0xFFfC9B92),
        child: const Icon(Icons.arrow_back_ios_new),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: 160,
                    height: 56,
                    child: ButtonProfil(
                      buttonColor: Colors.green,
                      buttonName: const SizedBox(
                        width: 200,
                        child: Center(
                          child: Text("upload image",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      onPressed: () async {
                        pickImage();
                        
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _titleController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  labelStyle: TextStyle(
                    color: Color(0xFFfC9B92),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                readOnly: true,
                controller: _categoryController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  labelText: 'Categorie',
                  labelStyle: TextStyle(
                    color: Color(0xFFfC9B92),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _tailleController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  labelText: 'Taille',
                  labelStyle: TextStyle(
                    color: Color(0xFFfC9B92),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _marqueController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  labelText: 'Marque',
                  labelStyle: TextStyle(
                    color: Color(0xFFfC9B92),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(),
                controller: _prixController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  labelStyle: TextStyle(
                    color: Color(0xFFfC9B92),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFFfC9B92),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                    width: 160,
                    height: 56,
                    child: ButtonProfil(
                      buttonColor: const Color(0xFFfC9B92),
                      buttonName: const SizedBox(
                        width: 200,
                        child: Center(
                          child: Text("Ajouter Vetement",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      onPressed: () async {
                        List<int> imageBytes = await _image.readAsBytes();
  
                        String base64String = base64Encode(imageBytes);

                        Map<String, dynamic> clothesData = {
                          "categorie": _categoryController.text,
                          "imageBase64": base64String,
                          "marque": _marqueController.text,
                          "prix": double.parse(_prixController.text),
                          "taille": _tailleController.text,
                          "titre": _titleController.text,
                        };
                        final clothesCollection = FirebaseFirestore.instance.collection('clothes');

                        await clothesCollection
                            .doc()
                            .set(clothesData)
                            .then(
                              (value) async {
                                await vetementViwModel.getVetements();
                                Fluttertoast.showToast(msg: "Clote is added");
                              }
                            );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
