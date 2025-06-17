import 'database_service.dart';
import '../models/motorbike.dart';
import 'auth_service.dart';

class CheckOutService {
  final DatabaseService _databaseService;
  final List<bool> _couponAvailability;
  final AuthService _authService;

  CheckOutService(this._databaseService, this._couponAvailability, this._authService);

  Future<String> checkOut(int couponCode, bool confirm) async {
    if (couponCode < 1 || couponCode > 300) {
      return 'የሚያስገቡት ኩፖን ቁጥር ከ 300 መብለጥ የለበትም';
    }
    final vehicles = await _databaseService.loadVehicles();
    for (var v in vehicles) {
      if (v.couponCode == couponCode && v is Motorbike && v.checkOutTime == null) {
        if (!confirm) {
          return 'ታርጋ ቁጥር: ${v.plateNumber}\nእባክዎ ያረጋግጡ';
        }
        final auth2 = _authService.getCurrentUsername();
        if (auth2 == null) {
          return 'እባክዎ መጀመሪያ ይግቡ';
        }
        await _databaseService.updateCheckOut(couponCode, DateTime.now(), auth2);
        _couponAvailability[couponCode - 1] = true;
        v.checkOutTime = DateTime.now();
        v.auth2 = auth2;
        return 'Check-out: ${v.getDetails()}';
      }
    }
    return 'በኩፓን ቁጥር $couponCode የተመዘገበ የለም';
  }
}