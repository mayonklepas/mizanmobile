import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../../component/bottom_modal_filter.dart';

class ListLabaHarian extends StatefulWidget {
  const ListLabaHarian({Key? key}) : super(key: key);

  @override
  State<ListLabaHarian> createState() => _ListLabaHarianState();
}

class _ListLabaHarianState extends State<ListLabaHarian> {
  Future<List<dynamic>>? _dataLabaHarian;
  dynamic _dataMasteLabaHarian;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataLabaHarian(
      {String tgl = "", String idDept = "", String idPengguna = ""}) async {
    if (tgl == "") {
      tgl = Utils.formatStdDate(DateTime.now());
    }

    if (idDept == "") {
      idDept = Utils.idDeptTemp;
    }

    if (idPengguna == "") {
      idPengguna = Utils.idPenggunaTemp;
    }

    Uri url =
        Uri.parse("${Utils.mainUrl}home/labaharian?idpengguna=$idPengguna&iddept=$idDept&tgl=$tgl");
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    log(jsonData.toString());
    _dataMasteLabaHarian = await jsonData["header"];
    return jsonData["detail"];
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataLabaHarian = _getDataLabaHarian();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataLabaHarian,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(children: [
                      Utils.labelValueSetter("Department", Utils.namaDeptTemp),
                      Utils.labelValueSetter(
                        "Bagian Penjualan",
                        Utils.namaPenggunaTemp,
                      ),
                      Utils.labelValueSetter(
                          "Modal", Utils.formatNumber(_dataMasteLabaHarian["MODAL"]),
                          boldValue: true),
                      Utils.labelValueSetter(
                          "Pendapatan", Utils.formatNumber(_dataMasteLabaHarian["PENDAPATAN"]),
                          boldValue: true),
                      Utils.labelValueSetter(
                          "Keuntungan",
                          Utils.formatNumber(
                              (_dataMasteLabaHarian["PENDAPATAN"] - _dataMasteLabaHarian["MODAL"])),
                          boldValue: true),
                      Utils.labelValueSetter(
                          "Rasio",
                          Utils.formatNumber(
                                  (_dataMasteLabaHarian["PENDAPATAN"] -
                                          _dataMasteLabaHarian["MODAL"]) /
                                      _dataMasteLabaHarian["MODAL"] *
                                      100,
                                  decimalDigit: 2) +
                              "%",
                          boldValue: true)
                    ]),
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
                                Utils.bagde((index + 1).toString()),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Utils.labelSetter(
                                          dataList["NAMA"],
                                          bold: true,
                                        ),
                                        Utils.labelSetter(dataList["KODE"]),
                                        Utils.labelValueSetter("Kelompok", dataList["KELOMPOK"]),
                                        Utils.labelValueSetter("Department", dataList["NAMA_DEPT"]),
                                        Utils.labelValueSetter(
                                            "Modal", Utils.formatNumber(dataList["MODAL"]),
                                            boldValue: true),
                                        Utils.labelValueSetter("Pendapatan",
                                            Utils.formatNumber(dataList["PENDAPATAN"]),
                                            boldValue: true),
                                        Utils.labelValueSetter(
                                            "Keuntungan",
                                            Utils.formatNumber(
                                                (dataList["PENDAPATAN"] - dataList["MODAL"])),
                                            boldValue: true),
                                        Utils.labelValueSetter(
                                            "Rasio",
                                            Utils.formatNumber(
                                                    (dataList["PENDAPATAN"] - dataList["MODAL"]) /
                                                        dataList["MODAL"] *
                                                        100,
                                                    decimalDigit: 2) +
                                                "%",
                                            boldValue: true)
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
  Widget customSearchBar = Text("Daftar Laba Harian");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
              onPressed: () {
                dateBottomModal(context);
              },
              icon: Icon(Icons.filter_list_alt))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customSearchBar = Text("Daftar Laba Harian");
              _dataLabaHarian = _getDataLabaHarian();
              tanggalDariCtrl.text = "";
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
              isDept: true,
              isPengguna: true,
              isSingleDate: true,
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  _dataLabaHarian = _getDataLabaHarian(
                      tgl: tanggalDariCtrl.text,
                      idDept: Utils.idDeptTemp,
                      idPengguna: Utils.idPenggunaTemp);
                });
              });
        });
  }
}
