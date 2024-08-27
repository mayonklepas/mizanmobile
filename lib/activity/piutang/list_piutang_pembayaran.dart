import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

class ListPiutangPembayaran extends StatefulWidget {
  final String idPiutangDetail;
  final String noref;

  const ListPiutangPembayaran({Key? key, required this.idPiutangDetail, required this.noref});

  @override
  State<ListPiutangPembayaran> createState() => _ListPiutangPembayaranState();
}

class _ListPiutangPembayaranState extends State<ListPiutangPembayaran> {
  Future<List<dynamic>>? _dataPiutangPembayaran;

  Future<List<dynamic>> _getDataPiutangPembayaran() async {
    Uri url =
        Uri.parse("${Utils.mainUrl}piutang/detail/pembayaran?idgenjur=${widget.idPiutangDetail}");
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData;
  }

  @override
  void initState() {
    _dataPiutangPembayaran = _getDataPiutangPembayaran();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPiutangPembayaran,
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
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Utils.bagde((index + 1).toString().substring(0, 1)),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(dataList["NOREF"], bold: true),
                                    Utils.labelSetter(dataList["KETERANGAN"]),
                                    Utils.labelValueSetter("Jumlah Bayar",
                                        Utils.formatNumber(dataList["TOTAL_CICILAN"]),
                                        boldValue: true),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      alignment: Alignment.bottomRight,
                                      child: Text(Utils.formatDate(dataList["TANGGAL"])),
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
      appBar: AppBar(title: Text("Pembayaran " + widget.noref)),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              _dataPiutangPembayaran = _getDataPiutangPembayaran();
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
