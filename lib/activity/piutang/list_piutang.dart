import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/piutang/list_piutang_detail.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListPiutang extends StatefulWidget {
  const ListPiutang({Key? key}) : super(key: key);

  @override
  State<ListPiutang> createState() => _ListPiutangState();
}

class _ListPiutangState extends State<ListPiutang> {
  Future<List<dynamic>>? _dataPiutang;

  Future<List<dynamic>> _getDataPiutang({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}piutang/daftar?iddept=${Utils.idDept}");
    if (keyword != null && keyword != "") {
      url = Uri.parse("${Utils.mainUrl}piutang/cari?iddept=${Utils.idDept}&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    var jsonData = jsonDecode(response.body)["data"];
    log(jsonData.toString());
    return jsonData;
  }

  @override
  void initState() {
    _dataPiutang = _getDataPiutang();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPiutang,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext contex, int index) {
                dynamic dataList = snapshot.data![index];
                return Container(
                  child: InkWell(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListPiutangDetail(
                                idPelanggan: dataList["NOINDEX"].toString(),
                              );
                            },
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Utils.bagde((dataList["NAMA"]).substring(0, 1)),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Utils.labelSetter(dataList["NAMA"], bold: true),
                                      Utils.labelSetter(dataList["DEPTNAME"]),
                                      Utils.labelValueSetter(
                                          "Total", Utils.formatNumber(dataList["TOTAL_HUTANG"]),
                                          boldValue: true),
                                      Utils.labelValueSetter(
                                          "Cicilan", Utils.formatNumber(dataList["TOTAL_CICILAN"]),
                                          boldValue: true),
                                      Utils.labelValueSetter(
                                          "Sisa", Utils.formatNumber(dataList["SISA_HUTANG"]),
                                          boldValue: true),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
  Widget customSearchBar = Text("Daftar Piutang");
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
                        _dataPiutang = _getDataPiutang(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Piutang");
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
              customSearchBar = Text("Daftar Piutang");
              _dataPiutang = _getDataPiutang();
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
