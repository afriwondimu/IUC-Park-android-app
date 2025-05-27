import 'package:intl/intl.dart';
import 'vehicle.dart';

class Motorbike extends Vehicle {
  DateTime? checkOutTime;

  Motorbike(super.couponCode, super.plateNumber, super.checkInTime);

  factory Motorbike.fromJson(Map<String, dynamic> json) {
    return Motorbike(
      json['couponCode'],
      json['plateNumber'],
      DateTime.parse(json['checkInTime']),
    )..checkOutTime = json['checkOutTime'] != null
        ? DateTime.parse(json['checkOutTime'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() => {
        'couponCode': couponCode,
        'plateNumber': plateNumber,
        'checkInTime': checkInTime.toIso8601String(),
        'checkOutTime': checkOutTime?.toIso8601String(),
      };

  @override
  String getDetails() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String checkOut = checkOutTime != null
        ? formatter.format(checkOutTime!)
        : 'አልወጣም';
    return 'ኩፖን ቁጥር : $couponCode, ታርጋ ቁጥር : $plateNumber, '
        '\nበ : ${formatter.format(checkInTime)} ገብቶ,\nበ: $checkOut ወጣ' ;
  }
}