import 'package:appcertificate/add_shipment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_certificate_screen.dart';


class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() =>  AddCertificateScreen());
              },
              child: const Text('إضافة إذن جديد'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() =>  AddShipmentScreen());
              },
              child: const Text('إضافة شحنة'),
            ),
          ],
        ),
      ),
    );
  }
}
