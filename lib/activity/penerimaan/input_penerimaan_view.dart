import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/activity/utility/printer_util.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class InputPenerimaanView extends StatefulWidget {
  final String idTransaksi;
  const InputPenerimaanView({Key? key, this.idTransaksi = ""}) : super(key: key);

  @override
  State<InputPenerimaanView> createState() => _InputPenerimaanViewState();
}

class _InputPenerimaanViewState extends State<InputPenerimaanView> {
  TextEditingController gudangCtrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  String noOrder = "";
  String idOrder = "";
  String idTransaksiGlobal = "";
  String norefGlobal = "";
  String keterangan = "";
  TextEditingController suplierCtrl = TextEditingController();
  String idSuplier = "";
  String idSuplierEdit = "";
  String namaSuplier = "";
  String namaPelangganEdit = "";
  String idGolonganSuplier = Utils.idGolonganSuplier;
  String idGolongan2Suplier = Utils.idGolongan2Suplier;
  String idDept = Utils.idDept;
  String idDeptEdit = "";
  String namaDept = Utils.namaDept;
  TextEditingController topCtrl = TextEditingController();
  String idTop = "";
  String namaTop = "";
  TextEditingController uangMukaCtrl = TextEditingController();
  bool isKredit = false;
  double totalPenjualan = 0;
  double kembalian = 0;
  TextEditingController jumlahUangCtrl = TextEditingController();
  String kembalianStatus = "";
  double jumlahBayarEdit = 0;
  String idUserInput = "";
  TextEditingController paymentTypeCtrl = TextEditingController();
  TextEditingController searchBarctrl = TextEditingController();

  List<dynamic> listRincianOrder = [];
  List<dynamic> dataList = [];
  List<dynamic> dataListShow = [];
  double totalBiaya = 0;

  FocusNode searchBarFocus = FocusNode();

  bool isMultiPayment = false;
  Map<String, double> multiPaymentSendData = {};
  List<DropdownMenuEntry<dynamic>> itemList = [];

  Future<dynamic> getDataDetailBarang(String idBarang) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/rincian?idgudang=$idGudang&halaman=0&idbarang=$idBarang";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> getRincianOrder(String idRincian) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}orderpembelian/rincian?noindex=$idRincian";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    return jsonData;
  }

  Future<dynamic> savePenerimaan(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}penjualan/$urlPath";
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    // TODO: implement initState
    tanggalCtrl.text = tanggalTransaksi;
    keteranganCtrl.text = "Penerimaan";
    super.initState();
  }

  void setTextDateRange(TextEditingController tgl) async {
    DateTime? pickedDate = await Utils.getDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        tgl.text = Utils.formatStdDate(pickedDate);
      });
    }
  }

  Future<List<dynamic>> setFuture(List<dynamic> data) async {
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: setSearchBarView(),
          actions: [
            IconButton(
                onPressed: () async {
                  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666", "Cancel", true, ScanMode.BARCODE);

                  if (barcodeScanRes.isEmpty) {
                    Utils.showMessage("Data tidak ditemukan, coba ulangi", context);
                    return;
                  }

                  List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
                      "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE kode=?",
                      params: [barcodeScanRes]);
                  listValueSetter(listDetailBarang);
                },
                icon: Icon(Icons.qr_code_scanner_rounded)),
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return modalHeader();
                      });
                },
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
                              namaSuplier,
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
                                  log(popUpResult.toString());

                                  setState(() {
                                    suplierCtrl.text = popUpResult["NAMA"];
                                    idSuplier = popUpResult["NOINDEX"];
                                    namaSuplier = popUpResult["NAMA"];
                                    idGolonganSuplier = popUpResult["IDGOLONGAN"];
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
                            flex: 2,
                            child: Text(
                              noOrder,
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
                                        type: "orderpembelian",
                                        idSuplier: idSuplier,
                                      );
                                    },
                                  ));

                                  if (popUpResult == null) return;

                                  setState(() {
                                    noOrder = popUpResult["KODE"];
                                  });
                                  idOrder = popUpResult["NOINDEX"];

                                  Map<String, dynamic> getRincianResult =
                                      await getRincianOrder(idOrder);
                                  listRincianOrder = getRincianResult["detail"];
                                  log(listRincianOrder.toString());
                                },
                                icon: Icon(Icons.search)))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: _listDataBarang()),
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
                        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 5),
                        child: Utils.labelValueSetter("Total", Utils.formatNumber(totalPenjualan),
                            sizeLabel: 18, sizeValue: 18, boldValue: true),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Utils.labelSetter("SIMPAN", color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }

  void listValueSetter(List<dynamic> listDetailBarang) {
    dynamic detailBarang = listDetailBarang[0];
    dynamic resultDataDetail = {
      "detail_barang": jsonDecode(detailBarang["detail_barang"]),
      "multi_satuan": jsonDecode(detailBarang["multi_satuan"]),
      "multi_harga": jsonDecode(detailBarang["multi_harga"]),
      "harga_tanggal": jsonDecode(detailBarang["harga_tanggal"]),
    };

    var data = resultDataDetail;
    var db = data["detail_barang"];
    db = data["detail_barang"];
    if (!isBarangExists(db["NOINDEX"].toString())) {
      dynamic hargaUpdate = 0;
      setState(() {
        dataListShow.add({
          "IDBARANG": db["NOINDEX"].toString(),
          "KODE": db["KODE"],
          "NAMA": db["NAMA"],
          "IDSATUAN": db["IDSATUAN"],
          "SATUAN": db["KODE_SATUAN"],
          "QTY": 1.0,
          "HARGA": hargaUpdate["HARGA"],
          "DISKON_NOMINAL": 0.0,
          "IDGUDANG": idGudang,
          "IDSATUANPENGALI": hargaUpdate["IDSATUANPENGALI"],
          "QTYSATUANPENGALI": hargaUpdate["QTYSATUANPENGALI"]
        });
        dataList.add(data);
        totalPenjualan = 0;
      });
    } else {
      int index = getIndexBarang(db["NOINDEX"].toString());
      double qty = dataListShow[index]["QTY"] + 1;
      String idSatuan = db["IDSATUAN"];
      dynamic hargaUpdate = 0;

      setState(() {
        dataListShow[index]["IDSATUANPENGALI"] = hargaUpdate["IDSATUANPENGALI"];
        dataListShow[index]["QTY"] = qty;
        dataListShow[index]["QTYSATUANPENGALI"] = hargaUpdate["QTYSATUANPENGALI"];
        dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
        totalPenjualan = 0;
      });
    }
  }

  ListView _listDataBarang() {
    return ListView.builder(
        itemCount: dataListShow.length,
        itemBuilder: (BuildContext context, int index) {
          dynamic data = dataListShow[index];
          return Container(
            child: Card(
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return modalEdit(data, index);
                      });
                },
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
                              Utils.labelSetter(Utils.formatNumber(data["HARGA"]), bold: true),
                              Utils.labelValueSetter(
                                  "QTY ORDER", Utils.formatDate(data["QTY_ORDER"])),
                              Utils.labelSetter(Utils.formatNumber(data["HARGA"]), bold: true),
                              Utils.labelValueSetter("QTY", Utils.formatDate(data["QTY"])),
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

  bool isBarangExists(String idBarang) {
    bool result = false;
    for (var d in dataListShow) {
      if (d["IDBARANG"] == idBarang) {
        result = true;
        break;
      }
    }
    return result;
  }

  int getIndexBarang(String idBarang) {
    int result = 0;
    for (var i = 0; i < dataListShow.length; i++) {
      if (dataListShow[i]["IDBARANG"] == idBarang) {
        result = i;
        break;
      }
    }
    return result;
  }

  SingleChildScrollView modalEdit(dynamic data, int index) {
    TextEditingController jumlahCtrl = TextEditingController();
    TextEditingController diskonCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    satuanCtrl.text = data["SATUAN"];
    String idSatuan = data["IDSATUAN"];
    jumlahCtrl.text = Utils.formatNumber(data["QTY"]);
    diskonCtrl.text = Utils.formatNumber(data["DISKON_NOMINAL"]);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Edit Jumlah", size: 25),
            Padding(padding: EdgeInsets.all(10)),
            Utils.labelForm("Jumlah"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 5,
                  child: TextField(
                    controller: jumlahCtrl,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        String jumlahText = jumlahCtrl.text;
                        if (jumlahText == "") {
                          jumlahCtrl.text = "1";
                        } else {
                          int jumlah = int.parse(Utils.removeDotSeparator(jumlahText));
                          jumlah = jumlah + 1;
                          jumlahCtrl.text = jumlah.toString();
                        }
                      },
                      child: Icon(Icons.add),
                    )),
                SizedBox(width: 10),
                Flexible(
                    flex: 1,
                    child: OutlinedButton(
                        onPressed: () {
                          String jumlahText = jumlahCtrl.text;
                          if (jumlahText == "") {
                            jumlahCtrl.text = "1";
                          } else {
                            int jumlah = int.parse(Utils.removeDotSeparator(jumlahText));
                            if (jumlah > 1) {
                              jumlah = jumlah - 1;
                            }
                            jumlahCtrl.text = jumlah.toString();
                          }
                        },
                        child: Icon(Icons.remove)))
              ],
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
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Diskon"),
            TextField(
              controller: diskonCtrl,
            ),
            Padding(padding: EdgeInsets.all(5)),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: ElevatedButton(
                        onPressed: () {
                          /* double qty = double.parse(Utils.removeDotSeparator(jumlahCtrl.text));
                          dynamic hargaUpdate = getHargaJual(dataList[index], idSatuan, qty);
                          setState(() {
                            dataListShow[index]["IDSATUANPENGALI"] = hargaUpdate["IDSATUANPENGALI"];
                            dataListShow[index]["QTY"] = qty;
                            dataListShow[index]["QTYSATUANPENGALI"] =
                                hargaUpdate["QTYSATUANPENGALI"];
                            dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
                            dataListShow[index]["IDSATUAN"] = idSatuan;
                            dataListShow[index]["SATUAN"] = satuanCtrl.text;
                            dataListShow[index]["DISKON_NOMINAL"] =
                                double.parse(Utils.removeDotSeparator(diskonCtrl.text));

                            totalPenjualan = setTotalJual();
                            Navigator.pop(context);
                          });*/
                        },
                        child: Text("Simpan"))),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () async {
                          bool isDelete = await Utils.showConfirmMessage(
                              context, "Yakin ingin menghapus data ini ?");
                          if (isDelete) {
                            Navigator.pop(context);
                            setState(() {
                              dataList.removeAt(index);
                              dataListShow.removeAt(index);
                            });
                          }
                        },
                        child: Text("Hapus")))
              ],
            )
          ],
        ),
      ),
    );
  }

  SingleChildScrollView modalHeader() {
    deptCtrl.text = namaDept;
    tanggalCtrl.text = tanggalTransaksi;
    gudangCtrl.text = namaGudang;
    suplierCtrl.text = namaSuplier;
    keteranganCtrl.text = keterangan;
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
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }

  _sendPayment({int isTunai = 0}) async {
    Map headerMap = {
      "IDDEPT": idDept,
      "KETERANGAN": keteranganCtrl.text,
      "USERINPUT": Utils.idUser,
      "TANGGAL": tanggalCtrl.text,
      "IDSUPLIER": idSuplier,
      "IDORDER": idOrder,
    };

    List<dynamic> detailList = [];

    for (var dataMap in dataListShow) {
      detailList.add({
        "IDBARANG": dataMap["IDBARANG"],
        "QTYORDER": dataMap["QTY"],
        "QTY": dataMap["HARGA"],
        "IDSATUAN": dataMap["IDSATUAN"],
        "IDGUDANG": idGudang,
        "IDSATUANPENGALI": dataMap["IDSATUANPENGALI"],
        "QTYSATUANPENGALI": dataMap["QTYSATUANPENGALI"]
      });
    }

    Map<String, Object> rootMap = {"header": headerMap, "detail": detailList};
    var result;
    if (widget.idTransaksi == "") {
      result = await _postPenjualan(rootMap, "insert");
    } else {
      headerMap["NOINDEX"] = widget.idTransaksi;
      headerMap["IDPELANGGAN"] = idSuplierEdit;
      headerMap["USERINPUT"] = idUserInput;
      headerMap["USEREDIT"] = Utils.idUser;
      result = await _postPenjualan(rootMap, "edit");
    }

    if (result["status"] == 1) {
      Utils.showMessage(result["message"], context);
      return;
    }

    var dataResult = result["data"];

    List<dynamic> detailBarangPost = dataResult["detail_barang"];

    DatabaseHelper dbh = DatabaseHelper();
    for (var d in detailBarangPost) {
      String idBarang = d["IDBARANG"];
      double stoktambahan = d["STOK"];

      List<dynamic> lsLocalUpdate = await dbh.readDatabase(
          "SELECT detail_barang FROM barang_temp WHERE idbarang =? ",
          params: [idBarang]);

      dynamic detailBarang = jsonDecode(lsLocalUpdate[0]["detail_barang"]);
      detailBarang["STOK"] = stoktambahan;
      String detailBarangStr = jsonEncode(detailBarang);

      await dbh.writeDatabase("UPDATE barang_temp SET detail_barang=? WHERE idbarang=?",
          params: [detailBarangStr, idBarang]);

      List<dynamic> lsLocalUpdateEnd = await dbh.readDatabase(
          "SELECT detail_barang FROM barang_temp WHERE idbarang =? ",
          params: [idBarang]);

      //log(lsLocalUpdateEnd[0]["detail_barang"]);
    }

    //log(result.toString());
    if (isTunai == 1) {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Utils.labelSetter("Transaksi berhasil", color: Colors.green, size: 20)));
    List<dynamic> dataListPrint = dataListShow;
    dynamic additionalInfo = {
      "kreditOrTunai": (isTunai == 0) ? "Tunai" : "Kredit",
      "totalUangMuka": Utils.strToDouble(uangMukaCtrl.text),
      "tanggal": tanggalCtrl.text,
      "kodePelanggan": Utils.kodePelanggan,
      "namaPelanggan": Utils.namaPelanggan,
      "jumlahUang": Utils.strToDouble(jumlahUangCtrl.text)
    };

    Map<String, String> printResult =
        await PrinterUtils().printReceipt(dataListPrint, additionalInfo);
    if (printResult["status"] == "error") {
      log(printResult["message"].toString());
    }

    if (widget.idTransaksi != "") {
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    }

    setState(() {
      dataList.clear();
      dataListShow.clear();
      isKredit = false;
      topCtrl.text = "";
      idTop = "";
      uangMukaCtrl.text = "";
      totalBiaya = 0;
    });
  }

  Widget setSearchBarView() {
    if (Utils.isPdtMode == "0") {
      return Utils.appBarSearchStatic(() async {
        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ListModalBarang(
              isLocal: true,
            );
          },
        ));

        if (popUpResult == null) return;

        String noIndex = popUpResult["NOINDEX"];
        log(noIndex);
      }, focus: false, readOnly: true);
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
            onSubmitted: (keyword) async {
              if (listRincianOrder.isEmpty) {
                Utils.showMessage("Anda belum memilih ", context);
              }
              List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
                  "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE kode =?",
                  params: [keyword]);

              if (listDetailBarang.isEmpty) {
                bool isOpenSearch = await Utils.showConfirmMessage(
                    context, "Data tidak ditemukan, buka pencarian?");
                if (isOpenSearch) {
                  dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListModalBarang(
                        isLocal: true,
                      );
                    },
                  ));

                  if (popUpResult == null) return;

                  String noIndex = popUpResult["NOINDEX"];

                  bool isFound = false;
                  for (var d in listRincianOrder) {
                    String noindexIn = d["NOINDEX"];
                    if (noindexIn == noIndex) {
                      isFound == true;
                    }
                  }

                  if (isFound == false) {
                    Utils.showMessage("Barang yang dipilih tidak ada dalam order", context);
                  }

                  List<dynamic> listDetailBarang = await DatabaseHelper().readDatabase(
                      "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =?",
                      params: [noIndex]);
                  listValueSetter(listDetailBarang);
                  setState(() {
                    searchBarctrl.clear();
                  });
                }

                searchBarFocus.requestFocus();
                return;
              }

              if (listDetailBarang.length > 1) {
                dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ListModalBarang(
                      isLocal: true,
                      keyword: keyword,
                    );
                  },
                ));

                if (popUpResult == null) return;
                String noIndex = popUpResult["NOINDEX"];
                listDetailBarang = await DatabaseHelper().readDatabase(
                    "SELECT detail_barang,multi_satuan,multi_harga,harga_tanggal FROM barang_temp WHERE idbarang =?",
                    params: [noIndex]);
              }

              listValueSetter(listDetailBarang);
              setState(() {
                searchBarctrl.clear();
              });
              searchBarFocus.requestFocus();
            }));
  }
}
