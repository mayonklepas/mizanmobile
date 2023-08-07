import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';

import '../../utils.dart';

class BottomModalFilter extends StatefulWidget {
  final Function action;
  TextEditingController tanggalDariCtrl;
  final TextEditingController tanggalHinggaCtrl;
  bool isGudang;
  bool isDept;
  bool isPengguna;
  bool isSingleDate;
  bool isKelompokTransaksi;
  BottomModalFilter(
      {super.key,
      required this.action,
      required this.tanggalDariCtrl,
      required this.tanggalHinggaCtrl,
      this.isGudang = false,
      this.isDept = false,
      this.isPengguna = false,
      this.isSingleDate = false,
      this.isKelompokTransaksi = false});

  @override
  State<BottomModalFilter> createState() => _BottomModalFilterState();
}

class _BottomModalFilterState extends State<BottomModalFilter> {
  String tanggalDariLabel = "Tanggal Dari";

  @override
  Widget build(BuildContext context) {
    if (widget.isSingleDate) {
      tanggalDariLabel = "Tanggal";
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.labelSetter("Filter Data", bold: true, size: 25),
            Padding(padding: const EdgeInsets.all(10)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Utils.labelForm(tanggalDariLabel),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: TextField(
                            controller: widget.tanggalDariCtrl,
                            keyboardType: TextInputType.datetime),
                      ),
                    ),
                    Expanded(
                        flex: 0,
                        child: IconButton(
                            onPressed: () {
                              setTextDateRange(widget.tanggalDariCtrl);
                            },
                            icon: Icon(
                              Icons.date_range,
                            )))
                  ],
                ),
              ],
            ),
            tanggalHingga(),
            gudang(),
            department(),
            pengguna(),
            kelompokTransaksi(),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    widget.action();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_alt),
                      Padding(padding: EdgeInsets.all(5)),
                      Text("Filter"),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget tanggalHingga() {
    if (widget.isSingleDate) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.labelForm("Tanggal Hingga"),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(controller: widget.tanggalHinggaCtrl),
                ),
              ),
              Expanded(
                  flex: 0,
                  child: IconButton(
                      onPressed: () {
                        setTextDateRange(widget.tanggalHinggaCtrl);
                      },
                      icon: Icon(
                        Icons.date_range,
                      )))
            ],
          ),
        ],
      ),
    );
  }

  Widget gudang() {
    if (!widget.isGudang) {
      return Container();
    }
    TextEditingController gudangCtrl = new TextEditingController();
    gudangCtrl.text = Utils.namaGudangTemp;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.labelForm("Gudang"),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(controller: gudangCtrl),
                ),
              ),
              Expanded(
                  flex: 0,
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
                        Utils.namaGudangTemp = popUpResult["NAMA"];
                        Utils.idGudangTemp = popUpResult["NOINDEX"];
                      },
                      icon: Icon(
                        Icons.search,
                      )))
            ],
          ),
        ],
      ),
    );
  }

  Widget department() {
    if (!widget.isDept) {
      return Container();
    }
    TextEditingController deptCtrl = new TextEditingController();
    deptCtrl.text = Utils.namaDeptTemp;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.labelForm("Department"),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(controller: deptCtrl),
                ),
              ),
              Expanded(
                  flex: 0,
                  child: IconButton(
                      onPressed: () async {
                        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ListModalForm(
                              type: "dept",
                            );
                          },
                        ));

                        if (popUpResult == null) return;
                        deptCtrl.text = popUpResult["NAMA"];
                        Utils.namaDeptTemp = popUpResult["NAMA"];
                        Utils.idDeptTemp = popUpResult["NOINDEX"].toString();
                      },
                      icon: Icon(
                        Icons.search,
                      )))
            ],
          ),
        ],
      ),
    );
  }

  Widget pengguna() {
    if (!widget.isDept) {
      return Container();
    }
    TextEditingController penggunaCtrl = new TextEditingController();
    penggunaCtrl.text = Utils.namaPenggunaTemp;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.labelForm("Bagian Penjualan"),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(controller: penggunaCtrl),
                ),
              ),
              Expanded(
                  flex: 0,
                  child: IconButton(
                      onPressed: () async {
                        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ListModalForm(
                              type: "pengguna",
                            );
                          },
                        ));

                        if (popUpResult == null) return;
                        penggunaCtrl.text = popUpResult["NAMA"];
                        Utils.namaPenggunaTemp = popUpResult["NAMA"];
                        Utils.idPenggunaTemp = popUpResult["NOINDEX"].toString();
                      },
                      icon: Icon(
                        Icons.search,
                      )))
            ],
          ),
        ],
      ),
    );
  }


  
  Widget kelompokTransaksi() {
    if (!widget.isKelompokTransaksi) {
      return Container();
    }
    TextEditingController kelompokTransaksiCtrl = new TextEditingController();
    kelompokTransaksiCtrl.text = Utils.namaKelompokTransaksi;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.labelForm("Kelompok Transaksi"),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: TextField(controller: kelompokTransaksiCtrl),
                ),
              ),
              Expanded(
                  flex: 0,
                  child: IconButton(
                      onPressed: () async {
                        dynamic popUpResult = await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ListModalForm(
                              type: "kelompoktransaksi",
                            );
                          },
                        ));

                        if (popUpResult == null) return;
                        kelompokTransaksiCtrl.text = popUpResult["NAMA"];
                        Utils.namaKelompokTransaksi = popUpResult["NAMA"];
                        Utils.idKelompokTransaksi = popUpResult["NOINDEX"].toString();
                      },
                      icon: Icon(
                        Icons.search,
                      )))
            ],
          ),
        ],
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
}
