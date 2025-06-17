import 'package:intl/intl.dart';
import 'vehicle.dart';

class Motorbike extends Vehicle {
  DateTime? checkOutTime;
  String? auth1;
  String? auth2;

  Motorbike(super.couponCode, super.plateNumber, super.checkInTime, {this.checkOutTime, this.auth1, this.auth2});

  factory Motorbike.fromJson(Map<String, dynamic> json) {
    return Motorbike(
      json['coupon_code'] as int,
      json['plate_number'] as String,
      DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['checkout_time'] != null ? DateTime.parse(json['checkout_time'] as String) : null,
      auth1: json['auth1'] as String?,
      auth2: json['auth2'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'coupon_code': couponCode,
        'plate_number': plateNumber,
        'check_in_time': checkInTime.toIso8601String(),
        'checkout_time': checkOutTime?.toIso8601String(),
        'auth1': auth1,
        'auth2': auth2,
      };

  @override
  String getDetails() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');
    String checkOut = checkOutTime != null ? formatter.format(checkOutTime!) : 'አልወጣም';
    String auth1Text = auth1 != null ? 'አስገቢ: $auth1' : '';
    String auth2Text = auth2 != null ? 'አስወጪ: $auth2' : '';
    return 'ኩፖን ቁጥር: $couponCode\nታርጋ ቁጥር: $plateNumber\n'
        'በ: ${formatter.format(checkInTime)} ገባ\n'
        'በ: $checkOut${auth2Text.isNotEmpty ? ' ወጣ\n$auth1Text\n$auth2Text\n' : ''}';
  }
}