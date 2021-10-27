import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_codigo3_sqflite_2/db/db_global.dart';
import 'package:flutter_codigo3_sqflite_2/models/band_model.dart';
import 'package:flutter_codigo3_sqflite_2/pages/list_band_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Barcode? result;

  QRViewController? controller;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print("QRRRRRRRRRRR: ${result!.code}");

        if(result!=null){
          Band myBand = new Band(
            bandName: result!.code,
            status: "true",
            favorite: "false"
          );
          DBGlobal.db.insertBand(myBand);
        }


      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (result != null)
                  Text(
                      'Banda: ${result!.code}')
                else
                  Text('Escanea el QR'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.remove_red_eye),
                        onPressed: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>ListBandPage())
                          );

                        },
                        label: Text("Ver lista d bandas"),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff282A3C),
                          shape: RoundedRectangleBorder(
                            borderRadius:BorderRadius.circular(10.0)
                          )
                        ),
                      )
                    ),

                  ],
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
