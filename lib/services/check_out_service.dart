import 'package:iucpark/models/motorbike.dart';
import 'database_service.dart';

class CheckOutService {
  final DatabaseService _databaseService;
  final List<bool> couponAvailability;

  CheckOutService(this._databaseService, this.couponAvailability);

  Future<String> checkOut(int couponCode, bool confirm) async {
    if (couponCode < 1 || couponCode > 300) {
      return 'Invalid coupon';
    }
    final vehicles = await _databaseService.loadVehicles();
    for (var v in vehicles) {
      if (v.couponCode == couponCode && v is Motorbike && v.checkOutTime == null) {
        if (!confirm) {
          return 'Plate: ${v.plateNumber}\nPlease confirm';
        }
        await _databaseService.updateCheckOut(couponCode, DateTime.now());
        couponAvailability[couponCode - 1] = true;
        v.checkOutTime = DateTime.now();
        return 'Check-out: ${v.getDetails()}';
      }
    }
    return 'በኩፓን ቁጥር $couponCode የተመዘገበ የለም';
  }
}