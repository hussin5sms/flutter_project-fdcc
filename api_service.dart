import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/company_model.dart';
import '../models/vet_certificate_model.dart';

class ApiService {

  static const String baseUrl = "https://hussein.org.ly/new_api/certificate/";



  /// جلب الشركات
  // static Future<List<Company>> fetchCompanies() async {
  //   final response = await http.get(Uri.parse("$baseUrl/get_companies.php"));
  //   if (response.statusCode == 200) {
  //     List data = jsonDecode(response.body);
  //     return data.map((e) => Company.fromJson(e)).toList();
  //   } else {
  //     throw Exception("فشل تحميل الشركات");
  //   }
  // }
  static Future<List<Company>> fetchCompanies({String? query}) async {
    try {
      final url = Uri.parse("$baseUrl/get_companies.php${query != null ? '?query=$query' : ''}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => Company.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load companies");
      }
    } catch (e) {
      throw Exception("Error fetching companies: $e");
    }
  }




  /// إضافة إذن جديد
  // static Future<bool> addCertificate(Map<String, dynamic> certificateData) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/add_certificate.php"),
  //     body: certificateData,
  //   );
  //   final json = jsonDecode(response.body);
  //   return json['status'] == "success";
  // }

  static Future<bool> addCertificate(Map<String, dynamic> certificateData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add_certificate.php"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(certificateData),
    );

    final json = jsonDecode(response.body);
    return json['status'] == "success";
  }




  /// جلب الأذونات البيطرية
  ///
  ///
  // static Future<List<VetCertificate>> fetchCertificates() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse("$baseUrl/get_certificates.php"),
  //       headers: {'Accept': 'application/json'},
  //     );
  //
  //     print('Status Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final decodedData = jsonDecode(response.body);
  //
  //       if (decodedData is Map && decodedData['success'] == true) {
  //         final data = decodedData['data'] as List;
  //         return data.map((e) => VetCertificate.fromJson(e)).toList();
  //       } else if (decodedData is List) {
  //         return decodedData.map((e) => VetCertificate.fromJson(e)).toList();
  //       } else {
  //         throw Exception('تنسيق غير متوقع للبيانات: ${decodedData.runtimeType}');
  //       }
  //     } else {
  //       throw Exception('فشل تحميل الأذونات. الرمز: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error in fetchCertificates: $e');
  //     throw Exception('فشل الاتصال بالخادم: $e');
  //   }
  // }
  //
  static Future<List<VetCertificate>> fetchCertificates() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_certificates.php"),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map && decodedData['success'] == true) {
          final data = decodedData['data'] as List;
          return data.map((e) => VetCertificate.fromJson(e)).toList();
        } else if (decodedData is List) {
          return decodedData.map((e) {
            try {
              return VetCertificate.fromJson(e);
            } catch (e) {
              debugPrint('Error parsing certificate: $e');
              return VetCertificate(
                id: 0,
                certificateNumber: 'Error',
                certificateDate: DateTime.now(),
                dayesLimit: 30,
                trackingMode: 0,
                allowedWeightTon: 0,
                allowedRemainingTon: 0,
              );
            }
          }).toList();
        } else {
          throw Exception('Unexpected data format: ${decodedData.runtimeType}');
        }
      } else {
        throw Exception('Failed to load certificates. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in fetchCertificates: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }



  /// إضافة شحنة جديدة


  static Future<bool> addShipment(Map<String, dynamic> shipmentData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_shipment.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(shipmentData),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return json['status'] == "success";
      } else {
        throw Exception(json['message'] ?? "فشل في إضافة الشحنة");
      }
    } catch (e) {
      throw Exception("Error adding shipment: $e");
    }
  }


}
