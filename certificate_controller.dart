


import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/company_model.dart';
import '../services/api_service.dart';

class CertificateController extends GetxController {
  // متغيرات الشركات والبحث
  var companies = <Company>[].obs;
  var selectedCompany = Rxn<Company>();
  var isLoadingCompanies = false.obs;
  var searchController = TextEditingController();

  // المتغيرات الأصلية
  var portNumber = ''.obs;
  var trackingMode = 0.obs; // 0 = وزن, 1 = صناديق
  var weight = ''.obs;
  var boxCount = ''.obs;
  var weightUnit = 0.obs; // 0=طن, 1=كجم
  var certNumber = ''.obs;
  var certDate = DateTime.now().obs;
  var certYear = DateTime.now().year.obs;
  var dayLimit = 30.obs;
  var isSaving = false.obs;
  var itemType = ''.obs;

  Future<void> searchCompanies(String query) async {
    try {
      isLoadingCompanies.value = true;
      companies.value = await ApiService.fetchCompanies(query: query.isNotEmpty ? query : null);
    } catch (e) {
      Get.snackbar("خطأ", "فشل في البحث عن الشركات: ${e.toString()}");
    } finally {
      isLoadingCompanies.value = false;
    }
  }

  Future<void> loadInitialCompanies() async {
    await searchCompanies('');
  }




//    Save


  Future<void> saveCertificate() async {
    try {
      isSaving.value = true;

      // التحقق من البيانات المطلوبة
      if (selectedCompany.value == null) {
        throw Exception("يجب اختيار شركة");
      }

      if (certNumber.value.isEmpty) {
        throw Exception("يجب إدخال رقم الإذن");
      }

      if (itemType.value.isEmpty) {
        throw Exception("يجب اختيار نوع السلعة");
      }

      // التحقق من وجود إذن بنفس الرقم في نفس السنة
      bool exists = await checkCertificateExists();
      if (exists) {
        throw Exception("يوجد إذن بنفس الرقم في سنة ${certYear.value}. الرجاء استخدام رقم إذن مختلف");
      }

      // إعداد البيانات
      final data = {
        "company_id": selectedCompany.value!.id.toString(),
        "certificate_number": certNumber.value,
        "certificate_date": certDate.value.toIso8601String().split('T')[0],
        "year": certYear.value.toString(),
        "tracking_mode": trackingMode.value.toString(),
        "weight": trackingMode.value == 0 ? weight.value : '0',
        "weight_unit": weightUnit.value.toString(),
        "box_count": trackingMode.value == 1 ? boxCount.value : '0',
        "dayesLimit": dayLimit.value.toString(),
        "item_type": itemType.value,
      };

      // إرسال البيانات
      bool success = await ApiService.addCertificate(data);

      if (!success) {
        throw Exception("فشل في إضافة الإذن دون سبب محدد من الخادم");
      }

      Get.snackbar("نجاح", "تم إضافة الإذن بنجاح",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));

      // إعادة تعيين الحقول بعد الحفظ الناجح فقط
      resetForm();

    } catch (e) {
      Get.snackbar("خطأ", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
      debugPrint("حدث خطأ أثناء حفظ الإذن: ${e.toString()}");
    } finally {
      isSaving.value = false;
    }
  }


 //====   END  SAVE




  void resetForm() {
    // إعادة تعيين حقول الشركة والبحث
    selectedCompany.value = null;
    searchController.clear();

    // إعادة تعيين حقول الإذن الأساسية
    certNumber.value = '';
    certDate.value = DateTime.now();
    certYear.value = DateTime.now().year;
    itemType.value = '';

    // إعادة تعيين حقول المنفذ (إذا كنت تستخدمها)
    // portNumber.value = '';

    // إعادة تعيين حقول التتبع
    trackingMode.value = 0; // الإعداد الافتراضي: تتبع بالوزن
    weight.value = '';
    boxCount.value = '';
    weightUnit.value = 0; // الإعداد الافتراضي: طن

    // إعادة تعيين حقول الصلاحية
    dayLimit.value = 30; // الإعداد الافتراضي: 30 يوم

    // إذا كنت تريد إعادة تحميل قائمة الشركات
    //loadInitialCompanies();
  }



  @override
  void onInit() {
    super.onInit();
    loadInitialCompanies();
    searchController.addListener(() {
      searchCompanies(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

// في certificate_controller.dart
  Future<bool> checkCertificateExists() async {
    try {
      if (certNumber.value.isEmpty) return false;

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}check_certificate_exists.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'certificate_number': certNumber.value,
          'year': certYear.value,
        }),
      );

      final json = jsonDecode(response.body);
      return json['exists'] == true;
    } catch (e) {
      debugPrint("Error checking certificate: $e");
      return false;
    }
  }

}