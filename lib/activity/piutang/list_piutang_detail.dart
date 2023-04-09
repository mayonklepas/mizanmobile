import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/piutang/list_piutang_pembayaran.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListPiutangDetail extends StatefulWidget {
  final String idPelanggan;

  const ListPiutangDetail({Key? key, required this.idPelanggan});

  @override
  State<ListPiutangDetail> createState() => _ListPiutangDetailState();
}

class _ListPiutangDetailState extends State<ListPiutangDetail> {
  Future<List<dynamic>>? _dataPiutangDetail;

  Future<List<dynamic>> _getDataPiutangDetail({String keyword = ""}) async {
    Uri url = Uri.parse("${Utils.mainUrl}piutang/detail?idpelanggan=${widget.idPelanggan}");
    if (keyword != null && keyword != "") {
      url = Uri.parse(
          "${Utils.mainUrl}piutang/detail/cari?idpelanggan=${widget.idPelanggan}&cari=$keyword");
    }
    Response response = await get(url, headers: Utils.setHeader());
    print(url.toString());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    return jsonData;
  }

  @override
  void initState() {
    _dataPiutangDetail = _getDataPiutangDetail();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPiutangDetail,
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
                            return ListPiutangPembayaran(
                                idPiutangDetail: dataList["NOINDEX"], noref: dataList["NOREF"]);
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
                                    Container(
                                        child: Table(
                                      defaultColumnWidth: FlexColumnWidth(),
                                      children: [
                                        Utils.labelDuoSetter("Jatuh Tempo",
                                            Utils.formatDate(dataList["JATUH_TEMPO"])),
                                        Utils.labelDuoSetter(
                                            "Total", Utils.formatRp(dataList["TOTAL_HUTANG"]),
                                            isRight: true),
                                        Utils.labelDuoSetter(
                                            "Cicilan", Utils.formatRp(dataList["TOTAL_CICILAN"]),
                                            isRight: true),
                                        Utils.labelDuoSetter(
                                            "Sisa", Utils.formatRp(dataList["SISA_HUTANG"]),
                                            isRight: true, bold: true)
                                      ],
                                    )),
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
  Widget customSearchBar = Text("Daftar Piutang Detail");
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
                        _dataPiutangDetail = _getDataPiutangDetail(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Piutang Detail");
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
              customSearchBar = Text("Daftar Piutang Detail");
              _dataPiutangDetail = _getDataPiutangDetail();
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
