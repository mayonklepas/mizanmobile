import 'dart:async';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/barang/list_barang.dart';
import 'package:mizanmobile/activity/hutang/list_hutang.dart';
import 'package:mizanmobile/activity/laporan/print_test.dart';
import 'package:mizanmobile/activity/laporan/summary/list_laba_bulanan.dart';
import 'package:mizanmobile/activity/laporan/summary/list_laba_harian.dart';
import 'package:mizanmobile/activity/laporan/summary/list_penjualan_bulanan.dart';
import 'package:mizanmobile/activity/laporan/summary/list_penjualan_harian.dart';
import 'package:mizanmobile/activity/pelanggan/list_pelanggan.dart';
import 'package:mizanmobile/activity/pembelian/list_pembelian.dart';
import 'package:mizanmobile/activity/penerimaan/list_penerimaan.dart';
import 'package:mizanmobile/activity/penjualan/list_penjualan.dart';
import 'package:mizanmobile/activity/piutang/list_piutang.dart';
import 'package:mizanmobile/activity/setup_connection.dart';
import 'package:mizanmobile/activity/setup_program.dart';
import 'package:mizanmobile/activity/setup_user.dart';
import 'package:mizanmobile/activity/stokopname/list_stokopname.dart';
import 'package:mizanmobile/activity/suplier/list_suplier.dart';
import 'package:mizanmobile/activity/transferbarang/list_tranferbarang.dart';
import 'package:mizanmobile/database_helper.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({Key? key}) : super(key: key);

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  Future<dynamic> _getHome() async {
    String urlString =
        "${Utils.mainUrl}home/daftar?tgl=${Utils.currentDateString()}&iddept=${Utils.idDept}";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData["data_home"];
  }

  Future<dynamic> _getInfoSync(String tglUpdate) async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    String urlString =
        "${Utils.mainUrl}barang/getitemsync?tglupdate=$tglUpdate&idgudang=${Utils.idGudang}";
    log(urlString);
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    return jsonData;
  }

  String koneksi = "";
  String localLastUpdate = "";
  bool sinkronisasiOnOff = false;
  String totalData = "0";

  _getInfoSyncLocal() async {
    var db = DatabaseHelper();
    List<dynamic> getInfo =
        await db.readDatabase("SELECT * FROM sync_info ORDER BY last_updated DESC LIMIT 1");
    List<dynamic> getInfoBarang =
        await db.readDatabase("SELECT COUNT(idbarang) as total FROM barang_temp");
    setState(() {
      localLastUpdate = getInfo[0]["last_updated"];
      sinkronisasiOnOff = (getInfo[0]["status"] == 1) ? true : false;
      totalData = Utils.formatNumber(getInfoBarang[0]["total"]);
    });
  }

  Container setIconCard(
      IconData icon, MaterialColor color, String label, void Function() tapAction) {
    return Container(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.only(top: 15),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              onTap: tapAction,
              child: Container(
                width: 75,
                height: 75,
                child: Icon(
                  icon,
                  color: color,
                  size: 50,
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            padding: EdgeInsets.only(top: 10),
            child: Utils.labelSetter(label, size: 13, bold: true, align: TextAlign.center),
          )
        ],
      ),
    );
  }

  _setupProgramChecked() {
    if (Utils.idDept.isEmpty || Utils.idGudang.isEmpty) {
      Future.delayed(Duration.zero, () {
        Utils.showMessageAction(
            "Anda harus melakukan setup program sebelum menggunakan aplikasi",
            context,
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SetupProgram();
                    },
                  ));
                },
                child: Text("Lakukan Setup")));
      });
    }
  }

  SingleChildScrollView _bottomSheetInfo(StateSetter stateIn) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Informasi Pengguna", bottom: 20, size: 20, bold: true),
            Utils.labelValueSetter("Pengguna", Utils.namaUser),
            Utils.labelValueSetter(
              "Nama Koneksi",
              Utils.connectionName,
              top: 10,
            ),
            Utils.labelValueSetter("Kode Outlet", Utils.companyCode, top: 10, bottom: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Ingin mengubah user dan password ?"),
                Padding(padding: EdgeInsets.all(3)),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return SetupUser();
                      },
                    ));
                  },
                  child: Text(
                    "Klik disini",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            Utils.labelSetter("Informasi Layanan", bottom: 10, top: 20, size: 20, bold: true),
            Utils.labelValueSetter("Mizan Mobile", "Aktif Sampai 21/05/2050",
                top: 10, colorValue: Colors.green),
            Utils.labelValueSetter("Mizan Desktop", "Aktif Sampai 21/05/2050",
                top: 10, colorValue: Colors.green),
            Utils.labelValueSetter("Mizan Cloud Backup", "Aktif Sampai 21/05/2050",
                colorValue: Colors.green, top: 10),
            Utils.labelValueSetter("Sinkronasisi Terakhir", localLastUpdate,
                colorValue: Colors.green, top: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      "Total Sinkronisasi",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    )),
                Expanded(
                    flex: 1,
                    child: Text(totalData,
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.green, fontSize: 14))),
                Expanded(
                    flex: 0,
                    child: IconButton(
                        onPressed: () async {
                          bool ya = await Utils.showConfirmMessage(context,
                              "Yakin ingin mereset data ? semua data sinkronisasi akan terhapus !");

                          if (ya == false) {
                            return;
                          }

                          Future.delayed(Duration.zero, () => Utils.showProgress(context));
                          String harikemerdekaaan = "1945-08-17 00:00:00";
                          await DatabaseHelper().writeDatabase(
                              "UPDATE sync_info SET last_updated = ? ",
                              params: [harikemerdekaaan]);
                          await DatabaseHelper().writeDatabase("DELETE FROM barang_temp");
                          stateIn(() {
                            localLastUpdate = harikemerdekaaan;
                            totalData = "0";
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.refresh))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sinkronisasi otomatis"),
                Switch(
                    value: sinkronisasiOnOff,
                    onChanged: (value) async {
                      int status = 0;
                      if (value == true) {
                        status = 1;
                      }
                      await DatabaseHelper()
                          .writeDatabase("UPDATE sync_info SET status = ? ", params: [status]);
                      stateIn(() => sinkronisasiOnOff = value);
                    })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Ingin mengaktifkan layanan ?"),
                Padding(padding: EdgeInsets.all(3)),
                InkWell(
                  onTap: () async {
                    if (!await launch("https://wa.me/6281805754534")) {
                      throw Exception("Tidak bisa membuka url");
                    }
                  },
                  child: Text(
                    "Hubungi kami",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Logout"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent)))
          ],
        ),
      ),
    );
  }

  double penjualanHarian = 0;
  double penjualanBulanan = 0;
  double labaHarian = 0;
  double labaBulanan = 0;

  setDataHome() async {
    dynamic data = await _getHome();
    setState(() {
      penjualanHarian = data["PENJUALAN_HARIAN"] ?? 0;
      penjualanBulanan = data["PENJUALAN_BULANAN"] ?? 0;
      labaHarian = data["LABA_HARIAN"] ?? 0;
      labaBulanan = data["LABA_BULANAN"] ?? 0;
    });
  }

  periodicTask() {
    Timer.periodic(Duration(minutes: 3), (timer) async {
      var db = DatabaseHelper();
      List<dynamic> lsSyncInfo = await db.readDatabase("SELECT * FROM sync_info WHERE id=1");
      int status = lsSyncInfo[0]["status"];
      if (status == 0) {
        log("no active sync");
      }
      log("process sync-task");
      await Utils.syncLocalData();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    periodicTask();
    setDataHome();
    _getInfoSyncLocal();
    koneksi = Utils.connectionName;
    _setupProgramChecked();
    super.initState();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(50, 20),
          )),
          toolbarHeight: 90,
          flexibleSpace: Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  flex: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return PrintTest();
                        },
                      ));
                    },
                    child: Image.network(
                      Utils.imageUrl + "logo.png",
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mizan Mobile",
                          style: TextStyle(
                              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          koneksi,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 0,
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext contenxt) {
                                        return StatefulBuilder(
                                            builder: (context, StateSetter setStateIn) {
                                          return _bottomSheetInfo(setStateIn);
                                        });
                                      });
                                },
                                icon: Icon(
                                  Icons.account_circle,
                                  size: 40,
                                  color: Colors.white,
                                )),
                          ],
                        )))
              ],
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 1,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "HALO " + Utils.namaUser,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          penjualanHarian = 0;
                          penjualanBulanan = 0;
                          labaHarian = 0;
                          labaBulanan = 0;
                          _getInfoSyncLocal();
                        });
                        dynamic data = await _getHome();
                        setState(() {
                          penjualanHarian = data["PENJUALAN_HARIAN"] ?? 0;
                          penjualanBulanan = data["PENJUALAN_BULANAN"] ?? 0;
                          labaHarian = data["LABA_HARIAN"] ?? 0;
                          labaBulanan = data["LABA_BULANAN"] ?? 0;
                        });
                      },
                      child: Text("Refresh Home"))
                ],
              ),
              padding: EdgeInsets.all(5),
            ),
            CarouselSlider(
              options: CarouselOptions(aspectRatio: 2.5, viewportFraction: 0.9),
              items: [
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListPenjualanHarian();
                            },
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total penjualan hari ini",
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  Utils.formatNumber(penjualanHarian),
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                ),
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListPenjualanBulanan();
                            },
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total penjualan bulan ini",
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  Utils.formatNumber(penjualanBulanan),
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                ),
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListLabaHarian();
                            },
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total laba hari ini",
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  Utils.formatNumber(labaHarian),
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                ),
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ListLabaBulanan();
                            },
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total laba bulan ini",
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  Utils.formatNumber(labaBulanan),
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                )
              ],
            ),
            Container(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Data Master",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                )),
            Container(
                child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.75),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                setIconCard(Icons.inventory, Colors.blue, "Barang", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListBarang();
                    },
                  ));
                }),
                setIconCard(Icons.supervised_user_circle, Colors.blue, "Pelanggan", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListPelanggan();
                    },
                  ));
                }),
                setIconCard(Icons.supervisor_account, Colors.blue, "Suplier", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListSuplier();
                    },
                  ));
                }),
              ],
            )),
            Container(
                child: Text(
              "Transaksi",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
            )),
            Container(
                child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.75),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                setIconCard(Icons.shopping_cart, Colors.blue, "Penjualan", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListPenjualan();
                    },
                  ));
                }),
                setIconCard(Icons.playlist_add, Colors.blue, "Piutang Usaha", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListPiutang();
                    },
                  ));
                }),
                setIconCard(Icons.assignment, Colors.blue, "Penerimaan Barang", () {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: Text("Informasi"),
                          content: Text("Fitur dalam pengerjaan"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"))
                          ],
                        );
                      });
                }),
                setIconCard(Icons.add_shopping_cart, Colors.blue, "Pembelian", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListPembelian();
                    },
                  ));
                }),
                setIconCard(Icons.playlist_remove_outlined, Colors.blue, "Hutang Usaha", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListHutang();
                    },
                  ));
                }),
                setIconCard(Icons.find_in_page, Colors.blue, "Stok Opname", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListStokOpname();
                    },
                  ));
                }),
                setIconCard(Icons.upload_file_outlined, Colors.blue, "Transfer Barang", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ListTransferBarang();
                    },
                  ));
                }),
              ],
            )),
            Container(
                child: Text(
              "Lainnya",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
            )),
            Container(
                child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.7),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                setIconCard(Icons.print_outlined, Colors.blue, "Laporan", () {}),
                setIconCard(Icons.settings, Colors.blue, "Setup Program", () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SetupProgram();
                    },
                  ));
                }),
                setIconCard(Icons.sync, Colors.blue, "Sinkronisasi", () async {
                  String tglSet = localLastUpdate;

                  dynamic itemSyncInfo = await _getInfoSync(tglSet);
                  int jumlahItem = itemSyncInfo["jumlah_item_sync"];

                  bool isConfirm = await Utils.showConfirmMessage(context,
                      "Jumlah item yang akan di sinkronisasi adalah ${Utils.formatNumber(jumlahItem)}, Lanjutkan ?");

                  if (!isConfirm) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    return;
                  }

                  Future.delayed(Duration.zero, () => Utils.showProgress(context));
                  await Utils.syncLocalData();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Sinkronisasi Berhasil")));

                  _getInfoSyncLocal();
                }),
              ],
            )),
          ],
        ));
  }
}
