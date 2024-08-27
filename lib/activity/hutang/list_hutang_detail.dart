import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/hutang/list_hutang_pembayaran.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

class ListHutangDetail extends StatefulWidget {
  final String idSuplier;

  const ListHutangDetail({Key? key, required this.idSuplier});

  @override
  State<ListHutangDetail> createState() => _ListHutangDetailState();
}

class _ListHutangDetailState extends State<ListHutangDetail> {
  Future<List<dynamic>>? _dataHutangDetail;

  Future<List<dynamic>> _getDataHutangDetail({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}hutang/detail?idsuplier=${widget.idSuplier}");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}hutang/detail/cari?idsuplier=${widget.idSuplier}&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    return jsonData;
  }

  @override
  void initState() {
    _dataHutangDetail = _getDataHutangDetail();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataHutangDetail,
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
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ListHutangPembayaran(
                                idHutangDetail: dataList["NOINDEX"], noref: dataList["NOREF"]);
                          },
                        ));
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
                                    Utils.labelSetter(dataList["NOREF"], bold: true),
                                    Utils.labelSetter(dataList["DEPTNAME"], bold: true),
                                    Utils.labelValueSetter(
                                        "Jatuh Tempo", Utils.formatDate(dataList["JATUH_TEMPO"])),
                                    Utils.labelValueSetter(
                                        "Total", Utils.formatNumber(dataList["TOTAL_HUTANG"]),
                                        boldValue: true),
                                    Utils.labelValueSetter(
                                        "Cicilan", Utils.formatNumber(dataList["TOTAL_CICILAN"]),
                                        boldValue: true),
                                    Utils.labelValueSetter(
                                        "Sisa", Utils.formatNumber(dataList["SISA_HUTANG"]),
                                        boldValue: true),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      alignment: Alignment.bottomRight,
                                      child:
                                          Utils.labelSetter(Utils.formatDate(dataList["TANGGAL"])),
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
  Widget customSearchBar = Text("Daftar Hutang Detail");
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
                        _dataHutangDetail = _getDataHutangDetail(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Hutang Detail");
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
              customSearchBar = Text("Daftar Hutang Detail");
              _dataHutangDetail = _getDataHutangDetail();
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
