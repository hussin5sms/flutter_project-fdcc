class BillModel {
  final String billNumber;
  final bool isDuplicate;
  final String duplicateReason;

  BillModel({
    required this.billNumber,
    this.isDuplicate = false,
    this.duplicateReason = '',
  });

  Map<String, dynamic> toJson() {
    return {
      "bill_number": billNumber,
      "tkrar": isDuplicate ? 1 : 0,
      "note_tkrar": duplicateReason,
      "year_bills": DateTime.now().year,
    };
  }
}