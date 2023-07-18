import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/utility/list_modal_form.dart';

import '../../utils.dart';

class BottomModalFilter extends StatefulWidget {
  final Function action;
  final TextEditingController tanggalDariCtrl;
  final TextEditingController tanggalHinggaCtrl;
  bool isGudang;
  bool isDept;
  bool isPengguna;
  BottomModalFilter(
      {super.key,
      required this.action,
      required this.tanggalDariCtrl,
      required this.tanggalHinggaCtrl,
      this.isGudang = false,
      this.isDept = false,
      this.isPengguna = false});

  @override
  State<BottomModalFilter> createState() => _BottomModalFilterState();
}

class _BottomModalFilterState extends State<BottomModalFilter> {
  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: TextField(
                      controller: widget.tanggalDariCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: "Tanggal Dari",
                      ),
                    ),
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
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: TextField(
                      controller: widget.tanggalHinggaCtrl,
                      decoration: InputDecoration(
                        hintText: "Tanggal Hingga",
                      ),
                    ),
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
            gudang(),
            department(),
            pengguna(),
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

  Widget gudang() {
    if (!widget.isGudang) {
      return Container();
    }
    TextEditingController gudangCtrl = new TextEditingController();
    gudangCtrl.text = Utils.namaGudangTemp;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 28,
              child: TextField(
                controller: gudangCtrl,
                decoration: InputDecoration(
                  hintText: "Gudang",
                ),
              ),
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
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 28,
              child: TextField(
                controller: deptCtrl,
                decoration: InputDecoration(
                  hintText: "Department",
                ),
              ),
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
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 28,
              child: TextField(
                controller: penggunaCtrl,
                decoration: InputDecoration(
                  hintText: "Bagian Penjualan",
                ),
              ),
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
