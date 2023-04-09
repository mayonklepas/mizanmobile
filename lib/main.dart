import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/home_activity.dart';
import 'package:mizanmobile/activity/login_activity.dart';
import 'package:mizanmobile/activity/setup_connection.dart';
import 'package:mizanmobile/activity/setup_program.dart';
import 'package:mizanmobile/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  String image = "";

  Future<dynamic> _postLogin(Map<String, Object> postBody) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}user/login";
    Uri url = Uri.parse(urlString);
    Response response = await post(
      url,
      body: jsonEncode(postBody),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var jsonData = jsonDecode(response.body);
    print(jsonData);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    _setGlobalData();
    super.initState();
  }

  _setGlobalData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      Utils.mainUrl = sp.getString("defaultConnection").toString();
      Utils.imageUrl = sp.getString("defaultImageUrl").toString();
      Utils.idDept = sp.getString("defaultIdDept").toString();
      Utils.namaDept = sp.getString("defaultNamaDept").toString();
      Utils.idAkunStokOpname = sp.getString("defaultIdAkunStokOpname").toString();
      Utils.namaAkunStokOpname = sp.getString("defaultNamaAkunStokOpname").toString();
      Utils.idGudang = sp.getString("defaultIdGudang").toString();
      Utils.namaGudang = sp.getString("defaultNamaGudang").toString();
      Utils.idUser = sp.getString("defaultIdUser").toString();
      Utils.token = sp.getString("token").toString();
      Utils.namaUser = sp.getString("namaUser").toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(50, 20),
            )),
            toolbarHeight: 65,
            flexibleSpace: Container(
                margin: EdgeInsets.only(top: 40),
                alignment: Alignment.center,
                child: Text("LOGIN",
                    style: TextStyle(
                        color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)))),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Expanded(
                    flex: 0,
                    child: Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Image.network(
                        Utils.imageUrl + "logo.png",
                        width: 170,
                        height: 170,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 170,
                            width: 170,
                          );
                        },
                      ),
                    )),
                Expanded(
                  flex: 0,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils.labelForm("Username"),
                        TextField(
                          controller: usernameCtrl,
                          keyboardType: TextInputType.name,
                        ),
                        Utils.labelForm("Password"),
                        TextField(
                          obscureText: true,
                          controller: passwordCtrl,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        Padding(padding: EdgeInsets.only(top: 30)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              dynamic map = <String, Object>{
                                "username": usernameCtrl.text,
                                "password": passwordCtrl.text
                              };

                              dynamic result = await _postLogin(map);
                              if (result != null) {
                                int status = result["status"];
                                if (status == 1) {
                                  Utils.showMessage(result["message"], context);
                                } else {
                                  dynamic data = result["data"];
                                  SharedPreferences sp = await SharedPreferences.getInstance();
                                  sp.setString("idUser", data["iduser"]);
                                  sp.setString("token", data["token"]);
                                  sp.setString("namauser", data["username"]);
                                  Utils.idUser = data["iduser"];
                                  Utils.token = data["token"];
                                  Utils.namaUser = data["username"];
                                  Navigator.pushReplacement(context, MaterialPageRoute(
                                    builder: (context) {
                                      return HomeActivity();
                                    },
                                  ));
                                }
                              }
                            },
                            child: Text("Login"),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Tidak bisa terkoneksi ?"),
                              Padding(padding: EdgeInsets.all(3)),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return SetupConnection();
                                    },
                                  ));
                                },
                                child: Text(
                                  "Atur Koneksi",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
