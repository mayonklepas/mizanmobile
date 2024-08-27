import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penerimaan/input_penerimaan.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../utility/bottom_modal_filter.dart';

class ListPenerimaan extends StatefulWidget {
  const ListPenerimaan({Key? key}) : super(key: key);

  @override
  State<ListPenerimaan> createState() => _ListPenerimaanState();
}

class _ListPenerimaanState extends State<ListPenerimaan> {
  Future<List<dynamic>>? _dataPenerimaan;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataPenerimaan(
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
        "${Utils.mainUrl}penerimaanbarang/daftar?iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}penerimaanbarang/cari?iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body)["data"];
    return jsonData;
  }

  Future<dynamic> deletePenerimaan(String noindex) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    Map<String, String> bodyparam = {"NOINDEX": noindex};
    String urlString = "${Utils.mainUrl}penerimaanbarang/delete";
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(bodyparam), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    return jsonData;
  }

  Future<dynamic> showOption(String idPenerimaan) {
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
                                return InputPenerimaan(idPenerimaan: idPenerimaan);
                              },
                            ));
                            setState(() {
                              _dataPenerimaan = _getDataPenerimaan();
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
                              dynamic result = await deletePenerimaan(idPenerimaan);
                              Navigator.pop(context);
                              if (result["status"] == 0) {
                                setState(() {
                                  _dataPenerimaan = _getDataPenerimaan();
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

  @override
  void initState() {
    Utils.initAppParam();
    _dataPenerimaan = _getDataPenerimaan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenerimaan,
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
                                          Utils.labelSetter(dataList["KETERANGAN"] ?? ""),
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

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Daftar Penerimaan");
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
              return InputPenerimaan();
            },
          ));
          setState(() {
            _dataPenerimaan = _getDataPenerimaan();
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
                        _dataPenerimaan = _getDataPenerimaan(
                            keyword: keyword,
                            tglDari: tanggalDariCtrl.text,
                            tglHingga: tanggalHinggaCtrl.text);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Penerimaan");
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
              customSearchBar = Text("Daftar Penerimaan");
              _dataPenerimaan = _getDataPenerimaan();
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
                  _dataPenerimaan = _getDataPenerimaan(
                      tglDari: tanggalDariCtrl.text, tglHingga: tanggalHinggaCtrl.text);
                });
              });
        });
  }
}
