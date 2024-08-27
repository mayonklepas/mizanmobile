import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penjualan/input_penjualan.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../../utility/bottom_modal_filter.dart';

class ListPenjualanHarian extends StatefulWidget {
  const ListPenjualanHarian({Key? key}) : super(key: key);

  @override
  State<ListPenjualanHarian> createState() => _ListPenjualanHarianState();
}

class _ListPenjualanHarianState extends State<ListPenjualanHarian> {
  Future<List<dynamic>>? _dataPenjualanHarian;
  dynamic _dataMastePenjualanHarian;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataPenjualanHarian(
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

    Uri url = Uri.parse(
        "${Utils.mainUrl}home/penjualanharian?idpengguna=$idPengguna&iddept=$idDept&tgl=$tgl");
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    _dataMastePenjualanHarian = await jsonData["header"];
    return jsonData["detail"];
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataPenjualanHarian = _getDataPenjualanHarian();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenjualanHarian,
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
                      child: Column(
                        children: [
                          Utils.labelValueSetter(
                            "Tanggal",
                            Utils.formatDate(_dataMastePenjualanHarian["TANGGAL"]),
                          ),
                          Utils.labelValueSetter("Department", Utils.namaDeptTemp),
                          Utils.labelValueSetter(
                            "Bagian Penjualan",
                            Utils.namaPenggunaTemp,
                          ),
                          Utils.labelValueSetter(
                              "Total Penjualan Tunai",
                              Utils.formatNumber(
                                  _dataMastePenjualanHarian["TOTAL_PENJUALAN_TUNAI"]),
                              boldValue: true),
                          Utils.labelValueSetter(
                              "Total Penjualan Kredit",
                              Utils.formatNumber(
                                  _dataMastePenjualanHarian["TOTAL_PENJUALAN_KREDIT"]),
                              boldValue: true),
                        ],
                      ))),
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
                                          dataList["NOREF"],
                                          bold: true,
                                        ),
                                        Utils.labelSetter(dataList["NAMA_PELANGGAN"]),
                                        Utils.labelValueSetter(
                                            "Keterangan", dataList["KETERANGAN"]),
                                        Utils.labelValueSetter("Department", dataList["NAMA_DEPT"]),
                                        Utils.labelValueSetter(
                                            "Bagian Penjualan", dataList["BAGIAN_PENJUALAN"]),
                                        Utils.labelValueSetter("Total Penjualan",
                                            Utils.formatNumber(dataList["TOTAL_PENJUALAN"]),
                                            boldValue: true),
                                        Container(
                                          padding: EdgeInsets.only(top: 10),
                                          alignment: Alignment.bottomRight,
                                          child: Utils.labelSetter(
                                              Utils.formatDate(dataList["TANGGAL"]),
                                              size: 12),
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
  Widget customSearchBar = Text("Daftar Penjualan Harian");
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
              customSearchBar = Text("Daftar Penjualan Harian");
              _dataPenjualanHarian = _getDataPenjualanHarian();
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
                  _dataPenjualanHarian = _getDataPenjualanHarian(
                      tgl: tanggalDariCtrl.text,
                      idDept: Utils.idDeptTemp,
                      idPengguna: Utils.idPenggunaTemp);
                });
              });
        });
  }
}
