import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/home_activity.dart';
import 'package:mizanmobile/activity/setup_connection.dart';
import 'package:mizanmobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  Future<dynamic> _postLogin(Map<String, Object> postBody) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}user/login";
    Uri url = Uri.parse(urlString);
    Response response = await post(
      url,
      body: jsonEncode(postBody),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'company-code': Utils.companyCode
      },
    );
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Expanded(
                  flex: 0,
                  child: Container(
                    padding: EdgeInsets.only(top: 100),
                    child: Image.network(
                      Utils.imageUrl + "logo.png",
                      width: 170,
                      height: 170,
                      cacheHeight: 170,
                      cacheWidth: 170,
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
      ),
    );
  }
}
