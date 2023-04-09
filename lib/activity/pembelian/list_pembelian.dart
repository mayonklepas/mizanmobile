import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../component/date_range_bottom_modal.dart';

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
      {String keyword = "", String tglDari = "", String tglHingga = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}pembelian/daftar?iddept=1&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}pembelian/cari?iddept=1&tgldari=$tglDari&tglhingga=$tglHingga&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(url);
    print(jsonData);
    return jsonData;
  }

  @override
  void initState() {
    _dataPembelian = _getDataPembelian();
    super.initState();
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
                                            Utils.formatRp(dataList["TOTAL_PEMBELIAN"]),
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
  Widget customSearchBar = Text("Daftar Pembelian");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  dateBottomModal(BuildContext context) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return DateRangeBottomModal(
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
}
