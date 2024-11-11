import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penjualan/input_penjualan.dart';
import 'package:mizanmobile/activity/penjualan/list_penjualan_offline.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../../helper/database_helper.dart';
import '../utility/bottom_modal_filter.dart';
import '../utility/printer_util.dart';
import 'input_order_penjualan.dart';

class ListOrderPenjualan extends StatefulWidget {
  const ListOrderPenjualan({Key? key}) : super(key: key);

  @override
  State<ListOrderPenjualan> createState() => _ListOrderPenjualanState();
}

class _ListOrderPenjualanState extends State<ListOrderPenjualan> {
  Future<List<dynamic>>? _dataOrderPenjualan;
  dynamic _dataMasteOrderPenjualan;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataOrderPenjualan(
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
        "${Utils.mainUrl}orderpenjualan/daftar?idpengguna=$idPengguna&iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}orderpenjualan/cari?idpengguna=$idPengguna&iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    log(jsonData.toString());
    _dataMasteOrderPenjualan = await jsonData["header"];
    List<dynamic> detailOrderPenjualan = jsonData["detail"];
    return detailOrderPenjualan;
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataOrderPenjualan = _getDataOrderPenjualan();
    super.initState();
  }

  _printStruck(noindex) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}orderpenjualan/rincian?noindex=${noindex}";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    Map result = jsonDecode(response.body);
    if (result["status"] == 1) {
      Navigator.pop(context);
      Utils.showMessage(result["message"], context);
      return;
    }
    Map data = result["data"];
    dynamic headerData = data["header"][0];

    String idPelanggan = headerData["IDPELANGGAN"];
    String kodePelanggan = headerData["KODEPELANGGAN"];
    String namaPelanggan = headerData["NAMAPELANGGAN"];
    double jumlahBayar = headerData["JUMLAHBAYAR"] ?? 0.0;
    String idUserInput = headerData["USERINPUT"];
    String namaKasir = headerData["NAMAKASIR"];
    String idGudang = "";
    String tanggal = headerData["TANGGAL"];
    int isTunai = headerData["ISTUNAI"];
    double uangMuka = headerData["TOTALUANGMUKA"];
    String noref = headerData["NOREF"];
    List<dynamic> dataListPrint = [];

    List<dynamic> detailBarang = data["detail"];

    double totalBelanja = 0;

    for (var d in detailBarang) {
      String idBarang = d["IDBARANG"].toString();
      List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
          "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =?",
          params: [idBarang]);

      dynamic detailBarang = listDetailBarang[0];
      dynamic resultDataDetail = {
        "detail_barang": jsonDecode(detailBarang["detail_barang"]),
        "multi_satuan": jsonDecode(detailBarang["multi_satuan"]),
        "multi_harga": jsonDecode(detailBarang["multi_harga"]),
        "harga_tanggal": jsonDecode(detailBarang["harga_tanggal"]),
      };

      dataListPrint.add({
        "IDBARANG": d["IDBARANG"].toString(),
        "KODE": d["KODEBARANG"],
        "NAMA": d["NAMABARANG"],
        "IDSATUAN": d["IDSATUAN"],
        "SATUAN": d["KODESATUAN"],
        "QTY": d["QTY"],
        "HARGA": d["HARGA"],
        "DISKONNOMINAL": d["DISKONNOMINAL"],
        "IDGUDANG": d["IDGUDANG"],
        "IDSATUANPENGALI": d["IDSATUANPENGALI"],
        "QTYSATUANPENGALI": d["QTYSATUANPENGALI"],
        "KETERANGAN": d["KETERANGAN"] ?? "",
      });
    }

    dynamic additionalInfo = {
      "kreditOrTunai": (isTunai == 0) ? "Tunai" : "Kredit",
      "totalUangMuka": uangMuka,
      "tanggal": tanggal,
      "kodePelanggan": kodePelanggan,
      "namaPelanggan": namaPelanggan,
      "kasir": namaKasir,
      "noref": noref,
      "jumlahUang": jumlahBayar
    };

    Map<String, String> printResult =
        await PrinterUtils().printReceipt(dataListPrint, additionalInfo);
    Navigator.pop(context);
    if (printResult["status"] == "error") {
      Utils.showMessage(printResult["message"]!, context);
      return;
    }
  }

  Future<dynamic> _deleteOrderPenjualan(paramnoindex) async {
    dynamic postBody = {"noindex": paramnoindex};
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}orderpenjualan/delete";
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> showOption(noindex) {
    return showModalBottomSheet(
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
                        onPressed: () async {
                          _printStruck(noindex);
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.print,
                          color: Colors.black54,
                        )),
                    Text("Print Struk")
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (Utils.hakAkses["MOBILE_EDITPENJUALAN"] == 0) {
                            return Utils.showMessage("Akses ditolak", context);
                          }

                          await Navigator.push(context, MaterialPageRoute(builder: (contenxt) {
                            return InputPenjualan(idTransaksi: noindex);
                          }));
                          setState(() {
                            _dataOrderPenjualan = _getDataOrderPenjualan();
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
                          if (Utils.hakAkses["MOBILE_EDITPENJUALAN"] == 0) {
                            return Utils.showMessage("Akses ditolak", context);
                          }

                          bool isDelete = await Utils.showConfirmMessage(
                              context, "ingin menghapus penjualan ini ");
                          if (isDelete) {
                            dynamic result = await _deleteOrderPenjualan(noindex);

                            if (result["status"] == 1) {
                              Utils.showMessage(result["message"], context);
                              return;
                            }

                            List<dynamic> detailBarang = result["data"]["detail_barang"];

                            for (var d in detailBarang) {
                              List<dynamic> lsDetailBarang = await new DatabaseHelper()
                                  .readDatabase(
                                      "SELECT detail_barang FROM barang_temp WHERE idbarang = ? ",
                                      params: [d["IDBARANG"].toString()]);

                              dynamic detailBarang = jsonDecode(lsDetailBarang[0]["detail_barang"]);
                              detailBarang["STOK"] = d["STOK"];

                              String detailBarangStr = jsonEncode(detailBarang);

                              await new DatabaseHelper().writeDatabase(
                                  "UPDATE barang_temp SET detail_barang = ? WHERE idbarang =?",
                                  params: [detailBarangStr, d["IDBARANG"]]);
                            }

                            setState(() {
                              _dataOrderPenjualan = _getDataOrderPenjualan();
                            });
                          }
                          Navigator.pop(context);
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
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataOrderPenjualan,
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
                        Utils.labelValueSetter("Periode",
                            "${Utils.formatDate(_dataMasteOrderPenjualan["TANGGAL_DARI"])} - ${Utils.formatDate(_dataMasteOrderPenjualan["TANGGAL_HINGGA"])}"),
                        Utils.labelValueSetter("Department", Utils.namaDeptTemp),
                        Utils.labelValueSetter(
                          "Bagian Penjualan",
                          Utils.namaPenggunaTemp,
                        ),
                        Utils.labelValueSetter("Total Order Penjualan",
                            Utils.formatNumber(_dataMasteOrderPenjualan["TOTAL_ORDER_PENJUALAN"]),
                            boldValue: true)
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
                            onTap: () {
                              showOption(dataList["NOINDEX"]);
                            },
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
                                          Utils.labelSetter(
                                              dataList["BAGIAN_PENJUALAN"].toString()),
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
  Widget customSearchBar = Text("Daftar Order Penjualan");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (contenxt) {
            return InputOrderPenjualan();
          }));

          setState(() {
            _dataOrderPenjualan = _getDataOrderPenjualan();
          });
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
                        _dataOrderPenjualan = _getDataOrderPenjualan(
                            keyword: keyword,
                            tglDari: tanggalDariCtrl.text,
                            tglHingga: tanggalHinggaCtrl.text);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Order Penjualan");
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
              customSearchBar = Text("Daftar Order Penjualan");
              _dataOrderPenjualan = _getDataOrderPenjualan();
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
                  _dataOrderPenjualan = _getDataOrderPenjualan(
                      tglDari: tanggalDariCtrl.text,
                      tglHingga: tanggalHinggaCtrl.text,
                      idDept: Utils.idDeptTemp,
                      idPengguna: Utils.idPenggunaTemp);
                });
              });
        });
  }
}
