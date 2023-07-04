import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../component/date_range_bottom_modal.dart';

class ListMutasi extends StatefulWidget {
  final String idBarang;
  const ListMutasi({Key? key, required this.idBarang});

  @override
  State<ListMutasi> createState() => _ListMutasiState();
}

class _ListMutasiState extends State<ListMutasi> {
  String idBarangGlobal = "";
  Future<dynamic>? _dataMutasi;
  dynamic? _dataheader;
  Future<List<dynamic>>? _dataMutasiHeader;
  Future<List<dynamic>>? _dataMutasiDetail;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<dynamic> _getDataMutasi(
      {String keyword = "", String tglDari = "", String tglHingga = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}barang/mutasi?idbarang=${widget.idBarang}&idgudang=1-1&tgldari=$tglDari&tglhingga=$tglHingga");
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    _dataheader = await jsonData["header"][0];
    return jsonData;
  }

  Future<List<dynamic>> getDetail(
      {String keyword = "", String tglDari = "", String tglHingga = ""}) async {
    var data = await _getDataMutasi(keyword: keyword, tglDari: tglDari, tglHingga: tglHingga);
    _dataheader = await data["header"][0];
    return data["detail"];
  }

  @override
  void initState() {
    _dataMutasiDetail = getDetail();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataMutasiDetail,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Utils.labelSetter(_dataheader["NAMA"].toString(), bold: true),
                        Utils.labelSetter(_dataheader["KODE"].toString(), bold: true),
                        Table(
                          defaultColumnWidth: FlexColumnWidth(),
                          children: [
                            Utils.labelDuoSetter("Satuan", _dataheader["KODE_SATUAN"].toString(),
                                isRight: true, bold: true),
                            Utils.labelDuoSetter(
                                "Stok Awal", Utils.formatNumber(_dataheader["STOK_AWAL"]),
                                isRight: true, bold: true),
                            Utils.labelDuoSetter("Masuk", Utils.formatNumber(_dataheader["MASUK"]),
                                isRight: true),
                            Utils.labelDuoSetter(
                                "Keluar", Utils.formatNumber(_dataheader["KELUAR"]),
                                isRight: true),
                            Utils.labelDuoSetter(
                                "Stok Akhir", Utils.formatNumber(_dataheader["STOK_AKHIR"]),
                                isRight: true, bold: true)
                          ],
                        )
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
                                        Utils.labelSetter(dataList["NOREF"].toString(), bold: true),
                                        Table(
                                          defaultColumnWidth: FlexColumnWidth(),
                                          children: [
                                            Utils.labelDuoSetter(
                                                "Kelompok", dataList["KELOMPOK_TRANS"],
                                                isRight: true, bold: true),
                                            Utils.labelDuoSetter(
                                                "Masuk", Utils.formatNumber(dataList["MASUK"]),
                                                isRight: true),
                                            Utils.labelDuoSetter(
                                                "Keluar", Utils.formatNumber(dataList["KELUAR"]),
                                                isRight: true),
                                            Utils.labelDuoSetter(
                                                "Sisa", Utils.formatNumber(dataList["SISA"]),
                                                isRight: true),
                                            Utils.labelDuoSetter("Harga Pokok",
                                                Utils.formatNumber(dataList["HARGA_POKOK"]),
                                                isRight: true, bold: true),
                                            Utils.labelDuoSetter("Harga Jual",
                                                Utils.formatNumber(dataList["HARGA_JUAL"]),
                                                isRight: true, bold: true)
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Mutasi Barang"),
        actions: [
          IconButton(
              onPressed: () {
                dateBottomModal(context);
              },
              icon: Icon(Icons.date_range))
        ],
      ),
      body: Container(
        child: setListFutureBuilder(),
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
                  _dataMutasiDetail =
                      getDetail(tglDari: tanggalDariCtrl.text, tglHingga: tanggalHinggaCtrl.text);
                });
              });
        });
  }
}
