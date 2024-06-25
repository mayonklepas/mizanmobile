import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/home_activity.dart';
import 'package:mizanmobile/activity/login_activity.dart';
import 'package:mizanmobile/activity/setup_connection.dart';
import 'package:mizanmobile/activity/setup_program.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

import 'database_helper.dart';

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
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    _setConnection();
    super.initState();
  }

  _initDatabaseTable() {
    DatabaseHelper db = DatabaseHelper();
    db.execQuery("CREATE TABLE IF NOT EXISTS setup_app(" +
        "id int PRIMARY KEY AUTOINCREMENT," +
        "default_company_code VARCHAR(200)," +
        "default_connection_name VARCHAR(250)," +
        "default_connection_url VARCHAR(250)," +
        "default_image_url VARCHAR(250)," +
        "list_connection TEXT," +
        "id_user_login VARCHAR(200)," +
        "id_user_login VARCHAR(200)," +
        "nama_user_login VARCHAR(200)," +
        "token_login TEXT," +
        ")");
  }

  _setConnection() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (sp.getString("listConnection") != null) {
      return;
    }

    List<dynamic> _lsData = [];

    _lsData.add(<String, String>{
      "nama": "Mizan Cloud Public",
      "url": "http://mizancloud.com:8081/api/",
      "imageUrl": "http://mizancloud.com/mizan-assets/default/",
      "companyCode": "public"
    });
    String jsData = jsonEncode(_lsData);
    sp.setString("listConnection", jsData);
    sp.reload();
    dynamic dataList = jsonDecode(jsData)[0];
    sp.setString("defaultConnectionName", dataList["nama"]);
    sp.setString("defaultConnection", dataList["url"]);
    sp.setString("defaultImageUrl", dataList["imageUrl"]);
    sp.setString("defaultCompanyCode", dataList["companyCode"]);
    //sp.setString("defaultHakAkses", jsonEncode(dataList["hakAkses"]));
    sp.reload();

    Utils.setAllPref();
  }

  Future<String> imageUrl() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Utils.setAllPref();
    return sp.getString("defaultImageUrl").toString();
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
                        padding: EdgeInsets.only(top: 15),
                        child: FutureBuilder<String>(
                            future: imageUrl(),
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      PrinterUtils().printTestDevice();
                                    },
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
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    Utils.connectionName,
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              );
                            }))),
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
                                  sp.setString("hakakses", jsonEncode(data["hakakses"]));
                                  Utils.idUser = data["iduser"];
                                  Utils.token = data["token"];
                                  Utils.namaUser = data["username"];
                                  Utils.hakAkses = data["hakakses"];
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
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Utils.labelSetter("Transaksi tapi koneksi mati ?"),
                              Padding(padding: EdgeInsets.all(3)),
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ListModalBarang(
                                        isLocal: true,
                                      );
                                    },
                                  ));
                                },
                                child: Text(
                                  "Cek barang local",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
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
