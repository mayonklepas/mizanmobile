import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PrinterUtils {
  BluetoothDevice? device;

  PrinterUtils(BluetoothDevice this.device);

  printWithDevice() async {
    await device!.connect();
    List<BluetoothService> bService = await device!.discoverServices();
    List<BluetoothCharacteristic> characteristicBlue = [];
    for (BluetoothService serv in bService) {
      characteristicBlue.addAll(serv.characteristics);
    }

    List<int> dataPrint = await dataPrinted();

    for (var d in characteristicBlue) {
      d.write(dataPrint);
    }
  }

  Future dataPrinted() async {
    var gen = Generator(PaperSize.mm58, await CapabilityProfile.load());
    List<int> data = [];
    data.addAll(gen.qrcode("mizan acc"));
    data.addAll(gen.emptyLines(1));
    data.addAll(gen.text("Toko Berkah Bahagia"));
    data.addAll(gen.hr());
    PosStyles style = PosStyles();

    data.addAll(gen.text("Chiki ball 80gr"));
    List<PosColumn> column = [];
    column.add(PosColumn(text: "10", width: 4));
    column.add(PosColumn(text: "Rp 20.000", width: 8, styles: style));
    data.addAll(gen.row(column));
    data.addAll(gen.hr());

    data.addAll(gen.text("Chitos jagung bakar 80gr"));
    List<PosColumn> column2 = [];
    column2.add(PosColumn(text: "10", width: 4));
    column2.add(PosColumn(text: "Rp 17.500", width: 8, styles: style));
    data.addAll(gen.row(column2));
    data.addAll(gen.hr());

    data.addAll(gen.text("panadol extra"));
    List<PosColumn> column3 = [];
    column3.add(PosColumn(text: "10", width: 4));
    column3.add(PosColumn(text: "Rp 17.500", width: 8, styles: style));
    data.addAll(gen.row(column3));
    data.addAll(gen.hr());

    data.addAll(gen.emptyLines(1));
    data.addAll(gen.cut());
    return data;
  }

  disconnect() async {
    await this.device?.disconnect();
  }

  connect() async {
    await this.device?.connect();
  }
}
