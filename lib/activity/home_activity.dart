import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/barang/list_barang.dart';
import 'package:mizanmobile/activity/hutang/list_hutang.dart';
import 'package:mizanmobile/activity/pelanggan/list_pelanggan.dart';
import 'package:mizanmobile/activity/pembelian/list_pembelian.dart';
import 'package:mizanmobile/activity/penerimaan/list_penerimaan.dart';
import 'package:mizanmobile/activity/penjualan/list_penjualan.dart';
import 'package:mizanmobile/activity/piutang/list_piutang.dart';
import 'package:mizanmobile/activity/setup_connection.dart';
import 'package:mizanmobile/activity/setup_program.dart';
import 'package:mizanmobile/activity/stokopname/list_stokopname.dart';
import 'package:mizanmobile/activity/suplier/list_suplier.dart';
import 'package:mizanmobile/activity/transferbarang/list_tranferbarang.dart';
import 'package:mizanmobile/utils.dart';
import 'package:http/http.dart';
import 'dart:convert';

class HomeActivity extends StatefulWidget {
  const HomeActivity({Key? key}) : super(key: key);

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  Future<dynamic> _getHome() async {
    String urlString = "${Utils.mainUrl}home/daftar";
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData["data_home"];
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
    String idDept = Utils.idDept;
    if (idDept == "null") {
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
    }
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

  @override
  void initState() {
    // TODO: implement initState
    setDataHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Image.network(
                    Utils.imageUrl + "logo.png",
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Mizan Mobile",
                      style:
                          TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
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
                        dynamic data = await _getHome();
                        setState(() {
                          penjualanHarian = data["PENJUALAN_HARIAN"] ?? 0;
                          penjualanBulanan = data["PENJUALAN_BULANAN"] ?? 0;
                          labaHarian = data["LABA_HARIAN"] ?? 0;
                          labaBulanan = data["LABA_BULANAN"] ?? 0;
                        });
                      },
                      child: Text("Refresh Summary"))
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
                                "IDR " + Utils.formatNumber(penjualanHarian),
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                "IDR " + Utils.formatNumber(penjualanBulanan),
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                "IDR " + Utils.formatNumber(labaHarian),
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                Center(
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                "IDR " + Utils.formatNumber(labaBulanan),
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
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
                  crossAxisCount: 3, childAspectRatio: 0.80),
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
                  crossAxisCount: 3, childAspectRatio: 0.8),
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
                  crossAxisCount: 3, childAspectRatio: 0.8),
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
              ],
            )),
          ],
        ));
  }
}
