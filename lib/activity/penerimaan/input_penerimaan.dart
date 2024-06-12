import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class InputPenerimaan extends StatefulWidget {
  final String idTransaksi;
  const InputPenerimaan({super.key, this.idTransaksi = ""});

  @override
  State<InputPenerimaan> createState() => _InputPenerimaanState();
}

class _InputPenerimaanState extends State<InputPenerimaan> {
  List<dynamic> dataListview = [];
  List<dynamic> listOrderBarang = [];

  FocusNode searchBarFocus = FocusNode();
  TextEditingController searchBarctrl = TextEditingController();

  //global var setter
  Map<String, String> suplierData = {"id": "", "code": "", "name": ""};
  Map<String, String> orderData = {"id": "", "code": "", "name": ""};

  Future<List<dynamic>> getRincianOrder(String noindex) async {
    Uri url = Uri.parse("${Utils.mainUrl}penerimaanbarang/rincianorder?noindex=$noindex");
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body)["data"]["detail"];
    return jsonData;
  }

  Future<dynamic> getDataDetailBarang(String idBarang) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/rincian?idgudang=${Utils.idGudang}&halaman=0&idbarang=$idBarang";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    return jsonData;
  }

  gotoModalBarang() async {
    dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ListModalBarang(
          isLocal: true,
        );
      },
    ));

    if (popUpResult == null) return;

    String noIndex = popUpResult["NOINDEX"];

    List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
        "SELECT detail_barang,multi_satuan FROM barang_temp WHERE idbarang =?",
        params: [noIndex]);

    Map<String, dynamic> detailBarang = jsonDecode(listDetailBarang[0]["detail_barang"]);
    List<dynamic> multiSatuan = jsonDecode(listDetailBarang[0]["multi_satuan"]);

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return modalSetQty();
        });

    Map<String, dynamic> dataMapView = {};
    dataMapView["IDBARANG"] = detailBarang["NOINDEX"];
    dataMapView["KODE"] = detailBarang["KODE"];
    dataMapView["NAMA"] = detailBarang["NAMA"];
    dataMapView["QTY"] = detailBarang["QTY"];
    dataMapView["QTYORDER"] = detailBarang["QTYORDER"];
    dataMapView["SATUAN"] = detailBarang["SATUAN"];
    dataMapView["IDSATUAN"] = detailBarang["IDSATUAN"];
    dataMapView["IDSATUANPENGALI"] = detailBarang["IDSATUANPENGALI"];
    dataMapView["QTYSATUANPENGALI"] = detailBarang["QTYSATUANPENGALI"];

    setState(() {
      dataListview.add(dataMapView);
    });
  }

  SingleChildScrollView modalSetQty() {
    TextEditingController satuanCtrl = TextEditingController();
    TextEditingController qtyOrderCtrl = TextEditingController();
    TextEditingController qtyTerimaCtrl = TextEditingController();
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Input QTY", size: 25),
            Padding(padding: EdgeInsets.all(10)),
            Utils.labelForm("Qty Order"),
            TextField(
              controller: qtyOrderCtrl,
            ),
            Utils.labelForm("Qty Terima"),
            TextField(
              controller: qtyTerimaCtrl,
            ),
            Utils.labelForm("Satuan"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: satuanCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "satuanbarang",
                            //idBarang: data["IDBARANG"],
                          );
                        },
                      ));

                      if (popUpResult == null) return;
                      satuanCtrl.text = popUpResult["NAMA"];
                      //idSatuan = popUpResult["NOINDEX"];
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Utils.widgetSetter(() {
          if (Utils.isPdtMode == "0") {
            return Utils.appBarSearchStatic(() => gotoModalBarang(), focus: false, readOnly: true);
          }
          return Container(
              height: 35,
              child: TextField(
                  cursorColor: Colors.blueAccent,
                  style: TextStyle(color: Colors.black54),
                  decoration: Utils.inputDecoration("Cari"),
                  textInputAction: TextInputAction.search,
                  autofocus: true,
                  focusNode: searchBarFocus,
                  controller: searchBarctrl,
                  onSubmitted: (keyword) => {}));
        }),
        actions: [
          IconButton(onPressed: () async {}, icon: Icon(Icons.qr_code_scanner_rounded)),
          IconButton(onPressed: () {}, icon: Icon(Icons.note_add_rounded))
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
                            suplierData["name"] ?? "",
                            textAlign: TextAlign.end,
                          )),
                      Expanded(
                          flex: 0,
                          child: IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () async {
                                dynamic popUpResult =
                                    await Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ListModalForm(
                                      type: "suplier",
                                    );
                                  },
                                ));

                                if (popUpResult == null) return;
                                setState(() {
                                  suplierData["id"] = popUpResult["NOINDEX"];
                                  suplierData["code"] = popUpResult["KODE"];
                                  suplierData["name"] = popUpResult["NAMA"];
                                });
                              },
                              icon: Icon(Icons.search)))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: Text("No Order")),
                      Expanded(
                          flex: 1,
                          child: Text(
                            orderData["code"] ?? "",
                            textAlign: TextAlign.end,
                          )),
                      Expanded(
                          flex: 0,
                          child: IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () async {
                                dynamic popUpResult =
                                    await Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ListModalForm(
                                      type: "penerimaanbarang",
                                      idSuplier: suplierData["id"]!,
                                    );
                                  },
                                ));

                                if (popUpResult == null) return;
                                listOrderBarang = await getRincianOrder(popUpResult["NOINDEX"]);
                                setState(() {
                                  orderData["id"] = popUpResult["NOINDEX"];
                                  orderData["code"] = popUpResult["KODE"];
                                  orderData["name"] = popUpResult["NAMA"];
                                });
                              },
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
                  itemCount: dataListview.length,
                  itemBuilder: (BuildContext context, int index) {
                    dynamic data = dataListview[index];
                    return Container(
                      child: Card(
                        child: InkWell(
                          onTap: () {},
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Utils.labelSetter(data["NAMA"], bold: true),
                                        Utils.labelSetter(data["KODE"]),
                                        Utils.labelSetter(Utils.formatNumber(data["HARGA"]),
                                            bold: true),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Utils.labelSetter("Jumlah : " +
                                                Utils.formatNumber(data["QTY"]) +
                                                " " +
                                                data["SATUAN"]),
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
                      width: double.maxFinite,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {},
                        child: Utils.labelSetter("SIMPAN", color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
