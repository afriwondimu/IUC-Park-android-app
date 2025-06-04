import 'package:intl/intl.dart';
import 'vehicle.dart';

class Motorbike extends Vehicle {
  DateTime? checkOutTime;

  Motorbike(super.couponCode, super.plateNumber, super.checkInTime);

  factory Motorbike.fromJson(Map<String, dynamic> json) {
    return Motorbike(
      json['coupon_code'] as int,
      json['plate_number'] as String,
      DateTime.parse(json['check_in_time'] as String),
    )..checkOutTime = json['checkout_time'] != null
        ? DateTime.parse(json['checkout_time'] as String)
        : null;
  }

  @override
  Map<String, dynamic> toJson() => {
        'coupon_code': couponCode,
        'plate_number': plateNumber,
        'check_in_time': checkInTime.toIso8601String(),
        'checkout_time': checkOutTime?.toIso8601String(),
      };

  @override
  String getDetails() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String checkOut = checkOutTime != null
        ? formatter.format(checkOutTime!)
        : 'አልወጣም';
    return 'ኩፖን ቁጥር : $couponCode, ታርጋ ቁጥር : $plateNumber, '
        '\nበ : ${formatter.format(checkInTime)} ገብቶ,\nበ: $checkOut ወጣ';
  }
}