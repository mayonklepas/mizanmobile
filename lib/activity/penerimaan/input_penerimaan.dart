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

  //global var setter
  String idDept = Utils.idDept;
  String namaDept = Utils.namaDept;
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  Map<String, String> suplierData = {"id": "", "code": "", "name": ""};
  Map<String, String> orderData = {"id": "", "code": "", "name": ""};
  Map<String, dynamic> qtySetter = {};

  FocusNode searchBarFocus = FocusNode();
  TextEditingController searchBarctrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController gudangCtrl = TextEditingController();

  Future<List<dynamic>> getRincianOrder(String noindex) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    Uri url = Uri.parse(
        "${Utils.mainUrl}penerimaanbarang/rincianorder?noindex=$noindex");
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body)["data"]["detail"];
    Navigator.pop(context);
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
    qtySetter = {};
    if (suplierData["code"] == "" || orderData["code"] == "") {
      Utils.showMessage("Anda belum melengkapi inputan", context);
      return;
    }
    dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ListModalBarang(
          isLocal: true,
        );
      },
    ));

    if (popUpResult == null) return;

    String noIndex = popUpResult["NOINDEX"];

    dynamic getOrderData = listOrderBarang.firstWhere(
        (element) => element["IDBARANG"] == noIndex,
        orElse: () => null);

    bool isAddToList = false;
    if (getOrderData != null) {
      isAddToList = true;
    } else {
      bool addConfirm = await Utils.showConfirmMessage(
          context, "Data tidak ada dalam pesanan, apakah ingin ditambahkan?");
      if (!addConfirm) {
        return;
      }
      isAddToList = true;
    }

    List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
        "SELECT detail_barang,multi_satuan FROM barang_temp WHERE idbarang =?",
        params: [noIndex]);

    Map<String, dynamic> detailBarang =
        jsonDecode(listDetailBarang[0]["detail_barang"]);
    List<dynamic> multiSatuan = jsonDecode(listDetailBarang[0]["multi_satuan"]);

    qtySetter = {
      "is_set": false,
      "qty_terima": 0.0,
      "qty_order": getOrderData?["QTY"] ?? 0.0,
      "satuan": getOrderData?["KODE_SATUAN"] ?? detailBarang["KODE_SATUAN"],
      "id_satuan": getOrderData?["IDSATUAN"] ?? detailBarang["IDSATUAN"],
      "id_satuan_pengali":
          getOrderData?["IDSATUANPENGALI"] ?? detailBarang["IDSATUAN"],
      "qty_satuan_pengali": getOrderData?["QTYSATUANPENGALI"] ?? 1.0,
    };

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return modalSetQty(detailBarang);
      },
    );

    if (!qtySetter["is_set"]) {
      return;
    }

    Map<String, dynamic> dataMapView = {};
    dataMapView["IDBARANG"] = detailBarang["NOINDEX"];
    dataMapView["KODE"] = detailBarang["KODE"];
    dataMapView["NAMA"] = detailBarang["NAMA"];
    dataMapView["QTY"] = qtySetter["qty_terima"];
    dataMapView["QTYORDER"] = qtySetter["qty_order"];
    dataMapView["SATUAN"] = qtySetter["satuan"];
    dataMapView["IDSATUAN"] = qtySetter["id_satuan"];
    dataMapView["IDSATUANPENGALI"] = qtySetter["id_satuan_pengali"];
    dataMapView["QTYSATUANPENGALI"] = qtySetter["qty_satuan_pengali"];
    dataMapView["IDGUDANG"] = idGudang;
    dataMapView["HARGABELI"] =
        (detailBarang["HARGA_BELI"] * qtySetter["qty_satuan_pengali"]);

    setState(() {
      dataListview.add(dataMapView);
    });
  }

  SingleChildScrollView modalSetQty(dynamic data) {
    TextEditingController satuanCtrl = TextEditingController();
    String idSatuan = qtySetter["id_satuan"];
    String idSatuanPengali = qtySetter["id_satuan_pengali"];
    double qtySatuanPengali = qtySetter["qty_satuan_pengali"];
    TextEditingController qtyOrderCtrl = TextEditingController();
    TextEditingController qtyTerimaCtrl = TextEditingController();
    qtyOrderCtrl.text = Utils.formatNumber(qtySetter["qty_order"]);
    satuanCtrl.text = qtySetter["satuan"];

    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "satuanbarang",
                            idBarang: data["NOINDEX"] ?? "",
                          );
                        },
                      ));

                      if (popUpResult == null) return;
                      satuanCtrl.text = popUpResult["NAMA"];
                      idSatuan = popUpResult["NOINDEX"];
                      idSatuanPengali = popUpResult["IDSATUANPENGALI"];
                      qtySatuanPengali = popUpResult["QTYSATUANPENGALI"];
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                  onPressed: () async {
                    qtySetter = {
                      "is_set": true,
                      "qty_terima": Utils.strToDouble(qtyTerimaCtrl.text),
                      "qty_order": Utils.strToDouble(qtyOrderCtrl.text),
                      "satuan": satuanCtrl.text,
                      "id_satuan": idSatuan,
                      "id_satuan_pengali": idSatuanPengali,
                      "qty_satuan_pengali": qtySatuanPengali
                    };

                    Navigator.pop(context);
                  },
                  child: Text("Tambahkan")),
            ),
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }

  savePenerimaan(String action) async {
    if (dataListview.isEmpty ||
        suplierData["code"] == "" ||
        orderData["code"] == "") {
      Utils.showMessage("Anda belum melengkapi inputan", context);
      return;
    }

    dynamic headerParam = {
      "IDDEPT": idDept,
      "TANGGAL": tanggalCtrl.text,
      "KETERANGAN": keteranganCtrl.text,
      "USERINPUT": Utils.idUser,
      "IDSUPLIER": suplierData["id"],
      "IDORDER": orderData["id"]
    };

    dynamic bodyparam = {
      "header": headerParam,
      "detail": dataListview,
    };

    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}penerimaanbarang/$action";
    Uri url = Uri.parse(urlString);
    Response response = await post(url,
        body: jsonEncode(bodyparam), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);

    if (action == "edit") {
      Navigator.pop(context);
      return;
    }

    setState(() {
      dataListview = [];
      listOrderBarang = [];
      //global var setter
      suplierData = {"id": "", "code": "", "name": ""};
      orderData = {"id": "", "code": "", "name": ""};
      qtySetter = {};
      tanggalCtrl.text = tanggalTransaksi;
      idGudang = Utils.idGudang;
      namaGudang = Utils.namaGudang;
      gudangCtrl.text = namaGudang;
      keteranganCtrl.text = "";
    });
  }

  showModalHeader() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return modalHeader();
        });
  }

  void setTextDateRange(TextEditingController tgl) async {
    DateTime? pickedDate = await Utils.getDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        tgl.text = Utils.formatStdDate(pickedDate);
      });
    }
  }

  SingleChildScrollView modalHeader() {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Input Informasi", size: 25),
            Padding(padding: EdgeInsets.all(10)),
            Text("Tanggal"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: tanggalCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      setTextDateRange(tanggalCtrl);
                    },
                    icon: Icon(Icons.date_range),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Departemen"),
            TextField(
              controller: deptCtrl,
              enabled: false,
            ),
            Utils.labelForm("Gudang"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: gudangCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "gudang",
                          );
                        },
                      ));

                      if (popUpResult == null) return;

                      gudangCtrl.text = popUpResult["NAMA"];
                      idGudang = popUpResult["NOINDEX"];
                      namaGudang = popUpResult["NAMA"];
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Keterangan"),
            TextField(
              controller: keteranganCtrl,
            ),
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    tanggalCtrl.text = tanggalTransaksi;
    deptCtrl.text = namaDept;
    gudangCtrl.text = namaGudang;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Utils.widgetSetter(() {
          if (Utils.isPdtMode == "0") {
            return Utils.appBarSearchStatic(() => gotoModalBarang(),
                focus: false, readOnly: true);
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
          IconButton(
              onPressed: () {}, icon: Icon(Icons.qr_code_scanner_rounded)),
          IconButton(
              onPressed: () => showModalHeader(),
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
                            suplierData["name"] ?? "",
                            textAlign: TextAlign.end,
                          )),
                      Expanded(
                          flex: 0,
                          child: IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: () async {
                                dynamic popUpResult = await Navigator.push(
                                    context, MaterialPageRoute(
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
                                if (suplierData["code"] == "") {
                                  Utils.showMessage(
                                      "Anda belum memilih suplier", context);
                                  return;
                                }
                                dynamic popUpResult = await Navigator.push(
                                    context, MaterialPageRoute(
                                  builder: (context) {
                                    return ListModalForm(
                                      type: "penerimaanbarang",
                                      idSuplier: suplierData["id"]!,
                                    );
                                  },
                                ));

                                if (popUpResult == null) return;

                                listOrderBarang = await getRincianOrder(
                                    popUpResult["NOINDEX"]);

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Utils.labelSetter(data["NAMA"],
                                            bold: true),
                                        Utils.labelSetter(data["KODE"]),
                                        Utils.labelSetter("Harga Beli: " +
                                            Utils.formatNumber(
                                                data["HARGABELI"])),
                                        Utils.labelSetter("Jumlah Order: " +
                                            Utils.formatNumber(
                                                data["QTYORDER"]) +
                                            " " +
                                            data["SATUAN"]),
                                        Utils.labelSetter("Jumlah Terima: " +
                                            Utils.formatNumber(data["QTY"]) +
                                            " " +
                                            data["SATUAN"])
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
                        onPressed: () => savePenerimaan("insert"),
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
