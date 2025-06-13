import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/shipment_controller.dart';
import '../models/vet_certificate_model.dart';

class AddShipmentScreen extends StatelessWidget {
  final ShipmentController controller = Get.put(ShipmentController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      controller.loadCertificates();
    });

    return Scaffold(
      appBar: AppBar(title: Text("إضافة شحنة")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCertificateDropdown(context),
                SizedBox(height: 20),
                _buildArrivalDateField(context),
                SizedBox(height: 20),
                _buildWeightOrBoxesField(),
                SizedBox(height: 20),
                _buildBolisaNumberField(),
                SizedBox(height: 20),
                _buildBillsList(),
                SizedBox(height: 10),
                _buildAddBillField(),
                SizedBox(height: 20),
                Obx(() => controller.bills.any((b) => b.isDuplicate) ? _buildNotesField() : SizedBox()),
                SizedBox(height: 30),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== Dropdown للأذونات البيطرية ==================
  Widget _buildCertificateDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("الإذن البيطري", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() {
            if (controller.isLoading.value) {
              return DropdownButton<VetCertificate>(
                isExpanded: true,
                hint: Text("جاري التحميل..."),
                items: [],
                onChanged: null,
              );
            }
            return DropdownButtonFormField<VetCertificate>(
              isExpanded: true,
              decoration: InputDecoration(border: InputBorder.none),
              hint: Text("اختر الإذن البيطري"),
              value: controller.selectedCertificate.value,
              items: controller.certificates.map((e) {
                return DropdownMenuItem<VetCertificate>(value: e, child: Text(e.certificateNumber));
              }).toList(),
              onChanged: (val) {
                controller.selectedCertificate.value = val;
                if (val?.certificateDate != null) {
                  controller.selectedYear.value = val!.certificateDate!.year;
                }
              },
              validator: (value) => value == null ? 'يجب اختيار إذن بيطري' : null,
            );
          }),
        ),
      ],
    );
  }

  // ================== حقل تاريخ الوصول ==================
  Widget _buildArrivalDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("تاريخ الوصول", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: controller.arrivalDate.value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: Locale('ar'),
            );
            if (picked != null) controller.arrivalDate.value = picked;
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd.MM.yyyy').format(controller.arrivalDate.value)),
                Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================== وزن الشحنة أو عدد الصناديق ==================
  Widget _buildWeightOrBoxesField() {
    return Obx(() {
      final cert = controller.selectedCertificate.value;
      if (cert == null) return SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cert.trackingMode == 0 ? "الوزن (طن)" : "عدد الصناديق", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: cert.trackingMode == 0),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: cert.trackingMode == 0 ? "أدخل الوزن بالطن" : "أدخل عدد الصناديق",
              suffixText: cert.trackingMode == 0 ? "طن" : "صندوق",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
              if (cert.trackingMode == 0 && double.tryParse(value) == null) return 'أدخل وزن صحيح';
              if (cert.trackingMode == 1 && int.tryParse(value) == null) return 'أدخل عدد صحيح';
              return null;
            },
            onChanged: (val) {
              if (cert.trackingMode == 0) {
                controller.weight.value = double.tryParse(val) ?? 0.0;
              } else {
                controller.boxCount.value = int.tryParse(val) ?? 0;
              }
            },
          ),
          SizedBox(height: 8),
          Text(
            "المتبقي: ${cert.trackingMode == 0 ? '${cert.allowedRemainingTon} طن' : '${cert.allowedRemainingBoxes} صندوق'}",
            style: TextStyle(color: Colors.blue),
          ),
        ],
      );
    });
  }

  // ================== رقم البوليصة الكلي (للقراءة فقط) ==================
  Widget _buildBolisaNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("رقم البوليصة الكلي", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          initialValue: controller.bolisaNumber.value,
          enabled: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "سيتم تعبئته تلقائيًا",
          ),
        ),
      ],
    );
  }

  // ================== قائمة البوالص ==================
  Widget _buildBillsList() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("البوالص المضافة", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text("${controller.bills.length}", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (controller.bills.isEmpty)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text("لا يوجد بوالص مضافة", style: TextStyle(color: Colors.grey))),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.bills.length,
            itemBuilder: (context, index) {
              final bill = controller.bills[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text(bill.billNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: bill.isDuplicate
                      ? Text("مكررة: ${bill.duplicateReason}", style: TextStyle(color: Colors.orange))
                      : null,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.removeBill(bill),
                  ),
                ),
              );
            },
          ),
      ],
    ));
  }

  // ================== إضافة بوليصة جديدة ==================
  Widget _buildAddBillField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: TextEditingController(text: controller.currentBill.value),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "أدخل رقم البوليصة",
            ),
            onChanged: (val) => controller.currentBill.value = val,
            onFieldSubmitted: (val) => controller.addCurrentBill(),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text("إضافة"),
          onPressed: controller.addCurrentBill,
        ),
      ],
    );
  }

  // ================== حقل الملاحظات (مرئي فقط عند وجود تكرار) ==================
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ملاحظات", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "سبب تكرار البوليصة",
          ),
          validator: (value) {
            if (controller.bills.any((b) => b.isDuplicate) && (value?.trim().isEmpty ?? true)) {
              return 'يجب كتابة سبب التكرار';
            }
            return null;
          },
          onChanged: (val) => controller.notes.value = val,
        ),
      ],
    );
  }

  // ================== زر الحفظ ==================
  Widget _buildSaveButton() {
    return Obx(() {
      final isValid = controller.selectedCertificate.value != null && controller.bills.isNotEmpty;
      return ElevatedButton(
        onPressed: controller.isSaving.value || !isValid ? null : () {
          if (_formKey.currentState?.validate() ?? false) {
            controller.saveShipment();
          }
        },
        child: controller.isSaving.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
            SizedBox(width: 10),
            Text("جاري الحفظ..."),
          ],
        )
            : Text("حفظ الشحنة"),
      );
    });
  }
}