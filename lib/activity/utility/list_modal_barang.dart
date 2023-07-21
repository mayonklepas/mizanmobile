import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListModalBarang extends StatefulWidget {
  final String keyword;
  final String barangList;
  const ListModalBarang({Key? key, this.keyword = "", this.barangList = ""}) : super(key: key);

  @override
  State<ListModalBarang> createState() => _ListModalBarangState();
}

class _ListModalBarangState extends State<ListModalBarang> {
  Future<List<dynamic>>? _dataBarang;

  Future<List<dynamic>> _getDataBarang({String keyword = ""}) async {
    if (widget.barangList != "") {
      return jsonDecode(widget.barangList);
    }
    String mainUrlString =
        "${Utils.mainUrl}barang/caribarangjual?idgudang=${Utils.idGudang}&cari=" + keyword;
    Uri url = Uri.parse(mainUrlString);
    Response response = await get(url, headers: Utils.setHeader());
    print(mainUrlString);
    print(jsonDecode(response.body));
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
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
                                        Utils.labelSetter(Utils.formatNumber(dataList["HARGA_JUAL"]),
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
  Widget customSearchBar = Text("Data Barang");
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
                        _dataBarang = _getDataBarang(keyword: keyword);
                      });
                    }, hint: "Cari Barang");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Data Barang");
                  }
                });
              },
              icon: customIcon),
          IconButton(onPressed: () {}, icon: Icon(Icons.qr_code_scanner))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar Barang");
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
