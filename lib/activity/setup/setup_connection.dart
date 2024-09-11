import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/setup/setup_connection_advance.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupConnection extends StatefulWidget {
  const SetupConnection({super.key});

  @override
  State<SetupConnection> createState() => _SetupConnectionState();
}

class _SetupConnectionState extends State<SetupConnection> {
  List<dynamic> _lsData = [];
  TextEditingController companyCodeCtrl = TextEditingController();
  String connectionName = "";
  String companyCode = "";

  _loadDefaultSetupConnection() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    String? spData = sp.getString("listConnection");
    List<dynamic> lsSpData = jsonDecode(spData!) as List<dynamic>;
    setState(() {
      _lsData = lsSpData;
    });

    connectionName = sp.getString("defaultConnectionName") ?? "";
    companyCode = sp.getString("defaultCompanyCode") ?? "";
    setState(() {
      companyCodeCtrl.text = companyCode;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadDefaultSetupConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup Koneksi"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
                flex: 0,
                child: Container(
                  width: double.infinity,
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                          children: [Utils.labelValueSetter("Connection Active", connectionName)]),
                    ),
                  ),
                )),
            Expanded(
                flex: 0,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils.labelForm("Company Code"),
                        TextField(
                          controller: companyCodeCtrl,
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 10)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              int indexOf = _lsData.indexWhere((d) => d["nama"] == connectionName);

                              if (indexOf < 0) {
                                return;
                              }

                              dynamic mapData = _lsData[indexOf];
                              String imageUrl = mapData["imageUrl"];
                              List<String> imageUrlArray = imageUrl.split("/");
                              imageUrlArray.removeLast();
                              imageUrlArray.removeLast();
                              imageUrl = "${imageUrlArray.join("/")}/${companyCodeCtrl.text}/";

                              setState(() {
                                _lsData[indexOf] = <String, String>{
                                  "nama": mapData["nama"],
                                  "url": mapData["url"],
                                  "imageUrl": imageUrl,
                                  "companyCode": companyCodeCtrl.text
                                };
                              });
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              String jsData = jsonEncode(_lsData);
                              await sp.setString("listConnection", jsData);
                              await sp.setString("defaultCompanyCode", companyCodeCtrl.text);
                              await sp.setString("defaultImageUrl", imageUrl);
                              sp.reload();

                              bool isClose = await Utils.showConfirmMessage(
                                  context, "Setup koneksi mengharuskan restart aplikasi!!");

                              if (isClose) {
                                exit(0);
                              }
                            },
                            child: Text("Simpan"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return SetupConnectionAdvance();
                  },
                ));
              },
              child: Text(
                "Setup Advance Connection",
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
        ),
      ),
    );
  }
}
