// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:smart_bell/dao/DeviceList.dart';
// //import 'package:ecp_sync_plugin/ecp_sync_plugin.dart';
// import 'package:smart_bell/screen/DeviceAddedScreen.dart';
// import 'package:smart_bell/screen/WifiScanScreen.dart';
// import 'package:smart_bell/utilities/Navigators.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:wifi_iot/wifi_iot.dart';

// import '../utilities/TextStyles.dart';

// class QRCodeScreen extends StatefulWidget {
//   const QRCodeScreen({Key key}) : super(key: key);

//   @override
//   _QRCodeScreenState createState() => _QRCodeScreenState();
// }

// class _QRCodeScreenState extends State<QRCodeScreen> {
//   final GlobalKey qrKey = GlobalKey();
//   Map<String, dynamic> result;
//   QRViewController controller;

//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       controller.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller.resumeCamera();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 64.0, left: 40, right: 40),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final size = min(constraints.maxWidth, constraints.maxHeight);
//                   var BarcodeFormat;
//                   return Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       height: size,
//                       width: size,
//                       padding: EdgeInsets.all(3),
//                       decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage("assets/images/qr_frame.png"),
//                               fit: BoxFit.cover)),
//                       child: QRView(
//                         key: qrKey,
//                         onQRViewCreated: _onQRViewCreated,
//                         formatsAllowed: [BarcodeFormat.qrcode],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Text(
//                 'Scanning ...',
//                 style: TextStyle(
//                     fontSize: 24, color: Theme.of(context).primaryColor),
//               ),
//               SizedBox(
//                 height: 19,
//               ),
//               Text(
//                 'Align the QR code or barcode in the frame and scan it.',
//                 style: Theme.of(context).textTheme.headline2,
//               ),
//               SizedBox(
//                 height: 80,
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: Text(
//                       "Cancel Scan",
//                       style: TextStyles.buttonTextStyle(),
//                     )),
//               ),
//               SizedBox(
//                 height: 19,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) async {
//     this.controller = controller;

//     controller.scannedDataStream.listen((scanData) async {
//       setState(() {
//         result = json.decode(scanData.code);
//         ;
//       });
//       bool isConnected = await WiFiForIoTPlugin.connect(result['SSID'],
//           password: result['Password']);
//       if (isConnected) {
//         Navigators.push(context, WifiScanScreen());
//       }
//     });

//     // setState(() {
//     //   result = {
//     //     "SSID": "Smart Bell",
//     //     "Password": "password",
//     //     "device-token": "WoqfNcOfbBv3NeWMEThQ"
//     //   };
//     // });
//     // await WiFiForIoTPlugin.connect(result['SSID'],
//     //     password: result['Password']);
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }

// QRView(
//     {GlobalKey<State<StatefulWidget>> key,
//     void Function(dynamic controller) onQRViewCreated,
//     List formatsAllowed}) {}
