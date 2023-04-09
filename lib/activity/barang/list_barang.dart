import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListBarang extends StatefulWidget {
  const ListBarang({Key? key}) : super(key: key);

  @override
  State<ListBarang> createState() => _ListBarangState();
}

class _ListBarangState extends State<ListBarang> {
  Future<List<dynamic>>? _dataBarang;
  String mainUrlString = "${Utils.mainUrl}barang/daftar?idgudang=1-1&halaman=0";
  String cariUrlString = "${Utils.mainUrl}barang/cari?idgudang=1-1&cari=";

  Future<List<dynamic>> _getDataBarang({String keyword = ""}) async {
    Uri url = Uri.parse(mainUrlString);
    if (keyword != null && keyword != "") {
      url = Uri.parse(cariUrlString + keyword);
    }
    Response response = await get(url, headers: Utils.setHeader());
    print(jsonDecode(response.body));
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData;
  }

  @override
  void initState() {
    _dataBarang = _getDataBarang();
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
                        showModalBottomSheet(
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
                                            onPressed: () {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) {
                                                  return InputBarang(
                                                    idBarang: dataList["NOINDEX"],
                                                  );
                                                },
                                              ));
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
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.black54,
                                            )),
                                        Text("Delete")
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.autorenew,
                                              color: Colors.black54,
                                            )),
                                        Text("Mutasi")
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
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
                                        Utils.labelSetter(Utils.formatRp(dataList["HARGA_JUAL"]),
                                            bold: true),
                                        Utils.labelSetter("Stok : " +
                                            Utils.formatNumber(dataList["STOK"]) +
                                            " " +
                                            dataList["KODE_SATUAN"]),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return InputBarang(
                idBarang: "",
              );
            },
          ));
        },
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
          IconButton(
              onPressed: () async {
                String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                    "#ff6666", "Cancel", true, ScanMode.BARCODE);

                if (barcodeScanRes == "-1") return;
                setState(() {
                  _dataBarang = _getDataBarang(keyword: barcodeScanRes);
                });
              },
              icon: Icon(Icons.qr_code_scanner))
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
