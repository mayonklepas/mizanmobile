import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListPenerimaan extends StatefulWidget {
  const ListPenerimaan({Key? key}) : super(key: key);

  @override
  State<ListPenerimaan> createState() => _ListPenerimaanState();
}

class _ListPenerimaanState extends State<ListPenerimaan> {
  Future<List<dynamic>>? _dataPenerimaan;

  Future<List<dynamic>> _getDataPenerimaan({String keyword = ""}) async {
    Uri url = Uri.parse(
        "${Utils.mainUrl}penerimaan/daftar?iddept=1&tgldari=2023-01-01&tglhingga=2023-01-31");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}penerimaan/cari?iddept=1&tgldari=2023-01-01&tglhingga=2023-01-31&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    print(url.toString());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonDecode(response.body));
    return jsonData;
  }

  @override
  void initState() {
    _dataPenerimaan = _getDataPenerimaan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenerimaan,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext contex, int index) {
                List? dataList = snapshot.data!;
                return Container(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Utils.bagde((index + 1).toString()),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dataList[index]["NOREF"],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Padding(padding: EdgeInsets.all(1)),
                                  Text(dataList[index]["NAMA_SUPLIER"],
                                      style: TextStyle(fontSize: 10)),
                                  Padding(padding: EdgeInsets.all(3)),
                                  Text(
                                    Utils.formatRp(dataList[index]["TOTAL_PEMBELIAN"]),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      Utils.formatDate(dataList[index]["TANGGAL"]),
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
              });
        }
      }),
    );
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Daftar Penerimaan");
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
                        _dataPenerimaan = _getDataPenerimaan(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Penerimaan");
                  }
                });
              },
              icon: customIcon)
        ],
      ),
      body: Container(
        child: setListFutureBuilder(),
      ),
    );
  }
}
