import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penjualan/input_penjualan.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../component/bottom_modal_filter.dart';

class ListPenjualan extends StatefulWidget {
  const ListPenjualan({Key? key}) : super(key: key);

  @override
  State<ListPenjualan> createState() => _ListPenjualanState();
}

class _ListPenjualanState extends State<ListPenjualan> {
  Future<List<dynamic>>? _dataPenjualan;
  dynamic _dataMastePenjualan;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataPenjualan(
      {String keyword = "",
      String tglDari = "",
      String tglHingga = "",
      String idDept = "",
      String idPengguna = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.formatStdDate(DateTime.now());
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
        "${Utils.mainUrl}penjualan/daftar?idpengguna=$idPengguna&iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}penjualan/cari?idpengguna=$idPengguna&iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    _dataMastePenjualan = await jsonData["header"];
    return jsonData["detail"];
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataPenjualan = _getDataPenjualan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenjualan,
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
                            "${Utils.formatDate(_dataMastePenjualan["TANGGAL_DARI"])} - ${Utils.formatDate(_dataMastePenjualan["TANGGAL_HINGGA"])}",
                            isRight: true),
                        Utils.labelDuoSetter("Department", Utils.namaDeptTemp, isRight: true),
                        Utils.labelDuoSetter("Bagian Penjualan", Utils.namaPenggunaTemp,
                            isRight: true),
                        Utils.labelDuoSetter("Total Penjualan Tunai",
                            Utils.formatNumber(_dataMastePenjualan["TOTAL_PENJUALAN_TUNAI"]),
                            isRight: true),
                        Utils.labelDuoSetter("Total Penjualan Kredit",
                            Utils.formatNumber(_dataMastePenjualan["TOTAL_PENJUALAN_KREDIT"]),
                            isRight: true)
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
                                          dataList["NOREF"],
                                          bold: true,
                                        ),
                                        Utils.labelSetter(dataList["NAMA_PELANGGAN"]),
                                        Utils.labelSetter(dataList["KETERANGAN"]),
                                        Utils.labelSetter(dataList["BAGIAN_PENJUALAN"]),
                                        Utils.labelSetter(
                                            Utils.formatRp(dataList["TOTAL_PENJUALAN"]),
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
  Widget customSearchBar = Text("Daftar Penjualan");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (contenxt) {
            return InputPenjualan();
          }));
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
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
                        _dataPenjualan = _getDataPenjualan(
                            keyword: keyword,
                            tglDari: tanggalDariCtrl.text,
                            tglHingga: tanggalHinggaCtrl.text);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Penjualan");
                  }
                });
              },
              icon: customIcon),
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
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar Penjualan");
              _dataPenjualan = _getDataPenjualan();
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
                  _dataPenjualan = _getDataPenjualan(
                      tglDari: tanggalDariCtrl.text,
                      tglHingga: tanggalHinggaCtrl.text,
                      idDept: Utils.idDeptTemp,
                      idPengguna: Utils.idPenggunaTemp);
                });
              });
        });
  }
}
