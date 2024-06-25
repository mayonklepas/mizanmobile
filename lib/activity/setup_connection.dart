import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupConnection extends StatefulWidget {
  const SetupConnection({super.key});

  @override
  State<SetupConnection> createState() => _SetupConnectionState();
}

class _SetupConnectionState extends State<SetupConnection> {
  List<dynamic> _lsData = [];
  TextEditingController namaCtrl = TextEditingController();
  TextEditingController urlCtrl = TextEditingController();
  TextEditingController imageUrlCtrl = TextEditingController();
  TextEditingController companyCodeCtrl = TextEditingController();
  int indexEdit = -1;

  _loadSetupConnection() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? spData = sp.getString("listConnection");
    List<dynamic> lsSpData = jsonDecode(spData!) as List<dynamic>;
    setState(() {
      _lsData = lsSpData;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadSetupConnection();
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
                    child: Column(children: [
                      Utils.labelValueSetter("Koneksi Aktif", Utils.mainUrl),
                      Utils.labelValueSetter("Image Url Aktif", Utils.imageUrl),
                      Utils.labelValueSetter("Company Code", Utils.companyCode)
                    ]),
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
                        Utils.labelForm("Nama Koneksi"),
                        TextField(
                          controller: namaCtrl,
                        ),
                        Utils.labelForm("Alamat URL Koneksi"),
                        TextField(
                          controller: urlCtrl,
                        ),
                        Utils.labelForm("Alamat URL Image"),
                        TextField(
                          controller: imageUrlCtrl,
                        ),
                        Utils.labelForm("Company Code"),
                        TextField(
                          controller: companyCodeCtrl,
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 10)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (namaCtrl.text == "" ||
                                  urlCtrl.text == "" ||
                                  imageUrlCtrl.text == "") {
                                return;
                              }
                              setState(() {
                                if (indexEdit == -1) {
                                  _lsData.add(<String, String>{
                                    "nama": namaCtrl.text,
                                    "url": urlCtrl.text,
                                    "imageUrl": imageUrlCtrl.text,
                                    "companyCode": companyCodeCtrl.text
                                  });
                                } else {
                                  _lsData[indexEdit] = <String, String>{
                                    "nama": namaCtrl.text,
                                    "url": urlCtrl.text,
                                    "imageUrl": imageUrlCtrl.text,
                                    "companyCode": companyCodeCtrl.text
                                  };
                                }
                              });
                              indexEdit = -1;
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              String jsData = jsonEncode(_lsData);
                              await sp.setString("listConnection", jsData);
                              sp.reload();
                              namaCtrl.text = "";
                              urlCtrl.text = "";
                              imageUrlCtrl.text = "";
                              companyCodeCtrl.text = "";
                            },
                            child: Text("Simpan"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Expanded(
                child: ListView.builder(
                    itemCount: _lsData.length,
                    itemBuilder: (context, index) {
                      dynamic dataList = _lsData[index];
                      return Container(
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: ((context) {
                                    return Container(
                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                      height: 100,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    if (Navigator.canPop(context)) {
                                                      Navigator.pop(context);
                                                    }
                                                    setState(() {
                                                      indexEdit = index;
                                                      namaCtrl.text = dataList["nama"];
                                                      urlCtrl.text = dataList["url"];
                                                      imageUrlCtrl.text = dataList["imageUrl"];
                                                      companyCodeCtrl.text =
                                                          dataList["companyCode"];
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.black54,
                                                  )),
                                              Text("Edit")
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      _lsData.remove(dataList);
                                                    });

                                                    SharedPreferences sp =
                                                        await SharedPreferences.getInstance();
                                                    String jsData = jsonEncode(_lsData);
                                                    await sp.setString("listConnection", jsData);
                                                    sp.reload();
                                                    if (Navigator.canPop(context)) {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.black54,
                                                  )),
                                              Text("Delete")
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      Utils.mainUrl = dataList["url"];
                                                      Utils.imageUrl = dataList["imageUrl"];
                                                    });
                                                    SharedPreferences sp =
                                                        await SharedPreferences.getInstance();
                                                    sp.setString(
                                                        "defaultConnectionName", dataList["nama"]);
                                                    sp.setString(
                                                        "defaultConnection", dataList["url"]);
                                                    sp.setString(
                                                        "defaultImageUrl", dataList["imageUrl"]);
                                                    sp.setString("defaultCompanyCode",
                                                        dataList["companyCode"]);
                                                    sp.reload();
                                                    if (Navigator.canPop(context)) {
                                                      Navigator.pop(context);
                                                    }

                                                    Utils.setAllPref();

                                                    bool isClose = await Utils.showConfirmMessage(
                                                        context,
                                                        "Setup koneksi mengharuskan restart aplikasi!!");

                                                    if (isClose) {
                                                      exit(0);
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.check,
                                                    color: Colors.black54,
                                                  )),
                                              Text("Set Default")
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.bagde((index + 1).toString()),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Utils.labelSetter(dataList["nama"], bold: true),
                                          Utils.labelSetter(dataList["url"]),
                                          Utils.labelSetter(dataList["imageUrl"]),
                                          Utils.labelSetter(dataList["companyCode"]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
