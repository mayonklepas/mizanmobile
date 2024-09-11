import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class SetupUser extends StatefulWidget {
  const SetupUser({super.key});

  @override
  State<SetupUser> createState() => _SetupUserState();
}

class _SetupUserState extends State<SetupUser> {
  String idUser = Utils.idUser;
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordLamaCtrl = TextEditingController();
  TextEditingController passwordBaruCtrl = TextEditingController();
  TextEditingController retypePasswordCtrl = TextEditingController();

  Future<dynamic> _postUpdateUsers(Map<String, Object> postBody) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}user/update";
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

  _loadSetupUser() async {
    setState(() {
      usernameCtrl.text = Utils.namaUser;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadSetupUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup User"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Utils.labelForm("Username"),
                TextField(
                  controller: usernameCtrl,
                ),
                Utils.labelForm("Password lama"),
                TextField(
                  controller: passwordLamaCtrl,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                Utils.labelForm("Password baru"),
                TextField(
                  controller: passwordBaruCtrl,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                Utils.labelForm("Retype password baru"),
                TextField(
                  controller: retypePasswordCtrl,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        String username = usernameCtrl.text;
                        String passwordLama = passwordLamaCtrl.text;
                        String passwordBaru = passwordBaruCtrl.text;
                        String retypePassword = retypePasswordCtrl.text;

                        if (retypePassword == passwordBaru) {
                          Map<String, String> postBody = {
                            "username": username,
                            "pwdlama": passwordLama,
                            "pwdbaru": passwordBaru,
                          };

                          dynamic result = await _postUpdateUsers(postBody);

                          if (result["status"] == 0) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Berhasil diupdate")));
                          }
                        } else {
                          Utils.showMessage(
                              "Password baru dan ketik ulang password tidak cocok", context);
                        }
                      },
                      child: Text("Simpan")),
                )
              ]),
        ),
      ),
    );
  }
}
