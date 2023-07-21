import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penjualan/input_penjualan.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../../component/bottom_modal_filter.dart';

class ListPenjualanBulanan extends StatefulWidget {
  const ListPenjualanBulanan({Key? key}) : super(key: key);

  @override
  State<ListPenjualanBulanan> createState() => _ListPenjualanBulananState();
}

class _ListPenjualanBulananState extends State<ListPenjualanBulanan> {
  Future<List<dynamic>>? _dataPenjualanBulanan;
  dynamic _dataMastePenjualanBulanan;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataPenjualanBulanan(
      {String tglDari = "",
      String tglHingga = "",
      String idDept = "",
      String idPengguna = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.fisrtDateOfMonthString();
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    if (idDept == "") {
      idDept = Utils.idDeptTemp;
    }

    if (idPengguna == "") {
      idPengguna = Utils.idPenggunaTemp;
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}home/penjualanbulanan?idpengguna=$idPengguna&iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    _dataMastePenjualanBulanan = await jsonData["header"];
    return jsonData["detail"];
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataPenjualanBulanan = _getDataPenjualanBulanan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenjualanBulanan,
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
                    child: Table(
                      defaultColumnWidth: FlexColumnWidth(),
                      children: [
                        Utils.labelDuoSetter("Periode",
                            "${Utils.formatDate(_dataMastePenjualanBulanan["TANGGAL_DARI"])} - ${Utils.formatDate(_dataMastePenjualanBulanan["TANGGAL_HINGGA"])}",
                            isRight: true),
                        Utils.labelDuoSetter("Department", Utils.namaDeptTemp, isRight: true),
                        Utils.labelDuoSetter("Bagian Penjualan", Utils.namaPenggunaTemp,
                            isRight: true),
                        Utils.labelDuoSetter("Total Penjualan Tunai",
                            Utils.formatNumber(_dataMastePenjualanBulanan["TOTAL_PENJUALAN_TUNAI"]),
                            isRight: true, bold: true, size: 15),
                        Utils.labelDuoSetter(
                            "Total Penjualan Kredit",
                            Utils.formatNumber(
                                _dataMastePenjualanBulanan["TOTAL_PENJUALAN_KREDIT"]),
                            isRight: true,
                            bold: true,
                            size: 15)
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
                                Utils.bagde((index + 1).toString()),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Utils.labelSetter(
                                          dataList["TIPE_PENJUALAN"],
                                          bold: true,
                                        ),
                                        Utils.labelSetter(dataList["BAGIAN_PENJUALAN"]),
                                        Utils.labelSetter(
                                            Utils.formatNumber(dataList["TOTAL_PENJUALAN"]),
                                            bold: true),
                                        Container(
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
  Widget customSearchBar = Text("Daftar Penjualan Bulanan");
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
              customSearchBar = Text("Daftar Penjualan Bulanan");
              _dataPenjualanBulanan = _getDataPenjualanBulanan();
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
              isDept: true,
              isPengguna: true,
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  _dataPenjualanBulanan = _getDataPenjualanBulanan(
                      tglDari: tanggalDariCtrl.text,
                      tglHingga: tanggalHinggaCtrl.text,
                      idDept: Utils.idDeptTemp,
                      idPengguna: Utils.idPenggunaTemp);
                });
              });
        });
  }
}
