import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class ListSuplier extends StatefulWidget {
  const ListSuplier({Key? key}) : super(key: key);

  @override
  State<ListSuplier> createState() => _ListSuplierState();
}

class _ListSuplierState extends State<ListSuplier> {
  Future<List<dynamic>>? _dataSuplier;

  Future<List<dynamic>> _getDataSuplier({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}suplier/daftar");
    if (keyword != null && keyword != "") {
      url = Uri.parse("${Utils.mainUrl}suplier/cari?cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    return jsonData;
  }

  Future<dynamic> _postSuplier(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}suplier/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    _dataSuplier = _getDataSuplier();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataSuplier,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext contex, int index) {
                dynamic dataList = snapshot.data![index];
                return Container(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext content) {
                              return Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                height: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                              showModalInputSuplier(param: dataList);
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
                                              bool isConfirm = await Utils.showConfirmMessage(
                                                  context, "Yakin ingin menghapus dara ini ?");

                                              if (isConfirm) {
                                                Map<String, Object> mapData = {
                                                  "noindex": dataList["NOINDEX"].toString()
                                                };
                                                dynamic result =
                                                    await _postSuplier(mapData, "delete");
                                                setState(() {
                                                  _dataSuplier = _getDataSuplier();
                                                });
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.black54,
                                            )),
                                        Text("Delete")
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Utils.bagde(dataList["NAMA"].toString().substring(0, 1)),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(dataList["NAMA"].toString(), bold: true),
                                    Utils.labelSetter(dataList["KODE"].toString()),
                                    Table(
                                      defaultColumnWidth: FlexColumnWidth(),
                                      children: [
                                        Utils.labelDuoSetter(
                                            "Golongan", dataList["NAMA_GOLONGAN"].toString(),
                                            isRight: true),
                                        Utils.labelDuoSetter(
                                            "Klasifikasi", dataList["NAMA_KLASIFIKASI"].toString(),
                                            isRight: true),
                                        Utils.labelDuoSetter(
                                            "Department", dataList["NAMA_DEPT"].toString(),
                                            isRight: true)
                                      ],
                                    )
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
              });
        }
      }),
    );
  }

  Future<dynamic> showModalInputSuplier({dynamic param = null}) {
    TextEditingController kodeCtrl = TextEditingController();
    TextEditingController namaCtrl = TextEditingController();
    TextEditingController golonganCtrl = TextEditingController();
    TextEditingController klasifikasiCtrl = TextEditingController();
    TextEditingController deptCtrl = TextEditingController();

    dynamic popUpResult;
    String idKlasifikasi = "";
    String idGolongan = "";
    String idDept = Utils.idDept;
    String namaDept = Utils.namaDept;
    String noIndex = "";
    String textMode = "Tambah Suplier";

    deptCtrl.text = namaDept;

    if (param != null) {
      textMode = "Edit Suplier";
      noIndex = param["NOINDEX"].toString();
      kodeCtrl.text = param["KODE"].toString();
      namaCtrl.text = param["NAMA"].toString();
      klasifikasiCtrl.text = param["NAMA_KLASIFIKASI"].toString();
      deptCtrl.text = param["NAMA_DEPT"].toString();
      idKlasifikasi = param["IDKLASIFIKASI"].toString();
      idDept = param["IDDEPT"].toString();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.labelSetter(textMode, size: 25),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Kode"),
                  TextField(
                    controller: kodeCtrl,
                  ),
                  Utils.labelForm("Nama"),
                  TextField(
                    controller: namaCtrl,
                  ),
                  Utils.labelForm("Golongan"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: golonganCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golongansuplier");
                              },
                            ));

                            if (popUpResult == null) return;
                            golonganCtrl.text = popUpResult["NAMA"];
                            idGolongan = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Klasifikasi"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: klasifikasiCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "klasifikasi");
                              },
                            ));

                            if (popUpResult == null) return;
                            klasifikasiCtrl.text = popUpResult["NAMA"];
                            idKlasifikasi = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Departement"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: deptCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "dept");
                              },
                            ));

                            if (popUpResult == null) return;
                            deptCtrl.text = popUpResult["NAMA"];
                            idDept = popUpResult["NOINDEX"].toString();
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            Map<String, Object> mapData = {};
                            dynamic result;
                            if (param != null) {
                              mapData = {
                                "noindex": noIndex,
                                "kode": kodeCtrl.text,
                                "nama": namaCtrl.text,
                                "idgolongan": idGolongan,
                                "iddept": idDept,
                                "idklasifikasi": idKlasifikasi,
                              };
                              result = await _postSuplier(mapData, "edit");
                            } else {
                              mapData = {
                                "kode": kodeCtrl.text,
                                "nama": namaCtrl.text,
                                "idgolongan": idGolongan,
                                "iddept": idDept,
                                "idklasifikasi": idKlasifikasi,
                              };
                              result = await _postSuplier(mapData, "insert");
                            }
                            Navigator.pop(context);
                            setState(() {
                              _dataSuplier = _getDataSuplier();
                            });
                          },
                          child: Text("Simpan")))
                ],
              ),
            ),
          );
        });
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Daftar Suplier");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {
          showModalInputSuplier();
        },
      ),
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = Icon(Icons.clear);
                    customSearchBar = Utils.appBarSearch((keyword) {
                      setState(() {
                        _dataSuplier = _getDataSuplier(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Suplier");
                  }
                });
              },
              icon: customIcon)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar Suplier");
              _dataSuplier = _getDataSuplier();
            });
          });
        },
        child: Container(
          child: setListFutureBuilder(),
        ),
      ),
    );
  }
}
