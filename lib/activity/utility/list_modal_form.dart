import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListModalForm extends StatefulWidget {
  final String type;
  final String idBarang;
  final String keyword;
  final bool isExtra;
  final bool withAll;
  const ListModalForm(
      {Key? key,
      required this.type,
      this.idBarang = "",
      this.keyword = "",
      this.isExtra = false,
      this.withAll = false});

  @override
  State<ListModalForm> createState() => _ListModalFormState();
}

class _ListModalFormState extends State<ListModalForm> {
  Future<List<dynamic>>? _dataModal;

  Future<List<dynamic>> _getDataModal({String keyword = ""}) async {
    String mainUrlString = "";

    String type = widget.type;

    if (type == "satuan") {
      mainUrlString = "${Utils.mainUrl}datapopup/satuan?cari=";
    } else if (type == "kelompokbarang") {
      mainUrlString = "${Utils.mainUrl}datapopup/kelompokbarang?cari=";
    } else if (type == "suplier") {
      mainUrlString = "${Utils.mainUrl}datapopup/suplier?cari=";
    } else if (type == "merk") {
      mainUrlString = "${Utils.mainUrl}datapopup/merek?cari=";
    } else if (type == "satuan") {
      mainUrlString = "${Utils.mainUrl}datapopup/satuan?cari";
    } else if (type == "gudang") {
      mainUrlString = "${Utils.mainUrl}datapopup/gudang?cari=";
    } else if (type == "lokasi") {
      mainUrlString = "${Utils.mainUrl}datapopup/lokasi?cari=";
    } else if (type == "dept") {
      mainUrlString = "${Utils.mainUrl}datapopup/dept?cari";
    } else if (type == "golongan") {
      mainUrlString = "${Utils.mainUrl}datapopup/golongan?cari=";
    } else if (type == "golongansuplier") {
      mainUrlString = "${Utils.mainUrl}datapopup/golongansuplier?cari=";
    } else if (type == "golonganpelanggan") {
      mainUrlString = "${Utils.mainUrl}datapopup/golonganpelanggan?cari=";
    } else if (type == "klasifikasi") {
      mainUrlString = "${Utils.mainUrl}datapopup/klasifikasi?cari=";
    } else if (type == "satuanbarang") {
      mainUrlString =
          "${Utils.mainUrl}datapopup/satuanbarang?idbarang=${widget.idBarang}";
    } else if (type == "akun") {
      mainUrlString = "${Utils.mainUrl}datapopup/akun?cari=";
    } else if (type == "pengguna") {
      mainUrlString = "${Utils.mainUrl}datapopup/pengguna?cari=";
    } else if (type == "pelanggan") {
      mainUrlString = "${Utils.mainUrl}datapopup/pelanggan?cari=";
    } else if (type == "top") {
      mainUrlString = "${Utils.mainUrl}datapopup/top?cari=";
    }
    if (type == "kelompoktransaksi") {
      mainUrlString = "${Utils.mainUrl}datapopup/kelompoktransaksi?cari=";
    }

    Uri url = Uri.parse(mainUrlString + keyword);
    Response response = await get(url, headers: Utils.setHeader());
    List<dynamic> jsonData = jsonDecode(response.body)["data"];
    if (widget.withAll) {
      Map<String, dynamic> map = {
        "NAMA": "SEMUA",
        "KODE": "SEMUA",
        "NOINDEX": "-1"
      };
      jsonData.insert(0, map);
    }
    return jsonData;
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("");

  @override
  void initState() {
    customSearchBar = Text("Data ${widget.type}");
    _dataModal = _getDataModal();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataModal,
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
                            Utils.bagde(Utils.koooosong(dataList["NAMA"])
                                .substring(0, 1)),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(
                                        dataList["NAMA"].toString(),
                                        bold: true),
                                    Utils.labelSetter(
                                        dataList["KODE"].toString())
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
                        _dataModal = _getDataModal(keyword: keyword);
                      });
                    }, hint: "Cari ${widget.type}");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Data " + widget.type);
                  }
                });
              },
              icon: customIcon),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Daftar ${widget.type}");
              _dataModal = _getDataModal();
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
