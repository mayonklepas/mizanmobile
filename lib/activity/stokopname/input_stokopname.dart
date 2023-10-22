import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/utility/list_modal_barang.dart';

import '../../utils.dart';
import 'package:http/http.dart';

import '../utility/list_modal_form.dart';

class InputStokOpname extends StatefulWidget {
  final String idTransaksi;
  const InputStokOpname({Key? key, required this.idTransaksi}) : super(key: key);

  @override
  State<InputStokOpname> createState() => _InputStokOpnameState();
}

class _InputStokOpnameState extends State<InputStokOpname> {
  TextEditingController gudangCtrl = TextEditingController();
  String idGudang = Utils.idGudang;
  String namaGudang = Utils.namaGudang;
  String tanggalTransaksi = Utils.currentDateString();
  String idTransaksiGlobal = "";
  String norefGlobal = "";
  String keterangan = "";

  TextEditingController akunOpnameCtrl = TextEditingController();
  String idAkunOpname = Utils.idAkunStokOpname;
  String namaAkunOpname = Utils.namaAkunStokOpname;

  String idDept = Utils.idDept;
  String namaDept = Utils.namaDept;

  late Container listContainer = Container();
  dynamic globalResultData = {};

  Future<dynamic> _getStokOpname(String idTransaksi) async {
    String urlString = "${Utils.mainUrl}stokopname/rincian?idgenjur=$idTransaksi";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData;
  }

  Future<dynamic> _postStokOpname(Map<String, Object> postBody, urlPath) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString = "${Utils.mainUrl}stokopname/" + urlPath;
    Uri url = Uri.parse(urlString);
    Response response = await post(url, body: jsonEncode(postBody), headers: Utils.setHeader());
    log(url.toString());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body);
    Navigator.pop(context);
    return jsonData;
  }

  @override
  void initState() {
    // TODO: implement initState
    _setStokOpname(idTransaksi: widget.idTransaksi);
    super.initState();
  }

  _setStokOpname({String idTransaksi = "", dynamic defaultResult = null}) async {
    dynamic resultData = null;

    if (defaultResult == null) {
      if (idTransaksi == "") {
        listContainer = Container();
        return;
      }
      idTransaksiGlobal = idTransaksi;
      resultData = await _getStokOpname(idTransaksi);
      globalResultData = resultData;
    } else {
      resultData = defaultResult;
      globalResultData = resultData;
    }

    dynamic header = resultData["header"];
    List<dynamic> detail = resultData["detail"];
    setState(() {
      norefGlobal = header["NOREF"];
      namaGudang = header["NAMA_GUDANG"];
      idGudang = header["IDGUDANG"];
      namaAkunOpname = header["NAMA_AKUN"];
      idAkunOpname = header["KODE_AKUN"];
      tanggalTransaksi = header["TANGGAL"];
      keterangan = header["KETERANGAN"];
      listContainer = Container(
        child: ListView.builder(
            itemCount: detail.length,
            itemBuilder: (BuildContext context, int index) {
              dynamic data = detail[index];
              return Container(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext content) {
                            return Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              height: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                            showModalInputDetail(param: data);
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
                                            Map<String, Object> mapData = {
                                              "idgenjur": idTransaksiGlobal,
                                              "noindex": data["NOINDEX"]
                                            };
                                            dynamic result =
                                                await _postStokOpname(mapData, "deletedetail");
                                            if (result["status"] == 0) {
                                              _setStokOpname(defaultResult: result["data"]);
                                            }
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
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
                            );
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
                                  Utils.labelSetter(data["NAMA_BARANG"], bold: true),
                                  Utils.labelSetter(data["KODE_BARANG"]),
                                  Utils.labelValueSetter(
                                    "Stok Program",
                                    Utils.formatNumber(data["STOK_PROGRAM"]) +
                                        " " +
                                        data["KODE_SATUAN"],
                                  ),
                                  Utils.labelValueSetter(
                                    "Stok Fisik",
                                    Utils.formatNumber(data["STOK_FISIK"]) +
                                        " " +
                                        data["KODE_SATUAN"],
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
            }),
      );
    });
  }

  Future<dynamic> showModalInputDetail({dynamic param = null}) {
    TextEditingController kodeBarangCtrl = TextEditingController();
    TextEditingController namaBarangCtrl = TextEditingController();
    TextEditingController satuanCtrl = TextEditingController();
    TextEditingController stokProgramCtrl = TextEditingController();
    TextEditingController stokFisikCtrl = TextEditingController();
    TextEditingController selisihStokCtrl = TextEditingController();

    dynamic popUpResult;
    String idBarang = "";
    String idSatuan = "";
    String idSatuanPengali = "";
    double qtySatuanPengali = 1;
    String noIndex = "";
    String inputType = "Tambah Barang";

    if (param != null) {
      noIndex = param["NOINDEX"];
      kodeBarangCtrl.text = param["KODE_BARANG"];
      namaBarangCtrl.text = param["NAMA_BARANG"];
      idBarang = param["IDBARANG"];
      satuanCtrl.text = param["KODE_SATUAN"];
      idSatuan = param["IDSATUAN"];
      idSatuanPengali = param["IDSATUANPENGALI"];
      qtySatuanPengali = param["QTYSATUANPENGALI"];
      stokFisikCtrl.text = Utils.formatNumber(param["STOK_FISIK"]);
      stokProgramCtrl.text = Utils.formatNumber(param["STOK_PROGRAM"]);
      selisihStokCtrl.text = Utils.formatNumber(param["JUMLAH"]);
      inputType = "Edit Barang";
    }
    return showModalBottomSheet(
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
                  Utils.labelSetter(inputType, size: 25),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Kode Barang"),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: kodeBarangCtrl,
                        enabled: false,
                      )),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalBarang();
                              },
                            ));

                            if (popUpResult == null) return;

                            log(popUpResult.toString());
                            kodeBarangCtrl.text = popUpResult["KODE"];
                            namaBarangCtrl.text = popUpResult["NAMA"];
                            idBarang = popUpResult["NOINDEX"];
                            satuanCtrl.text = popUpResult["KODE_SATUAN"];
                            idSatuan = popUpResult["IDSATUAN"];
                            idSatuanPengali = popUpResult["IDSATUAN"];
                            stokProgramCtrl.text = Utils.formatNumber(popUpResult["STOK"]);
                            qtySatuanPengali = 1;
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                                "#ff6666", "Cancel", true, ScanMode.BARCODE);

                            log(barcodeScanRes);

                            if (barcodeScanRes == "-1") return;

                            List<dynamic> result = await Utils.getDataBarangByCode(barcodeScanRes);

                            if (result.length == 1) {
                              popUpResult = result[0];
                            } else if (result.length > 1) {
                              popUpResult = await Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ListModalBarang(
                                    keyword: barcodeScanRes,
                                  );
                                },
                              ));
                            } else {
                              Utils.showMessage("Data tidak ditemukan", context);
                              popUpResult = null;
                            }

                            if (popUpResult == null) return;

                            kodeBarangCtrl.text = popUpResult["KODE"];
                            namaBarangCtrl.text = popUpResult["NAMA"];
                            idBarang = popUpResult["NOINDEX"];
                            satuanCtrl.text = popUpResult["KODE_SATUAN"];
                            idSatuan = popUpResult["IDSATUAN"];
                            idSatuanPengali = popUpResult["IDSATUAN"];
                            stokProgramCtrl.text = Utils.formatNumber(popUpResult["STOK"]);
                            qtySatuanPengali = 1;
                          },
                          icon: Icon(Icons.qr_code_scanner),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Nama Barang"),
                  TextField(
                    enabled: false,
                    controller: namaBarangCtrl,
                  ),
                  Utils.labelForm("Satuan"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: satuanCtrl,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          onPressed: () async {
                            popUpResult = await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ListModalForm(
                                  type: "satuanbarang",
                                  idBarang: idBarang,
                                );
                              },
                            ));

                            if (popUpResult == null) return;
                            satuanCtrl.text = popUpResult["NAMA"];
                            idSatuan = popUpResult["NOINDEX"];
                            qtySatuanPengali = popUpResult["QTYSATUANPENGALI"];
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  Utils.labelForm("Stok Program"),
                  TextField(
                    controller: stokProgramCtrl,
                    enabled: false,
                    keyboardType: TextInputType.number,
                  ),
                  Utils.labelForm("Stok Fisik"),
                  TextField(
                    controller: stokFisikCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      double stokProgram =
                          double.parse(Utils.removeDotSeparator(stokProgramCtrl.text));
                      double stokFisik = double.parse(value);
                      double selisih = stokFisik - stokProgram;
                      selisihStokCtrl.text = Utils.formatNumber(selisih);
                    },
                  ),
                  Utils.labelForm("Selisih"),
                  TextField(
                    enabled: false,
                    controller: selisihStokCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (stokFisikCtrl.text == "") {
                              Utils.showMessage("Stok fisik tidak boleh kosong", context);
                              return;
                            }

                            if (param == null) {
                              if (globalResultData["detail"] != null) {
                                List<dynamic> detail = globalResultData["detail"];
                                for (var d in detail) {
                                  if (d["IDBARANG"] == idBarang) {
                                    Utils.showMessage("Barang Sudah ada di daftar", context);
                                    return;
                                  }
                                }
                              }
                            }

                            Map<String, Object> mapData = {};
                            dynamic result;
                            if (param != null) {
                              mapData = {
                                "noindex": noIndex,
                                "idgenjur": idTransaksiGlobal,
                                "idgudang": idGudang,
                                "kodeakun": idAkunOpname,
                                "idbarang": idBarang,
                                "idsatuan": idSatuan,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": qtySatuanPengali,
                                "stokprogram":
                                    double.parse(Utils.removeDotSeparator(stokProgramCtrl.text)),
                                "stokfisik":
                                    double.parse(Utils.removeDotSeparator(stokFisikCtrl.text)),
                                "jumlah":
                                    double.parse(Utils.removeDotSeparator(selisihStokCtrl.text)),
                              };
                              result = await _postStokOpname(mapData, "editdetail");
                            } else {
                              mapData = {
                                "idgenjur": idTransaksiGlobal,
                                "idgudang": idGudang,
                                "kodeakun": idAkunOpname,
                                "idbarang": idBarang,
                                "idsatuan": idSatuan,
                                "idsatuanpengali": idSatuanPengali,
                                "qtysatuanpengali": qtySatuanPengali,
                                "stokprogram":
                                    double.parse(Utils.removeDotSeparator(stokProgramCtrl.text)),
                                "stokfisik":
                                    double.parse(Utils.removeDotSeparator(stokFisikCtrl.text)),
                                "jumlah":
                                    double.parse(Utils.removeDotSeparator(selisihStokCtrl.text)),
                              };
                              result = await _postStokOpname(mapData, "insertdetail");
                            }
                            Navigator.pop(context);
                            _setStokOpname(defaultResult: result["data"]);
                          },
                          child: Text("Simpan")))
                ],
              ),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (idTransaksiGlobal == "") {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Input Informasi Terlebih Dahulu")));
          } else {
            showModalInputDetail();
          }
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      appBar: AppBar(
        title: Text("Input Stok Opname"),
        actions: [
          IconButton(
              onPressed: () {
                TextEditingController tanggalCtrl = TextEditingController();
                TextEditingController keteranganCtrl = TextEditingController();
                TextEditingController deptCtrl = TextEditingController();
                deptCtrl.text = namaDept;
                tanggalCtrl.text = tanggalTransaksi;
                gudangCtrl.text = namaGudang;
                keteranganCtrl.text = keterangan;
                akunOpnameCtrl.text = namaAkunOpname;
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
                              Utils.labelForm("Akun Opname"),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 10,
                                      child: TextField(
                                        controller: akunOpnameCtrl,
                                        enabled: false,
                                      )),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () async {
                                        dynamic popUpResult =
                                            await Navigator.push(context, MaterialPageRoute(
                                          builder: (context) {
                                            return ListModalForm(
                                              type: "akun",
                                            );
                                          },
                                        ));

                                        if (popUpResult == null) return;

                                        akunOpnameCtrl.text = popUpResult["NAMA"];
                                        idAkunOpname = popUpResult["NOINDEX"];
                                        namaAkunOpname = popUpResult["NAMA"];
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
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        Map<String, Object> mapData = {};
                                        dynamic result;
                                        if (idTransaksiGlobal != "") {
                                          mapData = {
                                            "noindex": idTransaksiGlobal,
                                            "noref": norefGlobal,
                                            "iddept": idDept,
                                            "tanggal": tanggalCtrl.text,
                                            "keterangan": keteranganCtrl.text,
                                            "useredit": Utils.idUser,
                                          };
                                          result = await _postStokOpname(mapData, "editheader");
                                        } else {
                                          mapData = {
                                            "iddept": idDept,
                                            "tanggal": tanggalCtrl.text,
                                            "keterangan": keteranganCtrl.text,
                                            "userinput": Utils.idUser
                                          };
                                          result = await _postStokOpname(mapData, "insertheader");
                                        }

                                        idTransaksiGlobal = result["data"]["NOINDEX"];
                                        setState(() {
                                          norefGlobal = result["data"]["NOREF"];
                                          namaGudang = gudangCtrl.text;
                                          namaAkunOpname = akunOpnameCtrl.text;
                                          tanggalTransaksi = result["data"]["TANGGAL"];
                                          keterangan = result["data"]["KETERANGAN"];
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text("Simpan")))
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.note_add_rounded))
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
                flex: 0,
                child: Container(
                  child: Card(
                    elevation: 2,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Utils.labelValueSetter(
                            "No Transaksi",
                            norefGlobal,
                          ),
                          Utils.labelValueSetter(
                            "Tanggal Transaksi",
                            Utils.formatDate(tanggalTransaksi),
                          ),
                          Utils.labelValueSetter(
                            "Departmen",
                            namaDept,
                          ),
                          Utils.labelValueSetter("Gudang", namaGudang),
                          Utils.labelValueSetter("Akun Opname", namaAkunOpname),
                          Utils.labelValueSetter(
                            "Keterangan",
                            keterangan,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Expanded(child: listContainer)
          ],
        ),
      ),
    );
  }
}
