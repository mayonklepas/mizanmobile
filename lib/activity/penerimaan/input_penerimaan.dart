import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class InputPenerimaan extends StatefulWidget {
  final String idPenerimaan;
  const InputPenerimaan({super.key, this.idPenerimaan = ""});

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
  String keterangan = "Penerimaan mobile";
  Map<String, String> suplierData = {"id": "", "code": "", "name": ""};
  Map<String, String> orderData = {"id": "", "code": "", "name": ""};
  Map<String, dynamic> qtySetter = {};

  FocusNode searchBarFocus = FocusNode();
  TextEditingController searchBarctrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController gudangCtrl = TextEditingController();

  Future getRincianPenerimaan() async {
    Uri url = Uri.parse("${Utils.mainUrl}penerimaanbarang/rincian?noindex=${widget.idPenerimaan}");
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body)["data"];
    dynamic header = jsonData["header"][0];
    List<dynamic> detail = jsonData["detail"];
    setState(() {
      keterangan = header["KETERANGAN"];
      tanggalTransaksi = header["TANGGAL"];
      keteranganCtrl.text = keterangan;
      tanggalCtrl.text = tanggalTransaksi;
      suplierData = {
        "id": header["IDSUPLIER"],
        "code": header["KODESUPLIER"],
        "name": header["NAMASUPLIER"]
      };
      orderData = {
        "id": header["IDORDER"] ?? "",
        "code": header["NOMORORDER"] ?? "",
        "name": header["NOMORORDER"] ?? ""
      };
      dataListview.addAll(detail);
    });
  }

  Future<dynamic> getRincianOrder(String noindex) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    Uri url = Uri.parse("${Utils.mainUrl}penerimaanbarang/rincianorder?noindex=$noindex");
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body);
    Navigator.pop(context);
    return jsonData;
  }

  selectBarang({keyword = ""}) async {
    qtySetter = {};
    if (suplierData["code"] == "") {
      Utils.showMessage("Anda belum melengkapi inputan", context);
      return;
    }

    dynamic result = null;

    if (keyword.isEmpty) {
      result = await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return ListModalBarang(
            isLocal: true,
          );
        },
      ));
    } else {
      result = await DatabaseHelper().readDatabase(
          "SELECT idbarang AS NOINDEX FROM barang_temp WHERE kode =?",
          params: [keyword]);
      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Utils.labelSetter("Data tidak ditemukan", color: Colors.red, size: 20)));
        setState(() {
          searchBarctrl.text = "";
          searchBarFocus.requestFocus();
        });

        return;
      }
      result = result[0];
    }

    if (result == null || result.isEmpty) return;

    String noIndex = result["NOINDEX"];

    //check duplicate data
    bool isDataExistAtList = dataListview.any((element) => element["IDBARANG"] == noIndex);
    if (isDataExistAtList) {
      Utils.showMessage("Barang sudah ada pada daftar", context);
      return;
    }

    dynamic getOrderData = {};
    if (orderData["code"] != "") {
      getOrderData = listOrderBarang.firstWhere((element) => element["IDBARANG"] == noIndex,
          orElse: () => null);
      if (getOrderData == null) {
        bool addConfirm = await Utils.showConfirmMessage(
            context, "Data tidak ada dalam pesanan, apakah ingin ditambahkan?");
        if (!addConfirm) {
          return;
        }
      }
    }

    List<dynamic> listDetailBarang = await DatabaseHelper()
        .readDatabase("SELECT detail_barang FROM barang_temp WHERE idbarang =?", params: [noIndex]);

    Map<String, dynamic> detailBarang = jsonDecode(listDetailBarang[0]["detail_barang"]);

    qtySetter = {
      "is_set": false,
      "id_barang": detailBarang["NOINDEX"],
      "kode_barang": detailBarang["KODE"],
      "nama_barang": detailBarang["NAMA"],
      "harga": detailBarang["HARGA_BELI"],
      "qty_terima": 0.0,
      "qty_order": getOrderData?["QTY"] ?? 0.0,
      "kode_satuan": getOrderData?["KODE_SATUAN"] ?? detailBarang["KODE_SATUAN"],
      "id_satuan": getOrderData?["IDSATUAN"] ?? detailBarang["IDSATUAN"],
      "id_satuan_pengali": getOrderData?["IDSATUANPENGALI"] ?? detailBarang["IDSATUAN"],
      "qty_satuan_pengali": getOrderData?["QTYSATUANPENGALI"] ?? 1.0,
    };

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return modalSetQty();
      },
    );

    if (!qtySetter["is_set"]) {
      return;
    }

    Map<String, dynamic> dataMapView = {};
    dataMapView["IDBARANG"] = qtySetter["id_barang"];
    dataMapView["KODEBARANG"] = qtySetter["kode_barang"];
    dataMapView["NAMABARANG"] = qtySetter["nama_barang"];
    dataMapView["QTY"] = qtySetter["qty_terima"];
    dataMapView["QTYORDER"] = qtySetter["qty_order"];
    dataMapView["KODESATUAN"] = qtySetter["kode_satuan"];
    dataMapView["IDSATUAN"] = qtySetter["id_satuan"];
    dataMapView["IDSATUANPENGALI"] = qtySetter["id_satuan_pengali"];
    dataMapView["QTYSATUANPENGALI"] = qtySetter["qty_satuan_pengali"];
    dataMapView["IDGUDANG"] = idGudang;
    dataMapView["HARGA"] = (qtySetter["harga"] * qtySetter["qty_satuan_pengali"]);

    setState(() {
      dataListview.add(dataMapView);
      searchBarctrl.text = "";
      searchBarFocus.requestFocus();
    });
  }

  savePenerimaan() async {
    if (dataListview.isEmpty || suplierData["code"] == "") {
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

    String action = "insert";
    if (widget.idPenerimaan != "") {
      action = "edit";
      headerParam["NOINDEX"] = widget.idPenerimaan;
    }

    dynamic bodyparam = {
      "header": headerParam,
      "detail": dataListview,
    };

    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}penerimaanbarang/$action";
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(bodyparam), headers: Utils.setHeader());
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
      tanggalTransaksi = Utils.currentDateString();
      tanggalCtrl.text = tanggalTransaksi;
      idGudang = Utils.idGudang;
      namaGudang = Utils.namaGudang;
      gudangCtrl.text = namaGudang;
      keterangan = "";
      keteranganCtrl.text = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Utils.labelSetter("Data berhasil disimpan", color: Colors.green, size: 20)));
  }

//modal
  Future<dynamic> showModalHeader() async {
    deptCtrl.text = namaDept;
    gudangCtrl.text = namaGudang;
    keteranganCtrl.text = keterangan;
    tanggalCtrl.text = tanggalTransaksi;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
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
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          tanggalTransaksi = tanggalCtrl.text;
                          keterangan = keteranganCtrl.text;
                          Navigator.pop(context);
                        },
                        child: Text("Oke")),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                ],
              ),
            ),
          );
          ;
        });
  }

  SingleChildScrollView modalSetQty() {
    TextEditingController kodeBarangCtrl = TextEditingController();
    TextEditingController namaBarangCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    String idSatuan = qtySetter["id_satuan"];
    String idSatuanPengali = qtySetter["id_satuan_pengali"];
    double qtySatuanPengali = qtySetter["qty_satuan_pengali"];
    kodeBarangCtrl.text = qtySetter["kode_barang"];
    namaBarangCtrl.text = qtySetter["nama_barang"];
    TextEditingController qtyOrderCtrl = TextEditingController();
    TextEditingController qtyTerimaCtrl = TextEditingController();
    FocusNode qtyTerimFocus = FocusNode();
    qtyOrderCtrl.text = Utils.formatNumber(qtySetter["qty_order"]);
    if (qtySetter["qty_terima"] == 0.0) {
      qtyTerimaCtrl.text = "";
    } else {
      qtyTerimaCtrl.text = (Utils.formatNumber(qtySetter["qty_terima"]));
    }

    qtyTerimFocus.requestFocus();

    satuanCtrl.text = qtySetter["kode_satuan"];

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Input QTY", size: 25),
            Padding(padding: EdgeInsets.all(10)),
            Utils.labelForm("Kode Barang"),
            TextField(
              controller: kodeBarangCtrl,
              readOnly: true,
            ),
            Utils.labelForm("Nama Barang"),
            TextField(
              controller: namaBarangCtrl,
              readOnly: true,
            ),
            Utils.labelForm("Qty Order"),
            TextField(
              controller: qtyOrderCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (value) {},
            ),
            Utils.labelForm("Qty Terima"),
            TextField(
              controller: qtyTerimaCtrl,
              focusNode: qtyTerimFocus,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                /*Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "satuanbarang",
                            idBarang: qtySetter["id_barang"],
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
                )*/
              ],
            ),
            SizedBox(height: 5),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                  onPressed: () async {
                    qtySetter["is_set"] = true;
                    qtySetter["qty_terima"] = Utils.strToDouble(qtyTerimaCtrl.text);
                    qtySetter["qty_order"] = Utils.strToDouble(qtyOrderCtrl.text);
                    qtySetter["satuan"] = satuanCtrl.text;
                    qtySetter["id_satuan"] = idSatuan;
                    qtySetter["is_satuan_pengali"] = idSatuanPengali;
                    qtySetter["qty_satuan_pengali"] = qtySatuanPengali;
                    Navigator.pop(context);
                  },
                  child: Text("Oke")),
            ),
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }

  void setTextDateRange(TextEditingController tgl) async {
    DateTime? pickedDate = await Utils.getDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        tgl.text = Utils.formatStdDate(pickedDate);
      });
    }
  }

  Future<dynamic> showOption(int index, dynamic mapDataFromList) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext content) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            qtySetter = {
                              "is_set": false,
                              "id_barang": mapDataFromList?["IDBARANG"],
                              "kode_barang": mapDataFromList?["KODEBARANG"],
                              "nama_barang": mapDataFromList?["NAMABARANG"],
                              "harga":
                                  (mapDataFromList?["HARGA"] / mapDataFromList["QTYSATUANPENGALI"]),
                              "qty_terima": mapDataFromList?["QTY"],
                              "qty_order": mapDataFromList?["QTYORDER"],
                              "kode_satuan": mapDataFromList?["KODESATUAN"],
                              "id_satuan": mapDataFromList?["IDSATUAN"],
                              "id_satuan_pengali": mapDataFromList["IDSATUANPENGALI"],
                              "qty_satuan_pengali": mapDataFromList["QTYSATUANPENGALI"],
                            };

                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return modalSetQty();
                              },
                            );

                            if (!qtySetter["is_set"]) {
                              return;
                            }
                            Map<String, dynamic> dataMapView = {};
                            dataMapView["IDBARANG"] = qtySetter["id_barang"];
                            dataMapView["KODEBARANG"] = qtySetter["kode_barang"];
                            dataMapView["NAMABARANG"] = qtySetter["nama_barang"];
                            dataMapView["QTY"] = qtySetter["qty_terima"];
                            dataMapView["QTYORDER"] = qtySetter["qty_order"];
                            dataMapView["KODESATUAN"] = qtySetter["kode_satuan"];
                            dataMapView["IDSATUAN"] = qtySetter["id_satuan"];
                            dataMapView["IDSATUANPENGALI"] = qtySetter["id_satuan_pengali"];
                            dataMapView["QTYSATUANPENGALI"] = qtySetter["qty_satuan_pengali"];
                            dataMapView["IDGUDANG"] = idGudang;
                            dataMapView["HARGA"] =
                                (qtySetter["harga"] * qtySetter["qty_satuan_pengali"]);

                            setState(() {
                              dataListview[index] = dataMapView;
                            });
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.black54,
                          )),
                      Text("Edit")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            bool isOk = await Utils.showConfirmMessage(
                                context, "ingin menghapus data ini ?");
                            if (!isOk) {
                              return;
                            }

                            setState(() {
                              dataListview.removeAt(index);
                            });
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.black54,
                          )),
                      Text("Delete")
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    tanggalCtrl.text = tanggalTransaksi;
    keteranganCtrl.text = keterangan;

    if (widget.idPenerimaan != "") {
      getRincianPenerimaan();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Utils.widgetSetter(() {
          if (Utils.isPdtMode == "0") {
            return Utils.appBarSearchStatic(() => selectBarang(), focus: false, readOnly: true);
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
                onSubmitted: (keyword) => selectBarang(keyword: keyword)),
          );
        }),
        actions: [
          Utils.widgetSetter(() {
            if (Utils.isPdtMode == "0") {
              return IconButton(
                  onPressed: () async {
                    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                        "#ff6666", "Cancel", true, ScanMode.BARCODE);

                    if (barcodeScanRes.isEmpty) {
                      Utils.showMessage("Data tidak ditemukan, coba ulangi", context);
                      return;
                    }

                    selectBarang(keyword: barcodeScanRes);
                  },
                  icon: Icon(Icons.qr_code_scanner_rounded));
            }
            return IconButton(onPressed: () => selectBarang(), icon: Icon(Icons.list_alt_sharp));
          }),
          IconButton(onPressed: () => showModalHeader(), icon: Icon(Icons.note_add_rounded))
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
                                if (suplierData["code"] == "") {
                                  Utils.showMessage("Anda belum memilih suplier", context);
                                  return;
                                }
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

                                dynamic result = await getRincianOrder(popUpResult["NOINDEX"]);
                                if (result["status"] == 1) {
                                  Utils.showMessage(result["message"], context);
                                  return;
                                }

                                listOrderBarang = result["data"]["detail"];

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
                    String namaBarang = data["NAMABARANG"];
                    String kodeBarang = data["KODEBARANG"];
                    String satuan = data["KODESATUAN"];
                    String harga = Utils.formatNumber(data["HARGA"]);
                    String qtyOrder = Utils.formatNumber(data["QTYORDER"]);
                    String qtyTerima = Utils.formatNumber(data["QTY"]);
                    return Container(
                      child: Card(
                        child: InkWell(
                          onTap: () => showOption(index, data),
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
                                        Utils.labelSetter(namaBarang, bold: true),
                                        Utils.labelSetter(kodeBarang),
                                        Utils.labelValueSetter("Harga", harga, boldValue: true),
                                        Utils.labelValueSetter(
                                            "Qty Order ", qtyOrder + " " + satuan),
                                        Utils.labelValueSetter(
                                            "Qty Terima ", qtyTerima + " " + satuan)
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
                        onPressed: () => savePenerimaan(),
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
