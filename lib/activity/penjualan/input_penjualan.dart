import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class InputPenjualan extends StatefulWidget {
  final String idTransaksi;
  const InputPenjualan({Key? key, this.idTransaksi = ""}) : super(key: key);

  @override
  State<InputPenjualan> createState() => _InputPenjualanState();
}

class _InputPenjualanState extends State<InputPenjualan> {
  TextEditingController gudangCtrl = TextEditingController();
  TextEditingController tanggalCtrl = TextEditingController();
  TextEditingController keteranganCtrl = TextEditingController();
  TextEditingController deptCtrl = TextEditingController();
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  String idTransaksiGlobal = "";
  String norefGlobal = "";
  String keterangan = "";
  TextEditingController pelangganCtrl = TextEditingController();
  String idPelanggan = Utils.idPelanggan;
  String namaPelanggan = Utils.namaPelanggan;
  String idGolonganPelanggan = Utils.idGolonganPelanggan;
  String idGolongan2Pelanggan = Utils.idGolongan2Pelanggan;
  String idDept = Utils.idDept;
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

  List<dynamic> dataList = [];
  List<dynamic> dataListShow = [];

  Future<dynamic> _getBarang(String keyword) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/caribarangjual?idgudang=${Utils.idGudang}&cari=" +
            keyword;
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    Navigator.pop(context);
    print(urlString);
    return jsonData;
  }

  Future<dynamic> _postPenjualan(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}penjualan/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response =
        await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body);
    Navigator.pop(context);
    return jsonData;
  }

  dynamic _getDetailPenjualan() {
    List<dynamic> dataSample = [
      <String, Object>{
        "NOINDEX": "123",
        "NAMA": "bakso",
        "KODE": "12345",
        "SATUAN": "pcs",
        "JUMLAH": 1,
        "HARGA": 120000,
      }
    ];

    return dataSample;
  }

  @override
  void initState() {
    // TODO: implement initState
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
          title: Utils.appBarSearch((keyword) async {
            var resultData = await _getBarang(keyword);
            String tipe = resultData["tipe"];
            if (tipe == "daftar") {
              List<dynamic> itemList = resultData["item"];
              dynamic popUpResult =
                  await Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return ListModalBarang(barangList: jsonEncode(itemList));
                },
              ));

              if (popUpResult == null) return;
              var resultDataDetail = await _getBarang(popUpResult["KODE"]);
              var data = resultDataDetail["item"];
              var db = data["detail_barang"][0];
              if (!isBarangExists(db["NOINDEX"].toString())) {
                setState(() {
                  dataListShow.add({
                    "IDBARANG": db["NOINDEX"].toString(),
                    "KODE": db["KODE"],
                    "NAMA": db["NAMA"],
                    "IDSATUAN": db["IDSATUAN"],
                    "SATUAN": db["KODE_SATUAN"],
                    "QTY": 1,
                    "HARGA": db["HARGA_JUAL"],
                    "DISKON_NOMINAL": 0,
                    "IDGUDANG": idGudang,
                    "IDSATUANPENGALI": db["IDSATUAN"],
                    "QTYSATUANPENGALI": 1
                  });
                  dataList.add(data);
                  totalPenjualan = setTotalJual();
                });
              } else {
                int index = getIndexBarang(db["NOINDEX"].toString());
                int qty = dataListShow[index]["QTY"] + 1;
                String idSatuan = db["IDSATUAN"];
                dynamic hargaUpdate = getHargaJual(data, idSatuan, qty);

                setState(() {
                  dataListShow[index]["IDSATUANPENGALI"] =
                      hargaUpdate["IDSATUANPENGALI"];
                  dataListShow[index]["QTY"] = qty;
                  dataListShow[index]["QTYSATUANPENGALI"] =
                      hargaUpdate["QTYSATUANPENGALI"];
                  dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
                  totalPenjualan = setTotalJual();
                });
              }
            } else {
              dynamic data = resultData["item"];
              var db = data["detail_barang"][0];
              if (!isBarangExists(db["NOINDEX"].toString())) {
                setState(() {
                  dataListShow.add({
                    "IDBARANG": db["NOINDEX"].toString(),
                    "KODE": db["KODE"],
                    "NAMA": db["NAMA"],
                    "IDSATUAN": db["IDSATUAN"],
                    "SATUAN": db["KODE_SATUAN"],
                    "QTY": 1,
                    "HARGA": db["HARGA_JUAL"],
                    "DISKON_NOMINAL": 0,
                    "IDGUDANG": idGudang,
                    "IDSATUANPENGALI": db["IDSATUAN"],
                    "QTYSATUANPENGALI": 1
                  });
                  dataList.add(data);
                  totalPenjualan = setTotalJual();
                });
              } else {
                int index = getIndexBarang(db["NOINDEX"].toString());
                int qty = dataListShow[index]["QTY"] + 1;
                String idSatuan = db["IDSATUAN"];
                dynamic hargaUpdate = getHargaJual(data, idSatuan, qty);

                setState(() {
                  dataListShow[index]["IDSATUANPENGALI"] =
                      hargaUpdate["IDSATUANPENGALI"];
                  dataListShow[index]["QTY"] = qty;
                  dataListShow[index]["QTYSATUANPENGALI"] =
                      hargaUpdate["QTYSATUANPENGALI"];
                  dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
                  totalPenjualan = setTotalJual();
                });
              }
            }
          }, focus: false),
          actions: [
            IconButton(
                onPressed: () async {
                  String barcodeScanRes =
                      await FlutterBarcodeScanner.scanBarcode(
                          "#ff6666", "Cancel", true, ScanMode.BARCODE);
                  var resultData = await _getBarang(barcodeScanRes);
                  dynamic data = resultData["item"];
                  var db = data["detail_barang"][0];
                  if (!isBarangExists(db["NOINDEX"].toString())) {
                    setState(() {
                      dataListShow.add({
                        "IDBARANG": db["NOINDEX"].toString(),
                        "KODE": db["KODE"],
                        "NAMA": db["NAMA"],
                        "IDSATUAN": db["IDSATUAN"],
                        "SATUAN": db["KODE_SATUAN"],
                        "QTY": 1,
                        "HARGA": db["HARGA_JUAL"],
                        "DISKON_NOMINAL": 0,
                        "IDGUDANG": idGudang,
                        "IDSATUANPENGALI": db["IDSATUAN"],
                        "QTYSATUANPENGALI": 1
                      });
                      dataList.add(data);
                    });
                  } else {
                    int index = getIndexBarang(db["NOINDEX"].toString());
                    int qty = dataListShow[index]["QTY"] + 1;
                    String idSatuan = db["IDSATUAN"];
                    dynamic hargaUpdate = getHargaJual(data, idSatuan, qty);

                    setState(() {
                      dataListShow[index]["IDSATUANPENGALI"] =
                          hargaUpdate["IDSATUANPENGALI"];
                      dataListShow[index]["QTY"] = qty;
                      dataListShow[index]["QTYSATUANPENGALI"] =
                          hargaUpdate["QTYSATUANPENGALI"];
                      dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
                      totalPenjualan = setTotalJual();
                    });
                  }
                  totalPenjualan = setTotalJual();
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
            Expanded(flex: 0, child: Container()),
            Expanded(child: _listDataBarang()),
            Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.all(5),
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
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          children: [
                            Checkbox(
                                value: isKredit,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isKredit = value!;
                                    uangMukaCtrl.text = "0";
                                    idTop = "";
                                    topCtrl.text = "";
                                  });
                                }),
                            Text("Pembayaran Kredit"),
                          ],
                        ),
                      ),
                      KreditView(),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Table(
                          defaultColumnWidth: FlexColumnWidth(),
                          children: [
                            Utils.labelDuoSetter(
                                "Total", Utils.formatRp(totalPenjualan),
                                size: 19, isRight: true, bold: true)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            jumlahUangCtrl.text = "0";
                            double jumlahUang = jumlahUangSetter("0");
                            setState(() {
                              jumlahUangCtrl.text =
                                  jumlahUang.toStringAsFixed(0);
                              kembalian =
                                  calculateKembalian(jumlahUang.toString());
                              if (kembalian < 0) {
                                kembalianStatus = "KURANG";
                                kembalian = -kembalian;
                              } else {
                                kembalianStatus = "KEMBALIAN";
                              }
                            });

                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(builder:
                                      (context, StateSetter setStateIn) {
                                    return modalBayar(setStateIn);
                                  });
                                });
                          },
                          child:
                              Utils.labelSetter("BAYAR", color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
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
                              (Utils.labelSetter(data["KODE"])),
                              Utils.labelSetter(Utils.formatRp(data["HARGA"]),
                                  bold: true),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Utils.labelSetter(
                                      "Dic : " +
                                          Utils.formatRp(
                                              data["DISKON_NOMINAL"]),
                                      bold: false),
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
        });
  }

  Container KreditView() {
    if (isKredit) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelForm("Tempo Pembayaran"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: topCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "top",
                          );
                        },
                      ));

                      if (popUpResult == null) return;

                      topCtrl.text = popUpResult["NAMA"];
                      idTop = popUpResult["NOINDEX"];
                      namaTop = popUpResult["NAMA"];
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Utils.labelForm("Uang Muka"),
            TextField(controller: uangMukaCtrl)
          ],
        ),
      );
    }
    return Container();
  }

  dynamic getHargaJual(dynamic data, idSatuan, int qty) {
    List<dynamic> hargaTanggal = data["harga_tanggal"];
    List<dynamic> multiHarga = data["multi_harga"];
    List<dynamic> multiSatuan = data["multi_satuan"];
    List<dynamic> detailBarang = data["detail_barang"];

    dynamic tempResult;
    dynamic result;

    if (hargaTanggal.isNotEmpty) {
      result = null;
    }

    if (result == null) {
      if (multiHarga.isNotEmpty) {
        for (var d in multiHarga) {
          double qtyDari = d["DARI"];
          double qtyHingga = d["HINGGA"];
          if (d["IDSATUAN"] == idSatuan &&
              d["IDGOLONGAN"] == idGolonganPelanggan) {
            if (qty >= qtyDari && qty <= qtyHingga) {
              tempResult = d;
            }
          }
        }

        if (tempResult == null) {
          for (var d in multiHarga) {
            double qtyDari = d["DARI"];
            double qtyHingga = d["HINGGA"];
            if (d["IDSATUAN"] == idSatuan &&
                d["IDGOLONGAN"] == idGolongan2Pelanggan) {
              if (qty >= qtyDari && qty <= qtyHingga) {
                tempResult = d;
              }
            }
          }
        }

        if (tempResult != null) {
          String idSatuanPengali = tempResult["IDSATUANPENGALI"];
          double qtySatuanPengali = tempResult["QTYSATUANPENGALI"];
          double hargaJual = tempResult["HARGA_JUAL"];

          if (multiSatuan.isNotEmpty) {
            for (var mh in multiSatuan) {
              String idSatuanMh = mh["IDSATUAN"].toString();
              String idSatuanPengaliMh = mh["IDSATUANPENGALI"];
              double qtySatuanPengaliMh = mh["QTYSATUANPENGALI"];
              if (idSatuanMh == idSatuan) {
                idSatuanPengali = idSatuanPengaliMh;
                qtySatuanPengali = qtySatuanPengaliMh;
              }
            }
          }
          result = {
            "HARGA": hargaJual,
            "IDSATUANPENGALI": idSatuanPengali,
            "QTYSATUANPENGALI": qtySatuanPengali,
          };
        } else {
          result = null;
        }
      }
    }

    result ??= {
      "HARGA": detailBarang[0]["HARGA_JUAL"],
      "IDSATUANPENGALI": detailBarang[0]["IDSATUAN"],
      "QTYSATUANPENGALI": 1,
    };

    return result;
  }

  setTotalJual() {
    double result = 0;
    for (var d in dataListShow) {
      double total = (d["HARGA"] * d["QTY"]) - d["DISKON_NOMINAL"];
      result = result + total;
    }
    return result;
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

  double jumlahUangSetter(String jumlah) {
    double jumlahTambah = double.parse(jumlah);
    double currentJumlah = 0;
    try {
      currentJumlah = double.parse(jumlahUangCtrl.text);
    } catch (e) {
      currentJumlah = 0;
    }

    double hasil = currentJumlah + jumlahTambah;
    return hasil;
  }

  double calculateKembalian(String value) {
    if (value.isNotEmpty) {
      double jumlahUang = 0;

      double uangMuka = 0;
      try {
        uangMuka = double.parse(uangMukaCtrl.text);
      } catch (e) {
        uangMuka = 0;
      }

      try {
        jumlahUang = double.parse(value);
      } catch (e) {
        Utils.showMessage("Karakter harus angka", context);
        jumlahUang = 0;
      }
      double hasil = (jumlahUang + uangMuka) - totalPenjualan;
      return hasil;
    } else {
      return 0;
    }
  }

  SingleChildScrollView modalBayar(StateSetter setStateIn) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Pembayaran", size: 25),
            Padding(padding: EdgeInsets.all(20)),
            Text("TOTAL BELANJA"),
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(10),
              child: Utils.labelSetter(Utils.formatNumber(totalPenjualan),
                  size: 35,
                  bold: true,
                  align: TextAlign.right,
                  top: 0,
                  bottom: 0),
            ),
            Text(kembalianStatus),
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(10),
              child: Utils.labelSetter(Utils.formatNumber(kembalian),
                  size: 35,
                  bold: true,
                  align: TextAlign.right,
                  top: 0,
                  bottom: 0),
            ),
            Text("JUMLAH UANG"),
            Row(children: [
              Expanded(
                flex: 5,
                child: TextField(
                  controller: jumlahUangCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 30),
                  onChanged: (value) {
                    setStateIn(() {
                      kembalian = calculateKembalian(value);
                      if (kembalian < 0) {
                        kembalianStatus = "KURANG";
                        kembalian = -kembalian;
                      } else {
                        kembalianStatus = "KEMBALIAN";
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                    onPressed: () {
                      jumlahUangCtrl.text = "0";
                      double jumlahUang = jumlahUangSetter("0");
                      setStateIn(() {
                        jumlahUangCtrl.text = jumlahUang.toStringAsFixed(0);
                        kembalian = calculateKembalian(jumlahUang.toString());
                        if (kembalian < 0) {
                          kembalianStatus = "KURANG";
                          kembalian = -kembalian;
                        } else {
                          kembalianStatus = "KEMBALIAN";
                        }
                      });
                    },
                    icon: Icon(Icons.close)),
              )
            ]),
            SizedBox(height: 10),
            setBayarButton(setStateIn),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                  onPressed: () async {
                    int isTunai = 1;
                    if (isKredit) {
                      isTunai = 0;
                    }

                    if (isTunai == 0) {
                      double uangMuka = double.parse(uangMukaCtrl.text);
                      if (uangMuka > totalPenjualan) {
                        Utils.showMessage(
                            "Uang muka tidak boleh lebih besar dari total belanja",
                            context);
                        return;
                      }
                    }

                    if (isTunai == 1) {
                      if (kembalianStatus == "KURANG") {
                        Utils.showMessage(
                            "Pembayaran tidak cukup, transaksi tidak bisa diproses",
                            context);
                        return;
                      }
                    }

                    dynamic headerMap = {
                      "IDDEPT": idDept,
                      "KETERANGAN": keteranganCtrl.text,
                      "USERINPUT": Utils.idUser,
                      "TANGGAL": tanggalCtrl.text,
                      "IDPELANGGAN": idPelanggan,
                      "ISTUNAI": isTunai,
                      "DISKON_NOMINAL": 0,
                      "IDTOP": idTop,
                      "TOTAL_UANGMUKA": uangMukaCtrl.text
                    };
                    List<dynamic> detailList = [];

                    for (var dataMap in dataListShow) {
                      detailList.add({
                        "IDBARANG": dataMap["IDBARANG"],
                        "QTY": dataMap["QTY"],
                        "HARGA": dataMap["HARGA"],
                        "IDSATUAN": dataMap["IDSATUAN"],
                        "DISKON_NOMINAL": dataMap["DISKON_NOMINAL"],
                        "IDGUDANG": idGudang,
                        "IDSATUANPENGALI": dataMap["IDSATUANPENGALI"],
                        "QTYSATUANPENGALI": dataMap["QTYSATUANPENGALI"]
                      });
                    }
                    Map<String, Object> rootMap = {
                      "header": headerMap,
                      "detail": detailList
                    };
                    var result = await _postPenjualan(rootMap, "insert");
                    print(result);
                    if (result != null) {
                      if (result["status"] == 0) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Utils.labelSetter("Transaksi berhasil",
                                color: Colors.green, size: 20)));
                        setState(() {
                          dataList.clear();
                          dataListShow.clear();
                          totalPenjualan = setTotalJual();
                        });
                      } else {
                        Utils.showMessage(result["message"], context);
                      }
                    }
                  },
                  child: Text("SIMPAN")),
            )
          ],
        ),
      ),
    );
  }

  SingleChildScrollView modalEdit(dynamic data, int index) {
    TextEditingController jumlahCtrl = TextEditingController();
    TextEditingController diskonCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    satuanCtrl.text = data["SATUAN"];
    String idSatuan = data["IDSATUAN"];
    jumlahCtrl.text = data["QTY"].toString();
    diskonCtrl.text = data["DISKON_NOMINAL"].toString();
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          int jumlah = int.parse(jumlahText);
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
                            int jumlah = int.parse(jumlahText);
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
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "satuan",
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
                          int qty = int.parse(jumlahCtrl.text);
                          dynamic hargaUpdate =
                              getHargaJual(dataList[index], idSatuan, qty);
                          setState(() {
                            dataListShow[index]["IDSATUANPENGALI"] =
                                hargaUpdate["IDSATUANPENGALI"];
                            dataListShow[index]["QTY"] = qty;
                            dataListShow[index]["QTYSATUANPENGALI"] =
                                hargaUpdate["QTYSATUANPENGALI"];
                            dataListShow[index]["HARGA"] = hargaUpdate["HARGA"];
                            dataListShow[index]["IDSATUAN"] = idSatuan;
                            dataListShow[index]["SATUAN"] = satuanCtrl.text;
                            dataListShow[index]["DISKON_NOMINAL"] =
                                double.parse(diskonCtrl.text);

                            totalPenjualan = setTotalJual();
                            Navigator.pop(context);
                          });
                        },
                        child: Text("Simpan"))),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () async {
                          bool isDelete = await Utils.showConfirmMessage(
                              context, "Yakin ingin menghapus data ini ?");
                          if (isDelete) {
                            Navigator.pop(context);
                            setState(() {
                              dataList.removeAt(index);
                              dataListShow.removeAt(index);
                              setTotalJual();
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
    pelangganCtrl.text = namaPelanggan;
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
            Utils.labelForm("Pelanggan"),
            Row(
              children: [
                Expanded(
                    flex: 10,
                    child: TextField(
                      controller: pelangganCtrl,
                      enabled: false,
                    )),
                Expanded(
                  child: IconButton(
                    onPressed: () async {
                      dynamic popUpResult =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ListModalForm(
                            type: "pelanggan",
                          );
                        },
                      ));

                      if (popUpResult == null) return;
                      print(popUpResult);
                      pelangganCtrl.text = popUpResult["NAMA"];
                      idPelanggan = popUpResult["NOINDEX"];
                      namaPelanggan = popUpResult["NAMA"];
                      idGolonganPelanggan = popUpResult["IDGOLONGAN"];
                      idGolongan2Pelanggan = popUpResult["IDGOLONGAN2"];
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

  Wrap setBayarButton(StateSetter setStateIn) {
    List<String> listPecahan = ["5000", "10000", "20000", "50000", "100000"];
    List<Widget> lsButton = [];
    lsButton.add(
      OutlinedButton(
          onPressed: () {
            jumlahUangCtrl.text = "0";
            double jumlahUang = jumlahUangSetter(totalPenjualan.toString());
            setStateIn(() {
              jumlahUangCtrl.text = jumlahUang.toStringAsFixed(0);
              kembalian = calculateKembalian(jumlahUang.toString());
              if (kembalian < 0) {
                kembalianStatus = "KURANG";
                kembalian = -kembalian;
              } else {
                kembalianStatus = "KEMBALIAN";
              }
            });
          },
          child: Utils.labelSetter("UANG PAS", size: 20)),
    );
    for (String pecahan in listPecahan) {
      lsButton.add(
        OutlinedButton(
            onPressed: () {
              double jumlahUang = jumlahUangSetter(pecahan);
              setStateIn(() {
                jumlahUangCtrl.text = jumlahUang.toStringAsFixed(0);
                kembalian = calculateKembalian(jumlahUang.toString());
                if (kembalian < 0) {
                  kembalianStatus = "KURANG";
                  kembalian = -kembalian;
                } else {
                  kembalianStatus = "KEMBALIAN";
                }
              });
            },
            child: Utils.labelSetter(Utils.formatNumber(double.parse(pecahan)),
                size: 20)),
      );
    }
    ;
    return Wrap(
      spacing: 10,
      children: lsButton,
    );
  }
}
