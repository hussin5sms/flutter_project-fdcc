import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/certificate_controller.dart';
import '../models/company_model.dart';

class AddCertificateScreen extends StatelessWidget {
  AddCertificateScreen({super.key});

  final CertificateController controller = Get.put(CertificateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة إذن بيطري")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () {
            // إنشاء قائمة فريدة من الشركات لتجنب التكرار
            final uniqueCompanies = _getUniqueCompanies(controller.companies);

            // التحقق من أن القيمة المحددة موجودة في القائمة
            final selectedValue = uniqueCompanies.contains(controller.selectedCompany.value)
                ? controller.selectedCompany.value
                : null;

            return ListView(
              children: [
                // حقل البحث
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    labelText: "ابحث عن شركة",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.isLoadingCompanies.value
                        ? const CircularProgressIndicator()
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // إعادة تعيين القيمة المحددة عند البحث
                    if (value.isNotEmpty) {
                      controller.selectedCompany.value = null;
                    }
                    controller.searchCompanies(value);
                  },
                ),
                const SizedBox(height: 12),

                // القائمة المنسدلة للشركات
                DropdownButtonFormField<Company>(
                  hint: uniqueCompanies.isEmpty && controller.searchController.text.isNotEmpty
                      ? const Text("لا توجد نتائج")
                      : const Text("اختر الشركة"),
                  value: selectedValue,
                  items: uniqueCompanies.map((company) {
                    return DropdownMenuItem<Company>(
                      value: company,
                      child: Text(company.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedCompany.value = value;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                ),

                // باقي الحقول (تبقى كما هي بدون تغيير)
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "رقم الإذن"),
                  onChanged: (val) => controller.certNumber.value = val,
                ),
                const SizedBox(height: 12),

                //--------------------------------------      port Number
                // TextField(
                //   decoration: const InputDecoration(labelText: "رقم المنفذ"),
                //   onChanged: (val) => controller.portNumber.value = val,
                // ),
                //

                //------------------------------------------------- نوع السلعة


                // القائمة المنسدلة لنوع السلعة
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: controller.itemType.value.isEmpty ? null : controller.itemType.value,
                  items: const [
                    DropdownMenuItem(value: "لحم بقري مجمد", child: Text("لحم بقري مجمد")),
                    DropdownMenuItem(value: "لحم دجاج مجمد", child: Text("لحم دجاج مجمد")),
                  ],
                  onChanged: (value) {
                    controller.itemType.value = value!;
                  },
                  decoration: const InputDecoration(
                    labelText: "نوع السلعة",
                    border: OutlineInputBorder(),
                  ),
                ),


                //************************************************
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    "تاريخ الإذن: ${controller.certDate.value.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: controller.certDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      controller.certDate.value = picked;
                      controller.certYear.value = picked.year;
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("نوع التتبع: "),
                    Radio(
                      value: 0,
                      groupValue: controller.trackingMode.value,
                      onChanged: (val) => controller.trackingMode.value = val!,
                    ),
                    const Text("وزن"),
                    Radio(
                      value: 1,
                      groupValue: controller.trackingMode.value,
                      onChanged: (val) => controller.trackingMode.value = val!,
                    ),
                    const Text("صناديق"),
                  ],
                ),
                const SizedBox(height: 12),
                if (controller.trackingMode.value == 0) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: "الوزن الكلي"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => controller.weight.value = val,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: controller.weightUnit.value,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("طن")),
                      DropdownMenuItem(value: 1, child: Text("كجم")),
                    ],
                    onChanged: (val) => controller.weightUnit.value = val!,
                  ),
                ],
                if (controller.trackingMode.value == 1) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: "عدد الصناديق الكلي"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => controller.boxCount.value = val,
                  ),
                ],
                const SizedBox(height: 12),
                const Text("مدة الصلاحية: "),
                Row(
                  children: [30, 60, 90].map((days) {
                    return Row(
                      children: [
                        Radio(
                          value: days,
                          groupValue: controller.dayLimit.value,
                          onChanged: (val) => controller.dayLimit.value = val as int,
                        ),
                        Text("$days يوم"),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("تأكيد الحفظ"),
                        content: Text("هل أنت متأكد من حفظ بيانات الإذن البيطري؟"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("إلغاء"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("تأكيد"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      controller.saveCertificate();
                    }
                  },

                  //controller.saveCertificate,
                  icon: const Icon(Icons.save),
                  label: const Text("حفظ الإذن"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء قائمة فريدة من الشركات
  List<Company> _getUniqueCompanies(List<Company> companies) {
    final uniqueMap = <int, Company>{};
    for (var company in companies) {
      uniqueMap[company.id] = company;
    }
    return uniqueMap.values.toList();
  }


}