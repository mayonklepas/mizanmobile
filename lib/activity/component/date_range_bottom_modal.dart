import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../utils.dart';

class DateRangeBottomModal extends StatefulWidget {
  final Function action;
  final TextEditingController tanggalDariCtrl;
  final TextEditingController tanggalHinggaCtrl;
  const DateRangeBottomModal(
      {super.key,
      required this.action,
      required this.tanggalDariCtrl,
      required this.tanggalHinggaCtrl});

  @override
  State<DateRangeBottomModal> createState() => _DateRangeBottomModalState();
}

class _DateRangeBottomModalState extends State<DateRangeBottomModal> {
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
            Utils.labelSetter("Filter Tanggal", bold: true, size: 25),
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
                      Icon(Icons.date_range_outlined),
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

  void setTextDateRange(TextEditingController tgl) async {
    DateTime? pickedDate = await Utils.getDatePicker(context);
    if (pickedDate != null) {
      setState(() {
        tgl.text = Utils.formatStdDate(pickedDate);
      });
    }
  }
}
