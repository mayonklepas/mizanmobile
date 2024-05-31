import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/component/bottom_modal_filter.dart';
import 'package:mizanmobile/activity/transferbarang/input_transfer_barang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListTransferBarang extends StatefulWidget {
  const ListTransferBarang({Key? key}) : super(key: key);

  @override
  State<ListTransferBarang> createState() => _ListTransferBarangState();
}

class _ListTransferBarangState extends State<ListTransferBarang> {
  Future<List<dynamic>>? _dataTransferBarang;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<dynamic> _postTranferbarang(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}transferbarang/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body);
    Navigator.pop(context);
    return jsonData;
  }

  Future<List<dynamic>> _getDataTransferBarang(
      {String keyword = "", String tglDari = "", String tglHingga = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}transferbarang/daftar?iddept=${Utils.idDept}&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}transferbarang/cari?iddept=${Utils.idDept}&tgldari=$tglDari&tglhingga=$tglHingga&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    return jsonData;
  }

  @override
  void initState() {
    _dataTransferBarang = _getDataTransferBarang();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataTransferBarang,
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
                                                onPressed: () {
                                                  if (Utils.hakAkses["mobile_edittransferbarang"] ==
                                                      0) {
                                                    return Utils.showMessage(
                                                        "Akses ditolak", context);
                                                  }

                                                  if (Navigator.canPop(context)) {
                                                    Navigator.pop(context);
                                                  }
                                                  Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) {
                                                      return InputTransferBarang(
                                                        idTransaksi: dataList["NOINDEX"],
                                                      );
                                                    },
                                                  ));
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
                                                  if (Utils.hakAkses["mobile_edittransferbarang"] ==
                                                      0) {
                                                    return Utils.showMessage(
                                                        "Akses ditolak", context);
                                                  }

                                                  Map<String, Object> mapData = {
                                                    "idgenjur": dataList["NOINDEX"]
                                                  };
                                                  dynamic result = await _postTranferbarang(
                                                      mapData, "deleteheader");
                                                  Utils.showMessage(result["message"], context);
                                                  if (Navigator.canPop(context)) {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                                  setState(() {
                                                    _dataTransferBarang = _getDataTransferBarang(
                                                        tglDari: tanggalDariCtrl.text,
                                                        tglHingga: tanggalHinggaCtrl.text);
                                                  });
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
                          child: Card(
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
                                          Utils.labelSetter(dataList["NOREF"], bold: true),
                                          Utils.labelValueSetter(
                                            "Dari",
                                            dataList["NAMA_GUDANG_DARI"],
                                          ),
                                          Utils.labelValueSetter(
                                            "Ke",
                                            dataList["NAMA_GUDANG_TUJUAN"],
                                          ),
                                          Utils.labelValueSetter(
                                            "Keterangan",
                                            dataList["KETERANGAN"],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              Utils.formatDate(dataList["TANGGAL"]),
                                              style: TextStyle(fontSize: 13),
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
  Widget customSearchBar = Text("Daftar Transfer Barang");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return InputTransferBarang(
                idTransaksi: "",
              );
            },
          ));
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
                        _dataTransferBarang = _getDataTransferBarang(
                            keyword: keyword,
                            tglDari: tanggalDariCtrl.text,
                            tglHingga: tanggalHinggaCtrl.text);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Transfer Barang");
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
              customSearchBar = Text("Daftar Transfer Barang");
              _dataTransferBarang = _getDataTransferBarang();
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
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  _dataTransferBarang = _getDataTransferBarang(
                      tglDari: tanggalDariCtrl.text, tglHingga: tanggalHinggaCtrl.text);
                });
              },
              tanggalDariCtrl: tanggalDariCtrl,
              tanggalHinggaCtrl: tanggalHinggaCtrl);
        });
  }
}
