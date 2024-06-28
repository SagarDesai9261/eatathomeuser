import '../helpers/custom_trace.dart';

class CreditCard {
  String id;
  String number;
  String expMonth;
  String expYear;
  String cvc;

  CreditCard({
    this.id = '',
    this.number = '',
    this.expMonth = '',
    this.expYear = '',
    this.cvc = '',
  });

  CreditCard.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        number = jsonMap['stripe_number']?.toString() ?? '',
        expMonth = jsonMap['stripe_exp_month']?.toString() ?? '',
        expYear = jsonMap['stripe_exp_year']?.toString() ?? '',
        cvc = jsonMap['stripe_cvc']?.toString() ?? '';

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "stripe_number": number,
      "stripe_exp_month": expMonth,
      "stripe_exp_year": expYear,
      "stripe_cvc": cvc,
    };
  }

  bool validated() {
    return number.isNotEmpty && expMonth.isNotEmpty && expYear.isNotEmpty && cvc.isNotEmpty;
  }
}
