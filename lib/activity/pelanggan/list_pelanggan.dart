import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListPelanggan extends StatefulWidget {
  const ListPelanggan({Key? key}) : super(key: key);

  @override
  State<ListPelanggan> createState() => _ListPelangganState();
}

class _ListPelangganState extends State<ListPelanggan> {
  Future<List<dynamic>>? _dataPelanggan;

  Future<List<dynamic>> _getDataPelanggan({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}pelanggan/daftar");
    if (keyword != "") {
      url = Uri.parse("${Utils.mainUrl}pelanggan/cari?cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    return jsonData;
  }

  @override
  void initState() {
    _dataPelanggan = _getDataPelanggan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPelanggan,
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
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Utils.bagde(
                            dataList["NAMA"].toString().substring(0, 1),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.labelSetter(dataList["NAMA"], bold: true),
                                  Table(
                                    defaultColumnWidth: FlexColumnWidth(),
                                    children: [
                                      Utils.labelDuoSetter("Kode", dataList["KODE_GOL"],
                                          isRight: true),
                                      Utils.labelDuoSetter("Golongan", dataList["KODE_GOL"],
                                          isRight: true),
                                      Utils.labelDuoSetter(
                                          "Klasifikasi", dataList["NAMA_KLASIFIKASI"],
                                          isRight: true)
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
                );
              });
        }
      }),
    );
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Daftar Pelanggan");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {},
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
                        _dataPelanggan = _getDataPelanggan(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Pelanggan");
                  }
                });
              },
              icon: customIcon)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar Pelanggan");
              _dataPelanggan = _getDataPelanggan();
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
