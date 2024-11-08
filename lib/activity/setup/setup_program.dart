import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/utility/list_device.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProgram extends StatefulWidget {
  const SetupProgram({super.key});

  @override
  State<SetupProgram> createState() => _SetupProgramState();
}

class _SetupProgramState extends State<SetupProgram> {
  TextEditingController gudangCtrl = TextEditingController();
  String idGudang = "";
  TextEditingController deptCtrl = TextEditingController();
  String idDept = "";
  TextEditingController akunStokOpnameCtrl = TextEditingController();
  String idAkunStokOpname = "";
  TextEditingController namaPelangganCtrl = TextEditingController();
  String idPelanggan = "";
  String kodePelanggan = "";
  String idGolonganPelanggan = "";
  String idGolongan2Pelanggan = "";
  TextEditingController namaKelompokCtrl = TextEditingController();
  String idKelompok = "";
  TextEditingController satuanCtrl = TextEditingController();
  String idSatuan = "";
  TextEditingController namaLokasiCtrl = TextEditingController();
  String idLokasi = "";
  TextEditingController bluetoothDeviceCtrl = TextEditingController();
  String idBluetoothDevice = "";
  bool isPdtMode = false;
  String isPdtModevalue = "0";
  bool isShowStockProgram = false;
  String isShowStockProgramValue = "0";
  TextEditingController footerStrukCtrl = TextEditingController();
  TextEditingController headerStrukCtrl = TextEditingController();
  TextEditingController strukListFormatCtrl = TextEditingController();
  bool isShowDialogAfterSavePenjualan = false;
  String isShowDialogAfterSavePenjualanValue = "0";

  _loadSetupProgram() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      dynamic mapSetup = jsonDecode(sp.getString(Utils.connectionName).toString());
      idDept = mapSetup["defaultIdDept"] ?? "";
      deptCtrl.text = mapSetup["defaultNamaDept"] ?? "";
      idAkunStokOpname = mapSetup["defaultIdAkunStokOpname"] ?? "";
      akunStokOpnameCtrl.text = mapSetup["defaultNamaAkunStokOpname"] ?? "";
      idGudang = mapSetup["defaultIdGudang"] ?? "";
      gudangCtrl.text = mapSetup["defaultNamaGudang"] ?? "";
      idPelanggan = mapSetup["defaultIdPelanggan"] ?? "";
      idGolonganPelanggan = mapSetup["defaultIdGolonganPelanggan"] ?? "";
      idGolongan2Pelanggan = mapSetup["defaultIdGolongan2Pelanggan"] ?? "";
      namaPelangganCtrl.text = mapSetup["defaultNamaPelanggan"] ?? "";
      kodePelanggan = mapSetup["defaultKodePelanggan"] ?? "";
      idLokasi = mapSetup["defaultIdLokasi"] ?? "";
      namaLokasiCtrl.text = mapSetup["defaultNamaLokasi"] ?? "";
      satuanCtrl.text = mapSetup["defaultSatuan"] ?? "";
      idSatuan = mapSetup["defaultIdSatuan"] ?? "";
      idKelompok = mapSetup["defaultIdKelompok"] ?? "";
      namaKelompokCtrl.text = mapSetup["defaultNamaKelompok"] ?? "";
      bluetoothDeviceCtrl.text = mapSetup["defaultBluetoothDevice"] ?? "";
      idBluetoothDevice = mapSetup["defaultIdBluetoothDevice"] ?? "";
      strukListFormatCtrl.text = mapSetup["defaultStrukListFormat"] ?? "";
      isPdtModevalue = mapSetup["defaultIsPdtMode"] ?? "0";
      if (isPdtModevalue == "1") {
        isPdtMode = true;
      }

      isShowStockProgramValue = mapSetup["defaultIsShowStockProgram"] ?? "0";
      if (isShowStockProgramValue == "1") {
        isShowStockProgram = true;
      }

      isShowDialogAfterSavePenjualanValue =
          mapSetup["defaultIsShowDialogAfterSavePenjualan"] ?? "0";
      if (isShowDialogAfterSavePenjualanValue == "1") {
        isShowDialogAfterSavePenjualan = true;
      }

      headerStrukCtrl.text = mapSetup["defaultHeaderStruk"] ?? "";
      footerStrukCtrl.text = mapSetup["defaultFooterStruk"] ?? "";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSetupProgram();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup Program"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Utils.labelForm("Department"),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: TextField(
                          controller: deptCtrl,
                          enabled: false,
                        )),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListModalForm(
                                type: "dept",
                                withAll: true,
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idDept = popUpResult["NOINDEX"].toString();
                          deptCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
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
                                withAll: true,
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idGudang = popUpResult["NOINDEX"];
                          gudangCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                Utils.labelForm("Akun Stok Opname"),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: TextField(
                          controller: akunStokOpnameCtrl,
                          enabled: false,
                        )),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListModalForm(
                                type: "akun",
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idAkunStokOpname = popUpResult["NOINDEX"];
                          akunStokOpnameCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                Utils.labelForm("Pelanggan Umum"),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: TextField(
                          controller: namaPelangganCtrl,
                          enabled: false,
                        )),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListModalForm(
                                type: "pelanggan",
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idPelanggan = popUpResult["NOINDEX"];
                          kodePelanggan = popUpResult["KODE"];
                          idGolonganPelanggan = popUpResult["IDGOLONGAN"];
                          idGolongan2Pelanggan = popUpResult["IDGOLONGAN2"];
                          namaPelangganCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                Utils.labelForm("Kelompok"),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: TextField(
                          controller: namaKelompokCtrl,
                          enabled: false,
                        )),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListModalForm(
                                type: "kelompokbarang",
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idKelompok = popUpResult["NOINDEX"];
                          namaKelompokCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
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
                                type: "satuan",
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idSatuan = popUpResult["NOINDEX"];
                          satuanCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                Utils.labelForm("Lokasi"),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: TextField(
                          controller: namaLokasiCtrl,
                          enabled: false,
                        )),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListModalForm(
                                type: "lokasi",
                                withAll: true,
                              );
                            },
                          ));

                          if (popUpResult == null) return;

                          idLokasi = popUpResult["NOINDEX"];
                          namaLokasiCtrl.text = popUpResult["NAMA"];
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                Utils.labelForm("Bluetooth Printer"),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: TextField(
                          controller: bluetoothDeviceCtrl,
                          enabled: false,
                        )),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListModalDevice();
                            },
                          ));

                          if (popUpResult == null) return;
                          idBluetoothDevice = popUpResult["id"];
                          setState(() {
                            bluetoothDeviceCtrl.text = popUpResult["name"];
                          });
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(5)),
                Utils.labelForm("Struk List Format ex: (-20,6,11)"),
                TextField(
                  controller: strukListFormatCtrl,
                  enabled: true,
                ),
                Padding(padding: EdgeInsets.all(5)),
                Row(
                  children: [
                    Checkbox(
                      value: isPdtMode,
                      onChanged: (bool? value) {
                        setState(() {
                          isPdtMode = value!;
                          if (value == true) {
                            isPdtModevalue = "1";
                          } else {
                            isPdtModevalue = "0";
                          }
                        });
                      },
                    ),
                    Text("Gunakan Mode PDT"),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isShowStockProgram,
                      onChanged: (bool? value) {
                        setState(() {
                          isShowStockProgram = value!;
                          if (value == true) {
                            isShowStockProgramValue = "1";
                          } else {
                            isShowStockProgramValue = "0";
                          }
                        });
                      },
                    ),
                    Text("Tampilkan Stok Program"),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isShowDialogAfterSavePenjualan,
                      onChanged: (bool? value) {
                        setState(() {
                          isShowDialogAfterSavePenjualan = value!;
                          if (value == true) {
                            isShowDialogAfterSavePenjualanValue = "1";
                          } else {
                            isShowDialogAfterSavePenjualanValue = "0";
                          }
                        });
                      },
                    ),
                    Text("Tampilkan Dialog Setelah Simpan Penjualan"),
                  ],
                ),
                Utils.labelForm("Header Struk"),
                TextField(
                  controller: headerStrukCtrl,
                ),
                Utils.labelForm("Footer Struk"),
                TextField(
                  controller: footerStrukCtrl,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        Map<String, String> mapSetup = {
                          "defaultIdDept": idDept,
                          "defaultNamaDept": deptCtrl.text,
                          "defaultIdGudang": idGudang,
                          "defaultNamaGudang": gudangCtrl.text,
                          "defaultIdAkunStokOpname": idAkunStokOpname,
                          "defaultNamaAkunStokOpname": akunStokOpnameCtrl.text,
                          "defaultIdPelanggan": idPelanggan,
                          "defaultNamaPelanggan": namaPelangganCtrl.text,
                          "defaultKodePelanggan": kodePelanggan,
                          "defaultIdGolonganPelanggan": idGolonganPelanggan,
                          "defaultIdGolongan2Pelanggan": idGolonganPelanggan,
                          "defaultIdKelompok": idKelompok,
                          "defaultNamaKelompok": namaKelompokCtrl.text,
                          "defaultIdSatuan": idSatuan,
                          "defaultSatuan": satuanCtrl.text,
                          "defaultIdLokasi": idLokasi,
                          "defaultNamaLokasi": namaLokasiCtrl.text,
                          "defaultBluetoothDevice": bluetoothDeviceCtrl.text,
                          "defaultIdBluetoothDevice": idBluetoothDevice,
                          "defaultIsPdtMode": isPdtModevalue,
                          "defaultIsShowStockProgram": isShowStockProgramValue,
                          "defaultIsShowDialogAfterSavePenjualan":
                              isShowDialogAfterSavePenjualanValue,
                          "defaultHeaderStruk": headerStrukCtrl.text,
                          "defaultFooterStruk": footerStrukCtrl.text,
                          "defaultStrukListFormat": strukListFormatCtrl.text
                        };

                        String jsonSetup = jsonEncode(mapSetup);

                        SharedPreferences sp = await SharedPreferences.getInstance();
                        sp.setString(Utils.connectionName, jsonSetup);

                        setState(() {
                          Utils.idDept = idDept;
                          Utils.namaDept = deptCtrl.text;
                          Utils.idGudang = idGudang;
                          Utils.namaGudang = gudangCtrl.text;
                          Utils.idAkunStokOpname = idAkunStokOpname;
                          Utils.namaAkunStokOpname = akunStokOpnameCtrl.text;
                          Utils.idPelanggan = idPelanggan;
                          Utils.kodePelanggan = kodePelanggan;
                          Utils.idGolonganPelanggan = idGolonganPelanggan;
                          Utils.idGolongan2Pelanggan = idGolongan2Pelanggan;
                          Utils.namaPelanggan = namaPelangganCtrl.text;
                          Utils.idKelompok = idKelompok;
                          Utils.namaKelompok = namaKelompokCtrl.text;
                          Utils.idLokasi = idLokasi;
                          Utils.namaLokasi = namaLokasiCtrl.text;
                          Utils.idSatuan = idSatuan;
                          Utils.satuan = satuanCtrl.text;
                          Utils.bluetoothId = idBluetoothDevice;
                          Utils.bluetoothName = bluetoothDeviceCtrl.text;
                          Utils.isPdtMode = isPdtModevalue;
                          Utils.isShowStockProgram = isShowStockProgramValue;
                          Utils.isShowDialogAfterSavePenjualan =
                              isShowDialogAfterSavePenjualanValue;
                          Utils.footerStruk = footerStrukCtrl.text;
                          Utils.headerStruk = headerStrukCtrl.text;
                          Utils.strukListFormat = strukListFormatCtrl.text;
                        });
                        sp.reload();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Berhasil disimpan")));
                      },
                      child: Text("Simpan")),
                )
              ]),
        ),
      ),
    );
  }
}
