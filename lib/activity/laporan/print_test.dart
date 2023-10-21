import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../utils.dart';
import 'package:http/http.dart' as http;

class PrintTest extends StatefulWidget {
  const PrintTest({super.key});

  @override
  State<PrintTest> createState() => _PrintTestState();
}

class _PrintTestState extends State<PrintTest> {
  String mainUrlString = "${Utils.mainUrl}barang/daftar?idgudang=${Utils.idGudang}&halaman=0";

  Future<List<dynamic>> _getDataBarang({String keyword = ""}) async {
    Uri url = Uri.parse(mainUrlString);
    http.Response response = await http.get(url, headers: Utils.setHeader());
    log(jsonDecode(response.body).toString());
    var jsonData = jsonDecode(response.body)["data"];
    return jsonData;
  }

  void cetakPdf() async {
    final doc = pw.Document();

    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(child: pw.Column(children: []));
        }));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Print"),
      ),
      body: Container(
        child: ElevatedButton(
            onPressed: () {
              cetakPdf();
            },
            child: Text("Print")),
      ),
    );
  }
}
