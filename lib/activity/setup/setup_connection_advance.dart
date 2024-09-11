import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupConnectionAdvance extends StatefulWidget {
  const SetupConnectionAdvance({super.key});

  @override
  State<SetupConnectionAdvance> createState() => _SetupConnectionAdvanceState();
}

class _SetupConnectionAdvanceState extends State<SetupConnectionAdvance> {
  List<dynamic> _lsData = [];
  String textMode = "";

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

  Future<dynamic> showModalInputConnection({dynamic param = null, indexEdit = -1}) {
    TextEditingController namaCtrl = TextEditingController();
    TextEditingController urlCtrl = TextEditingController();
    TextEditingController imageUrlCtrl = TextEditingController();
    TextEditingController companyCodeCtrl = TextEditingController();

    textMode = "Tambah Koneksi";

    if (param != null) {
      namaCtrl.text = param["nama"];
      urlCtrl.text = param["url"];
      imageUrlCtrl.text = param["imageUrl"];
      companyCodeCtrl.text = param["companyCode"];
      textMode = "Edit Koneksi";
    }
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.labelSetter(textMode, size: 25),
                  Padding(padding: EdgeInsets.all(10)),
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
                        if (namaCtrl.text == "" || urlCtrl.text == "" || imageUrlCtrl.text == "") {
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
                        Navigator.pop(context);
                      },
                      child: Text("Simpan"),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 30,
          ),
          onPressed: () => showModalInputConnection()),
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
                      padding: EdgeInsets.all(5),
                      child: Column(children: [
                        Utils.labelValueSetter("Koneksi Aktif", Utils.connectionName,
                            boldValue: true),
                      ]),
                    ),
                  ),
                )),
            Expanded(
                child: ListView.builder(
                    itemCount: _lsData.length,
                    itemBuilder: (context, index) {
                      dynamic dataList = _lsData[index];
                      String koneksiNama = dataList["nama"] ?? "";
                      String companyCode = dataList["companyCode"] ?? "";
                      String koneksiUrl = dataList["url"] ?? "";
                      String koneksiImageUrl = dataList["imageUrl"] ?? "";
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
                                                    showModalInputConnection(
                                                        param: dataList, indexEdit: index);
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
                                                      Utils.mainUrl = koneksiUrl;
                                                      Utils.imageUrl = koneksiImageUrl;
                                                    });
                                                    SharedPreferences sp =
                                                        await SharedPreferences.getInstance();
                                                    sp.setString(
                                                        "defaultConnectionName", koneksiNama);
                                                    sp.setString("defaultConnection", koneksiUrl);
                                                    sp.setString(
                                                        "defaultImageUrl", koneksiImageUrl);
                                                    sp.setString("defaultCompanyCode", companyCode);
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
                                              Text("Set as Default")
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
                                          Utils.labelSetter(koneksiNama + " / " + companyCode,
                                              bold: true),
                                          Utils.labelSetter(koneksiUrl),
                                          Utils.labelSetter(koneksiImageUrl),
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
