import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

class InputPembelian extends StatefulWidget {
  final String idPembelian;
  const InputPembelian({super.key, this.idPembelian = ""});

  @override
  State<InputPembelian> createState() => _InputPembelianState();
}

class _InputPembelianState extends State<InputPembelian> {
  List<dynamic> dataListview = [];
  //List<dynamic> listOrderBarang = [];

  //global var setter
  String idDept = Utils.idDept;
  String namaDept = Utils.namaDept;
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  String keterangan = "Pembelian mobile";

  Map<String, String> suplierData = {"id": "", "code": "", "name": ""};
  Map<String, String> penerimaanData = {"id": "", "code": "", "name": ""};

  double totalPembelian = 0.0;

  FocusNode searchBarFocus = FocusNode();
  TextEditingController searchBarctrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController gudangCtrl = TextEditingController();

  //modal textfield
  TextEditingController kodeBarangCtrl = TextEditingController();
  TextEditingController namaBarangCtrl = TextEditingController();
  TextEditingController satuanCtrl = TextEditingController();
  TextEditingController qtyPenerimaanCtrl = TextEditingController();
  TextEditingController qtyInputCtrl = TextEditingController();
  TextEditingController hargaCtrl = TextEditingController();
  TextEditingController diskonCtrl = TextEditingController();

  Future getRincianPembelian() async {
    Uri url = Uri.parse("${Utils.mainUrl}pembelian/rincian?noindex=${widget.idPembelian}");
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

      penerimaanData = {
        "id": header["IDPENERIMAAN"] ?? "",
        "code": header["NOMORPENERIMAAN"] ?? "",
        "name": header["NOMORPENERIMAAN"] ?? ""
      };
      dataListview.addAll(detail);
    });
  }

  Future<dynamic> getRincianPenerimaan(String noindex) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    Uri url = Uri.parse("${Utils.mainUrl}penerimaanbarang/rincianorder?noindex=$noindex");
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    var jsonData = jsonDecode(body);
    Navigator.pop(context);
    return jsonData;
  }

  selectBarang({keyword = ""}) async {
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

    List<dynamic> listDetailBarang = await DatabaseHelper()
        .readDatabase("SELECT detail_barang FROM barang_temp WHERE idbarang =?", params: [noIndex]);

    Map<String, dynamic> detailBarang = jsonDecode(listDetailBarang[0]["detail_barang"]);

    Map<String, dynamic> dataMapView = {};
    dataMapView["IDBARANG"] = detailBarang["NOINDEX"];
    dataMapView["KODEBARANG"] = detailBarang["KODE"];
    dataMapView["NAMABARANG"] = detailBarang["NAMA"];
    dataMapView["QTYPENERIMAANBARANG"] = 0.0;
    dataMapView["QTY"] = 0.0;
    dataMapView["KODESATUAN"] = detailBarang["KODE_SATUAN"];
    dataMapView["IDSATUAN"] = detailBarang["IDSATUAN"];
    dataMapView["IDSATUANPENGALI"] = detailBarang["IDSATUAN"];
    dataMapView["QTYSATUANPENGALI"] = 1.0;
    dataMapView["IDGUDANG"] = idGudang;
    dataMapView["HARGA"] = detailBarang["HARGA_BELI"];
    dataMapView["DISKONNOMINAL"] = 0.0;

    setState(() {
      dataListview.add(dataMapView);
      searchBarctrl.text = "";
      searchBarFocus.requestFocus();
      totalPembelian = _calculateTotalPembelian();
    });
  }

  savePembelian() async {
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
      "IDPENERIMAANBARANG": penerimaanData["id"]
    };

    String action = "insert";
    if (widget.idPembelian != "") {
      action = "edit";
      headerParam["NOINDEX"] = widget.idPembelian;
    }

    dynamic bodyparam = {
      "header": headerParam,
      "detail": dataListview,
    };

    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}pembelian/$action";
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
      //listOrderBarang = [];
      //global var setter
      suplierData = {"id": "", "code": "", "name": ""};
      penerimaanData = {"id": "", "code": "", "name": ""};
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

  double _calculateTotalPembelian() {
    double totalPembelian = 0.0;
    for (var d in dataListview) {
      double harga = d["HARGA"];
      totalPembelian = totalPembelian + harga;
    }
    return totalPembelian;
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

  SingleChildScrollView modalEdit(int index, dynamic data) {
    FocusNode qtyInputFocus = FocusNode();

    String idSatuan = data["IDSATUAN"];
    String idSatuanPengali = data["IDSATUANPENGALI"];
    double qtySatuanPengali = data["QTYSATUANPENGALI"];
    kodeBarangCtrl.text = data["KODEBARANG"];
    namaBarangCtrl.text = data["NAMABARANG"];

    qtyPenerimaanCtrl.text = Utils.formatNumber(data["QTYPENERIMAANBARANG"]);
    qtyInputCtrl.text = (Utils.formatNumber(data["QTY"]));
    hargaCtrl.text = (Utils.formatNumber(data["HARGA"]));
    diskonCtrl.text = (Utils.formatNumber(data["DISKONNOMINAL"]));
    satuanCtrl.text = data["KODESATUAN"];

    qtyInputFocus.requestFocus();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Edit Data", size: 25),
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
            Utils.labelForm("Qty Penerimaan"),
            TextField(
              controller: qtyPenerimaanCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (value) {},
            ),
            Utils.labelForm("Qty"),
            TextField(
              controller: qtyInputCtrl,
              focusNode: qtyInputFocus,
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
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "satuanbarang",
                            idBarang: data["IDBARANG"],
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
                )
              ],
            ),
            Utils.labelForm("Harga"),
            TextField(
              controller: hargaCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Utils.labelForm("Diskon"),
            TextField(
              controller: diskonCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                  onPressed: () async {
                    double qtypenerimaan = Utils.strToDouble(qtyPenerimaanCtrl.text);
                    double qtyInput = Utils.strToDouble(qtyInputCtrl.text);
                    double harga = Utils.strToDouble(hargaCtrl.text);
                    double diskon = Utils.strToDouble(diskonCtrl.text);

                    setState(() {
                      dataListview[index]["QTYPENERIMAANBARANG"] = qtypenerimaan;
                      dataListview[index]["QTY"] = qtyInput;
                      dataListview[index]["KODESATUAN"] = satuanCtrl.text;
                      dataListview[index]["IDSATUAN"] = idSatuan;
                      dataListview[index]["IDSATUANPENGALI"] = idSatuanPengali;
                      dataListview[index]["QTYSATUANPENGALI"] = qtySatuanPengali;
                      dataListview[index]["IDGUDANG"] = idGudang;
                      dataListview[index]["HARGA"] = (harga * qtySatuanPengali);
                      dataListview[index]["DISKONNOMINAL"] = diskon;
                      totalPembelian = _calculateTotalPembelian();
                    });

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
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return modalEdit(index, mapDataFromList);
                              },
                            );
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

    if (widget.idPembelian != "") {
      getRincianPembelian();
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
                      Expanded(flex: 1, child: Text("No Penerimaan")),
                      Expanded(
                          flex: 1,
                          child: Text(
                            penerimaanData["code"] ?? "",
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
                                      type: "pembelianpenerimaan",
                                      idSuplier: suplierData["id"]!,
                                    );
                                  },
                                ));

                                if (popUpResult == null) return;

                                dynamic result = await getRincianPenerimaan(popUpResult["NOINDEX"]);

                                if (result["status"] == 1) {
                                  Utils.showMessage(result["message"], context);
                                  return;
                                }

                                dynamic detailData = result["data"]["detail"];

                                List<Map<String, dynamic>> listMapView = [];
                                for (var d in detailData) {
                                  Map<String, dynamic> dataMapView = {};
                                  dataMapView["IDBARANG"] = d["IDBARANG"];
                                  dataMapView["KODEBARANG"] = d["KODEBARANG"];
                                  dataMapView["NAMABARANG"] = d["NAMABARANG"];
                                  dataMapView["QTYPENERIMAANBARANG"] = d["QTY"];
                                  dataMapView["QTY"] = d["QTY"];
                                  dataMapView["KODESATUAN"] = d["KODESATUAN"];
                                  dataMapView["IDSATUAN"] = d["IDSATUAN"];
                                  dataMapView["IDSATUANPENGALI"] = d["IDSATUANPENGALI"];
                                  dataMapView["QTYSATUANPENGALI"] = d["QTYSATUANPENGALI"];
                                  dataMapView["IDGUDANG"] = idGudang;
                                  dataMapView["HARGA"] = (d["HARGA"] * d["QTY"]);
                                  dataMapView["DISKONNOMINAL"] = d["DISKONNOMINAL"];
                                  listMapView.add(dataMapView);
                                }

                                setState(() {
                                  dataListview = listMapView;
                                  penerimaanData["id"] = popUpResult["NOINDEX"];
                                  penerimaanData["code"] = popUpResult["KODE"];
                                  penerimaanData["name"] = popUpResult["NAMA"];
                                  totalPembelian = _calculateTotalPembelian();
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
                    String qtyPenerimaan = Utils.formatNumber(data["QTYPENERIMAANBARANG"]);
                    String qty = Utils.formatNumber(data["QTY"]);
                    String diskon = Utils.formatNumber(data["DISKONNOMINAL"]);
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
                                        Utils.labelValueSetter("Diskon", diskon, boldValue: true),
                                        Utils.labelValueSetter(
                                            "Qty Penerimaan", qtyPenerimaan + " " + satuan),
                                        Utils.labelValueSetter(
                                            "Qty Pembelian ", qty + " " + satuan),
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
                padding: EdgeInsets.all(10),
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
                    Utils.labelValueSetter("Total Pembelian", Utils.formatNumber(totalPembelian),
                        sizeLabel: 18, sizeValue: 18, boldValue: true)
                  ],
                ),
              )),
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
                        onPressed: () => savePembelian(),
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
