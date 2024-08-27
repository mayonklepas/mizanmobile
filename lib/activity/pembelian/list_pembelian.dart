import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/pembelian/input_pembelian.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../utility/bottom_modal_filter.dart';

class ListPembelian extends StatefulWidget {
  const ListPembelian({Key? key}) : super(key: key);

  @override
  State<ListPembelian> createState() => _ListPembelianState();
}

class _ListPembelianState extends State<ListPembelian> {
  Future<List<dynamic>>? _dataPembelian;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataPembelian(
      {String keyword = "", String tglDari = "", String tglHingga = "", String idDept = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    if (idDept == "") {
      idDept = Utils.idDeptTemp;
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}pembelian/daftar?iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}pembelian/cari?iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];

    return jsonData;
  }

  Future<dynamic> deletePembelian(String noindex) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    Map<String, String> bodyparam = {"NOINDEX": noindex};
    String urlString = "${Utils.mainUrl}pembelian/delete";
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(bodyparam), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    return jsonData;
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPembelian,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color: Colors.black54,
                          size: 20,
                        ),
                        Text(
                            "${Utils.formatDate(tanggalDariCtrl.text)} - ${Utils.formatDate(tanggalHinggaCtrl.text)}"),
                      ],
                    ),
                  )),
              Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext contex, int index) {
                      dynamic dataList = snapshot.data![index];
                      return Container(
                        child: Card(
                          child: InkWell(
                            onTap: () => showOption(dataList["NOINDEX"]),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.bagde(((index + 1).toString())),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Utils.labelSetter(dataList["NOREF"], bold: true),
                                          Utils.labelSetter(dataList["NAMA_SUPLIER"]),
                                          Utils.labelSetter(
                                              Utils.formatNumber(dataList["TOTAL_PEMBELIAN"]),
                                              bold: true),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              Utils.formatDate(dataList["TANGGAL"]),
                                              style: TextStyle(fontSize: 11),
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
                        ),
                      );
                    }),
              ),
            ],
          );
        }
      }),
    );
  }

  Future<dynamic> showOption(String idPembelian) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext content) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return InputPembelian(idPembelian: idPembelian);
                              },
                            ));
                            setState(() {
                              _dataPembelian = _getDataPembelian();
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
                            Navigator.pop(context);
                            bool isOk = await Utils.showConfirmMessage(
                                context, "Ingin menghapus data ini ?");
                            if (isOk) {
                              dynamic result = await deletePembelian(idPembelian);
                              Navigator.pop(context);
                              if (result["status"] == 0) {
                                setState(() {
                                  _dataPembelian = _getDataPembelian();
                                });
                              } else {
                                Utils.showMessage(result["message"], context);
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
            ),
          );
        });
  }

  dateBottomModal(BuildContext context) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return BottomModalFilter(
              tanggalDariCtrl: tanggalDariCtrl,
              tanggalHinggaCtrl: tanggalHinggaCtrl,
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  _dataPembelian = _getDataPembelian(
                      tglDari: tanggalDariCtrl.text, tglHingga: tanggalHinggaCtrl.text);
                });
              });
        });
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataPembelian = _getDataPembelian();
    super.initState();
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Daftar Pembelian");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return InputPembelian();
            },
          ));
          setState(() {
            _dataPembelian = _getDataPembelian();
          });
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
                        _dataPembelian = _getDataPembelian(
                            keyword: keyword,
                            tglDari: tanggalDariCtrl.text,
                            tglHingga: tanggalHinggaCtrl.text);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Pembelian");
                  }
                });
              },
              icon: customIcon),
          IconButton(
              onPressed: () {
                dateBottomModal(context);
              },
              icon: Icon(Icons.date_range))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar Pembelian");
              _dataPembelian = _getDataPembelian();
              tanggalDariCtrl.text = "";
              tanggalHinggaCtrl.text = "";
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
