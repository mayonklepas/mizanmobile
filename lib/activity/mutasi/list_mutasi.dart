import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../component/bottom_modal_filter.dart';

class ListMutasi extends StatefulWidget {
  final String idBarang;
  const ListMutasi({Key? key, required this.idBarang});

  @override
  State<ListMutasi> createState() => _ListMutasiState();
}

class _ListMutasiState extends State<ListMutasi> {
  String idBarangGlobal = "";
  Future<List<dynamic>>? _dataMutasi;
  dynamic? _dataheader;
  Future<List<dynamic>>? _dataMutasiHeader;
  Future<List<dynamic>>? _dataMutasiDetail;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();
  TextEditingController gudangCtrl = TextEditingController();

  Future<List<dynamic>> _getDataMutasi(
      {String tglDari = "",
      String tglHingga = "",
      String idGudang = "",
      String idDept = "",
      String idPengguna = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    if (idGudang == "") {
      idGudang = Utils.idGudangTemp;
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}barang/mutasi?idbarang=${widget.idBarang}&idgudang=$idGudang&tgldari=$tglDari&tglhingga=$tglHingga");
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    _dataheader = await jsonData["header"];
    return jsonData["detail"];
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataMutasiDetail = _getDataMutasi();
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
                        Utils.labelSetter(_dataheader["NAMA"].toString(), bold: true),
                        Utils.labelSetter(_dataheader["KODE"].toString()),
                        SizedBox(height: 3),
                        Utils.labelValueSetter("Periode",
                            "${Utils.formatDate(tanggalDariCtrl.text)} - ${Utils.formatDate(tanggalHinggaCtrl.text)}"),
                        Utils.labelValueSetter(
                          "Satuan",
                          _dataheader["KODE_SATUAN"].toString(),
                        ),
                        Utils.labelValueSetter(
                          "Stok Awal",
                          Utils.formatNumber(_dataheader["STOK_AWAL"]),
                        ),
                        Utils.labelValueSetter(
                          "Masuk",
                          Utils.formatNumber(_dataheader["MASUK"]),
                        ),
                        Utils.labelValueSetter(
                          "Keluar",
                          Utils.formatNumber(_dataheader["KELUAR"]),
                        ),
                        Utils.labelValueSetter(
                            "Stok Akhir", Utils.formatNumber(_dataheader["STOK_AKHIR"]))
                      ],
                    ),
                  )),
              Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext contex, int index) {
                      dynamic dataList = snapshot.data![index];
                      if (dataList == null) {
                        return Container(
                          child: Center(
                            child: Text("Data tidak ada"),
                          ),
                        );
                      }
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
                                        Utils.labelValueSetter(
                                            "Kelompok", dataList["KELOMPOK_TRANS"]),
                                        Utils.labelValueSetter(
                                          "Masuk",
                                          Utils.formatNumber(dataList["MASUK"]),
                                        ),
                                        Utils.labelValueSetter(
                                          "Keluar",
                                          Utils.formatNumber(dataList["KELUAR"]),
                                        ),
                                        Utils.labelValueSetter(
                                          "Sisa",
                                          Utils.formatNumber(dataList["SISA"]),
                                        ),
                                        Utils.labelValueSetter(
                                          "Harga Pokok",
                                          Utils.formatNumber(dataList["HARGA_POKOK"]),
                                        ),
                                        Utils.labelValueSetter(
                                          "Harga Jual",
                                          Utils.formatNumber(dataList["HARGA_JUAL"]),
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
              icon: Icon(Icons.filter_alt)),
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
          return BottomModalFilter(
              tanggalDariCtrl: tanggalDariCtrl,
              tanggalHinggaCtrl: tanggalHinggaCtrl,
              isGudang: true,
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  _dataMutasiDetail = _getDataMutasi(
                      tglDari: tanggalDariCtrl.text,
                      tglHingga: tanggalHinggaCtrl.text,
                      idGudang: Utils.idGudangTemp);
                });
              });
        });
  }
}
