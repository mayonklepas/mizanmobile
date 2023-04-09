import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListHutangPembayaran extends StatefulWidget {
  final String idHutangDetail;
  final String noref;

  const ListHutangPembayaran({Key? key, required this.idHutangDetail, required this.noref});

  @override
  State<ListHutangPembayaran> createState() => _ListHutangPembayaranState();
}

class _ListHutangPembayaranState extends State<ListHutangPembayaran> {
  Future<List<dynamic>>? _dataHutangPembayaran;

  Future<List<dynamic>> _getDataHutangPembayaran() async {
    Uri url =
        Uri.parse("${Utils.mainUrl}piutang/detail/pembayaran?idgenjur=${widget.idHutangDetail}");
    Response response = await get(url, headers: Utils.setHeader());
    print(url.toString());
    var jsonData = jsonDecode(response.body)["data"];
    print(jsonData);
    return jsonData;
  }

  @override
  void initState() {
    _dataHutangPembayaran = _getDataHutangPembayaran();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataHutangPembayaran,
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
                                    Container(
                                        child: Table(
                                      defaultColumnWidth: FlexColumnWidth(),
                                      children: [
                                        Utils.labelDuoSetter("Jumlah Bayar",
                                            Utils.formatRp(dataList["TOTAL_CICILAN"]),
                                            bold: true, isRight: true),
                                      ],
                                    )),
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
              _dataHutangPembayaran = _getDataHutangPembayaran();
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
