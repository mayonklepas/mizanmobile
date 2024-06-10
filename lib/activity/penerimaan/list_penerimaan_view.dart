import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penerimaan/list_penerimaan_controller.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class ListPenerimaanView extends StatefulWidget {
  const ListPenerimaanView({Key? key}) : super(key: key);

  @override
  State<ListPenerimaanView> createState() => _ListPenerimaanViewState();
}

class _ListPenerimaanViewState extends State<ListPenerimaanView> {
  late listPenerimaanController ctrl;

  @override
  void initState() {
    ctrl = new listPenerimaanController(context, setState);
    ctrl.dataPenerimaan = ctrl.getDataPenerimaan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: ctrl.dataPenerimaan,
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
                                    Utils.formatNumber(dataList[index]["TOTAL_PEMBELIAN"]),
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
      floatingActionButton: Utils.widgetSetter(() {
        /*if (Utils.hakAkses["MOBILE_EDITPENERIMAAN"] == 0) {
          return Container();
        }*/
        return FloatingActionButton(
            child: Icon(
              Icons.add,
              size: 30,
            ),
            onPressed: () => ctrl.showInput());
      }),
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
                        ctrl.dataPenerimaan = ctrl.getDataPenerimaan(
                            keyword: keyword,
                            tglDari: ctrl.tanggalDariCtrl.text,
                            tglHingga: ctrl.tanggalHinggaCtrl.text);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Daftar Penerimaan");
                  }
                });
              },
              icon: customIcon),
          IconButton(onPressed: () => ctrl.dateBottomModal(context), icon: Icon(Icons.date_range))
        ],
      ),
      body: Container(
        child: setListFutureBuilder(),
      ),
    );
  }
}
