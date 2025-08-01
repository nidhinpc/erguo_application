import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QRCodePage extends StatelessWidget {
  final String url = "https://erguoregister.page.link/NLtk";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Worker Registration QR")),
      body: Center(
        child: QrImageView(
          data: url,
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}
