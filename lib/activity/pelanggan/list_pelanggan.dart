import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class ListPelanggan extends StatefulWidget {
  const ListPelanggan({Key? key}) : super(key: key);

  @override
  State<ListPelanggan> createState() => _ListPelangganState();
}

class _ListPelangganState extends State<ListPelanggan> {
  Future<List<dynamic>>? _dataPelanggan;

  Future<List<dynamic>> _getDataPelanggan({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}pelanggan/daftar");
    if (keyword != "") {
      url = Uri.parse("${Utils.mainUrl}pelanggan/cari?cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    log(jsonData.toString());
    return jsonData;
  }

  Future<dynamic> _postPelanggan(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}pelanggan/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    _dataPelanggan = _getDataPelanggan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPelanggan,
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
                                              showModalInputPelanggan(param: dataList);
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
                                                  context, "Yakin ingin menghapus daa ini ?");

                                              if (isConfirm) {
                                                Map<String, Object> mapData = {
                                                  "noindex": dataList["NOINDEX"].toString()
                                                };
                                                dynamic result =
                                                    await _postPelanggan(mapData, "delete");
                                                setState(() {
                                                  _dataPelanggan = _getDataPelanggan();
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
                            Utils.bagde(
                              dataList["NAMA"].toString().substring(0, 1),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(dataList["NAMA"].toString(), bold: true),
                                    Utils.labelValueSetter(
                                      "GOL 1",
                                      dataList["NAMA_GOLONGAN"].toString(),
                                    ),
                                    Utils.labelValueSetter(
                                      "GOL 2",
                                      dataList["NAMA_GOLONGAN2"].toString(),
                                    ),
                                    Utils.labelValueSetter(
                                      "Klasifikasi",
                                      dataList["NAMA_KLASIFIKASI"].toString(),
                                    ),
                                    Utils.labelValueSetter(
                                      "Department",
                                      dataList["NAMA_DEPT"].toString(),
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

  Future<dynamic> showModalInputPelanggan({dynamic param = null}) {
    TextEditingController kodeCtrl = TextEditingController();
    TextEditingController namaCtrl = TextEditingController();
    TextEditingController golongan1Ctrl = TextEditingController();
    TextEditingController golongan2Ctrl = TextEditingController();
    TextEditingController klasifikasiCtrl = TextEditingController();
    TextEditingController deptCtrl = TextEditingController();

    dynamic popUpResult;
    String idGolongan1 = "";
    String idGolongan2 = "";
    String idKlasifikasi = "";
    String idDept = Utils.idDept;
    String namaDept = Utils.namaDept;
    String noIndex = "";
    String textMode = "Tambah Pelanggan";

    deptCtrl.text = namaDept;

    if (param != null) {
      textMode = "Edit Pelanggan";
      noIndex = param["NOINDEX"].toString();
      kodeCtrl.text = param["KODE"].toString();
      namaCtrl.text = param["NAMA"].toString();
      golongan1Ctrl.text = param["NAMA_GOLONGAN"].toString();
      golongan2Ctrl.text = param["NAMA_GOLONGAN2"].toString();
      klasifikasiCtrl.text = param["NAMA_KLASIFIKASI"].toString();
      deptCtrl.text = param["NAMA_DEPT"].toString();

      idGolongan1 = param["IDGOLONGAN"].toString();
      idGolongan2 = param["IDGOLONGAN2"].toString();
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
                  Text("Kode Pelanggan"),
                  TextField(
                    controller: kodeCtrl,
                  ),
                  Utils.labelForm("Nama pelanggan"),
                  TextField(
                    controller: namaCtrl,
                  ),
                  Utils.labelForm("Golongan 1"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: golongan1Ctrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golonganpelanggan");
                              },
                            ));

                            if (popUpResult == null) return;
                            golongan1Ctrl.text = popUpResult["NAMA"];
                            idGolongan1 = popUpResult["NOINDEX"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Golongan 2"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: golongan2Ctrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(type: "golonganpelanggan");
                              },
                            ));

                            if (popUpResult == null) return;
                            golongan2Ctrl.text = popUpResult["NAMA"];
                            idGolongan2 = popUpResult["NOINDEX"];
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
                                "iddept": idDept,
                                "idgolongan": idGolongan1,
                                "idgolongan2": idGolongan2,
                                "idklasifikasi": idKlasifikasi,
                              };
                              result = await _postPelanggan(mapData, "edit");
                            } else {
                              mapData = {
                                "kode": kodeCtrl.text,
                                "nama": namaCtrl.text,
                                "iddept": idDept,
                                "idgolongan": idGolongan1,
                                "idgolongan2": idGolongan2,
                                "idklasifikasi": idKlasifikasi,
                              };
                              result = await _postPelanggan(mapData, "insert");
                            }
                            Navigator.pop(context);
                            setState(() {
                              _dataPelanggan = _getDataPelanggan();
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
  Widget customSearchBar = Text("Daftar Pelanggan");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {
          showModalInputPelanggan();
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
                        _dataPelanggan = _getDataPelanggan(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Pelanggan");
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
              customSearchBar = Text("Daftar Pelanggan");
              _dataPelanggan = _getDataPelanggan();
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
