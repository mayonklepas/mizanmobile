import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../../database_helper.dart';

class ListModalBarang extends StatefulWidget {
  final String keyword;
  final bool isLocal;
  const ListModalBarang({Key? key, this.keyword = "", this.isLocal = false}) : super(key: key);

  @override
  State<ListModalBarang> createState() => _ListModalBarangState();
}

class _ListModalBarangState extends State<ListModalBarang> {
  Future<List<dynamic>>? _dataBarang;

  Future<List<dynamic>> _getDataBarang({String keyword = ""}) async {
    if (widget.isLocal) {
      List<dynamic> listBarang = await DatabaseHelper()
          .readDatabase("SELECT idbarang,detail_barang FROM barang_temp LIMIT 100");
      if (keyword != "") {
        listBarang = await DatabaseHelper().readDatabase(
            "SELECT idbarang,kode,nama,detail_barang FROM barang_temp WHERE nama LIKE ? LIMIT 100",
            params: ["%$keyword%"]);
      }

      List<dynamic> listBarangSort = List.of(listBarang);

      if (keyword.isNotEmpty) {
        listBarangSort.sort((a, b) {
          int indexA = a["nama"].toString().toLowerCase().indexOf(keyword.toLowerCase());
          int indexB = b["nama"].toString().toLowerCase().indexOf(keyword.toLowerCase());
          return indexA.compareTo(indexB);
        });
      }

      List<dynamic> listBarangContainer = [];
      listBarangSort.forEach((d) => listBarangContainer.add(jsonDecode(d["detail_barang"])));
      return listBarangContainer;
    }

    String mainUrlString =
        "${Utils.mainUrl}barang/caribarangjual?idgudang=${Utils.idGudang}&cari=" + keyword;
    Uri url = Uri.parse(mainUrlString);
    Response response = await get(url, headers: Utils.setHeader());
    log(mainUrlString);
    log(jsonDecode(response.body).toString());
    var jsonData = jsonDecode(response.body)["data"]["item"];
    return jsonData;
  }

  @override
  void initState() {
    _dataBarang = _getDataBarang(keyword: widget.keyword);
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataBarang,
      builder: ((context, snapshot) {
        List<dynamic> snap = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting && widget.isLocal == false) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snap.length,
              itemBuilder: (BuildContext contex, int index) {
                dynamic dataList = snapshot.data![index];
                return Container(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, dataList);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Utils.bagde(dataList["NAMA"].toString().substring(0, 1)),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(dataList["NAMA"], bold: true),
                                    (Utils.labelSetter(dataList["KODE"])),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Utils.labelSetter(
                                            Utils.formatNumber(dataList["HARGA_JUAL"]),
                                            bold: true),
                                        Utils.labelSetter(
                                            "Stok : " + Utils.formatNumber(dataList["STOK"])),
                                      ],
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
              });
        }
      }),
    );
  }

  Icon customIcon = Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Utils.appBarSearchDynamic((keyword) {
          setState(() {
            _dataBarang = _getDataBarang(keyword: keyword);
          });
        }),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.qr_code_scanner))],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              _dataBarang = _getDataBarang();
            });
          });
        },
        child: Container(
          child: setListFutureBuilder(),
        ),
      ),
    );
  }
}
