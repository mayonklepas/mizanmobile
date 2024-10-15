import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/home_activity.dart';
import 'package:mizanmobile/activity/login_activity.dart';
import 'package:mizanmobile/activity/setup/setup_connection.dart';
import 'package:mizanmobile/activity/setup/setup_program.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

import 'helper/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)),
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

  bool isOffline = false;

  int imageClickCount = 0;

  String connectionName = "";

  Future<dynamic> _postLogin(Map<String, Object> postBody) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}user/login";
    Uri url = Uri.parse(urlString);

    log(urlString);

    Response response = await post(
      url,
      body: jsonEncode(postBody),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'company-code': Utils.companyCode
      },
    );
    var jsonData = jsonDecode(response.body);
    log(jsonData.toString());
    await _saveLoginInfo(jsonData);
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> _offlineLogin(Map<String, dynamic> postBody) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String offlineLoginData = sp.getString("loginInfo") ?? "";
    Map<String, dynamic> data = jsonDecode(offlineLoginData);
    if (offlineLoginData.isNotEmpty) {
      String userName = postBody["username"];
      String password = postBody["password"];
      String offlinePassword = data["password"];
      String offlineUserName = data["data"]["username"];

      if (userName == offlineUserName && password == offlinePassword) {
        return data;
      } else {
        return {"status": 1, "message": "User atau password salah"};
      }
    } else {
      Utils.showMessage("Data offline tidak ada", context);
    }
  }

  _saveLoginInfo(dynamic jsonData) async {
    jsonData["password"] = passwordCtrl.text;
    SharedPreferences sp = await SharedPreferences.getInstance();
    String jsonDataString = jsonEncode(jsonData);
    sp.setString("loginInfo", jsonDataString);
    sp.reload();
  }

  @override
  void initState() {
    super.initState();
    _setConnection();
  }

  _setConnection() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (sp.getString("listConnection") != null) {
      Utils.setAllPref();
      setState(() {
        connectionName = Utils.connectionName;
      });
      return;
    }

    setState(() {
      connectionName = "retail";
    });

    List<dynamic> _lsData = [];

    _lsData.add(<String, String>{
      "nama": "default",
      "url": "http://app.mizancloud.com/api/",
      "imageUrl": "http://mizancloud.com/mizan-assets/default/",
      "companyCode": "retail"
    });
    String jsData = jsonEncode(_lsData);
    sp.setString("listConnection", jsData);
    sp.setString("defaultConnectionName", "default");
    sp.setString("defaultConnection", "http://app.mizancloud.com/api/");
    sp.setString(
        "defaultImageUrl", "http://mizancloud.com/mizan-assets/default/");
    sp.setString("defaultCompanyCode", "retail");
    sp.reload();

    Utils.setAllPref();
  }

  Future<String> imageUrl() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String imageUrlStr = sp.getString("defaultImageUrl") ??
        "http://mizancloud.com/mizan-assets/default/";
    sp.setString("defaultImageUrl", imageUrlStr);
    return imageUrlStr;
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
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)))),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Expanded(
                    flex: 0,
                    child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: FutureBuilder<String>(
                            future: imageUrl(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              return Column(
                                children: [
                                  Image.network(
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            }))),
                Expanded(
                    flex: 0,
                    child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(connectionName))),
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

                              late dynamic result;

                              if (Utils.isOffline) {
                                result = await _offlineLogin(map);
                              } else {
                                result = await _postLogin(map);
                              }

                              if (result != null) {
                                int status = result["status"];
                                if (status == 1) {
                                  Utils.showMessage(result["message"], context);
                                } else {
                                  dynamic data = result["data"];
                                  Utils.idUser = data["iduser"];
                                  Utils.token = data["token"];
                                  Utils.namaUser = data["username"];
                                  Utils.hakAkses = data["hakakses"];
                                  SharedPreferences sp =
                                      await SharedPreferences.getInstance();
                                  sp.setString("idUser", data["iduser"]);
                                  sp.setString("token", data["token"]);
                                  sp.setString("namauser", data["username"]);
                                  sp.setString(
                                      "hakakses", jsonEncode(data["hakakses"]));
                                  sp.reload();
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(
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
                          child: Column(
                            children: [
                              Row(
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
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Internet Bermasalah atau server gangguan ?"),
                                  Padding(padding: EdgeInsets.all(3)),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Gunakan Mode Offline"),
                                  Padding(padding: EdgeInsets.all(3)),
                                  Switch(
                                      value: isOffline,
                                      onChanged: (value) async {
                                        setState(() {
                                          if (value) {
                                            isOffline = true;
                                            Utils.isOffline = true;
                                          } else {
                                            isOffline = false;
                                            Utils.isOffline = false;
                                          }
                                        });
                                      })
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
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
