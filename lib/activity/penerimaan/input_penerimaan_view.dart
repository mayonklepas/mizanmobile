import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/penerimaan/input_penerimaan_controller.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class InputPenerimaanView extends StatefulWidget {
  final String idTransaksi;
  const InputPenerimaanView({Key? key, this.idTransaksi = ""})
      : super(key: key);

  @override
  State<InputPenerimaanView> createState() => _InputPenerimaanViewState();
}

class _InputPenerimaanViewState extends State<InputPenerimaanView> {
  late InputPenerimaanController ctrl;

  @override
  void initState() {
    ctrl = InputPenerimaanController(context, setState, widget.idTransaksi);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: ctrl.setSearchBarView(),
          actions: [
            IconButton(
                onPressed: () => ctrl.scanBarcode(),
                icon: Icon(Icons.qr_code_scanner_rounded)),
            IconButton(
                onPressed: () => ctrl.showHeader(),
                icon: Icon(Icons.note_add_rounded))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 0,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.black,
                  width: 0.10,
                ))),
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: Text("Suplier")),
                        Expanded(
                            flex: 1,
                            child: Text(
                              ctrl.namaSuplier,
                              textAlign: TextAlign.end,
                            )),
                        Expanded(
                            flex: 0,
                            child: IconButton(                               
                                alignment: Alignment.centerRight,
                                onPressed: () => ctrl.getSuplier(),
                                icon: Icon(Icons.search)))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: Text("No Order")),
                        Expanded(
                            flex: 2,
                            child: Text(
                              ctrl.noOrder,
                              textAlign: TextAlign.end,
                            )),
                        Expanded(
                            flex: 0,
                            child: IconButton(
                                alignment: Alignment.centerRight,
                                onPressed: () => ctrl.getOrder(),
                                icon: Icon(Icons.search)))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: ListView.builder(
                    itemCount: ctrl.dataListShow.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic data = ctrl.dataListShow[index];
                      return Container(
                        child: Card(
                          child: InkWell(
                            onTap: () => ctrl.showEdit(data,index),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.bagde((index + 1).toString()),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Utils.labelSetter(data["NAMA"],
                                              bold: true),
                                          Utils.labelSetter(data["KODE"]),
                                          Utils.labelSetter(
                                              Utils.formatNumber(data["HARGA"]),
                                              bold: true),
                                          Utils.labelValueSetter(
                                              "QTY ORDER",
                                              Utils.formatDate(
                                                  data["QTY_ORDER"])),
                                          Utils.labelSetter(
                                              Utils.formatNumber(data["HARGA"]),
                                              bold: true),
                                          Utils.labelValueSetter("QTY",
                                              Utils.formatDate(data["QTY"])),
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
                    })),
            Expanded(
                flex: 0,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                    color: Colors.black,
                    width: 0.15,
                  ))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, bottom: 15, top: 5),
                        child: Utils.labelValueSetter(
                            "Total", Utils.formatNumber("0"),
                            sizeLabel: 18, sizeValue: 18, boldValue: true),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () =>ctrl.sendPayment(),
                          child:
                              Utils.labelSetter("SIMPAN", color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }
}
