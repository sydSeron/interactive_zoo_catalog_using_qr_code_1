import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scanned_text_screen.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late final MobileScannerController cameraController;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
    startScanning();
  }

  void startScanning() {
    cameraController.start();
    setState(() {
      isScanning = true;
    });
  }

  void stopScanning() {
    cameraController.stop();
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Scan QR Code'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            stopScanning();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (barcode, arguments) {
                    if (barcode.rawValue != null) {
                      final String qrData = barcode.rawValue!;
                      stopScanning();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScannedTextScreen(scannedText: qrData),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to scan QR Code')),
                      );
                    }
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 2,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  //
}
