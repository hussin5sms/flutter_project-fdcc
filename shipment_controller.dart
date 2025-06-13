import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/BillModel.dart';
import '../models/vet_certificate_model.dart';
import '../services/api_service.dart';

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ShipmentController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  var certificates = <VetCertificate>[].obs;
  var selectedCertificate = Rxn<VetCertificate>();
  var selectedYear = Rxn<int>();

  var arrivalDate = DateTime.now().obs;
  var weight = 0.0.obs;
  var boxCount = 0.obs;
  var notes = ''.obs;
  var bolisaNumber = ''.obs;

  var bills = <BillModel>[].obs;
  var currentBill = ''.obs;

  Future<void> loadCertificates() async {
    try {
      isLoading(true);
      errorMessage('');
      final loadedCertificates = await ApiService.fetchCertificates();
      certificates.value = loadedCertificates.where((cert) => cert.id > 0).toList();
      if (certificates.isEmpty) {
        errorMessage.value = 'لا توجد أذونات متاحة';
      }
    } catch (e) {
      errorMessage.value = 'فشل تحميل الأذونات: ${e.toString()}';
    } finally {
      isLoading(false);
    }
  }

  void addCurrentBill() {
    final bill = currentBill.value.trim();
    if (bill.isEmpty) {
      Get.snackbar('تنبيه', 'يجب إدخال رقم البوليصة');
      return;
    }
    if (bills.any((b) => b.billNumber == bill)) {
      _handleDuplicateBill(bill);
    } else {
      bills.add(BillModel(billNumber: bill));
      currentBill.value = '';
      _updateBolisaNumber(); // تحديث الرقم الكلي
    }
  }

  void _handleDuplicateBill(String bill) {
    String duplicateReason = '';
    Get.defaultDialog(
      title: "بوليصة مكررة",
      content: Column(
        children: [
          Text("هذه البوليصة مسجلة مسبقاً. هل تريد المتابعة؟"),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(labelText: "سبب التكرار", border: OutlineInputBorder()),
            onChanged: (val) => duplicateReason = val,
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          bills.add(BillModel(billNumber: bill, isDuplicate: true, duplicateReason: duplicateReason));
          currentBill.value = '';
          _updateBolisaNumber(); // تحديث الرقم الكلي
          Get.back();
        },
        child: Text("موافق"),
      ),
      cancel: TextButton(onPressed: Get.back, child: Text("إلغاء")),
    );
  }

  void removeBill(BillModel bill) {
    bills.remove(bill);
    _updateBolisaNumber(); // تحديث الرقم الكلي
    Get.snackbar('تم الحذف', 'تم حذف البوليصة ${bill.billNumber}');
  }

  void _updateBolisaNumber() {
    if (bills.isNotEmpty) {
      bolisaNumber.value = bills.map((b) => b.billNumber).join(" / ");
    } else {
      bolisaNumber.value = '';
    }
  }

  Future<void> saveShipment() async {
    if (selectedCertificate.value == null || bills.isEmpty) {
      Get.snackbar('خطأ', 'يرجى اختيار إذن بيطري وإضافة بوليصة واحدة على الأقل');
      return;
    }

    final cert = selectedCertificate.value!;
    if (cert.trackingMode == 0 && weight.value <= 0 ||
        cert.trackingMode == 1 && boxCount.value <= 0) {
      Get.snackbar('خطأ', 'يرجى إدخال قيمة صحيحة للوزن أو عدد الصناديق');
      return;
    }

    // التحقق من أن كل البوالص المكررة تحتوي على سبب
    final hasDuplicateWithoutReason = bills
        .where((b) => b.isDuplicate)
        .any((b) => b.duplicateReason?.trim().isEmpty ?? true);

    if (hasDuplicateWithoutReason) {
      Get.snackbar('خطأ', 'يجب كتابة سبب التكرار لكل بوليصة مكررة');
      return;
    }

    try {
      isSaving(true);
      final data = {
        "certificate_id": cert.id,
        "shipment_date": arrivalDate.value.toIso8601String().split('T')[0],
        "weight_ton": cert.trackingMode == 0 ? weight.value : null,
        "box_count": cert.trackingMode == 1 ? boxCount.value : null,
        "notes": notes.value,
        "bolisa_number": bolisaNumber.value,
        "bills": bills.map((bill) => bill.toJson()).toList(),
        "year": selectedYear.value ?? arrivalDate.value.year,
      };

      final success = await ApiService.addShipment(data);
      if (success) {
        bills.clear();
        notes.value = '';
        weight.value = 0.0;
        boxCount.value = 0;
        currentBill.value = '';
        bolisaNumber.value = '';
        Get.snackbar('نجاح', 'تمت إضافة الشحنة بنجاح');
        Get.back();
      } else {
        Get.snackbar('خطأ', 'فشل في إضافة الشحنة');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ: $e');
    } finally {
      isSaving(false);
    }
  }
}