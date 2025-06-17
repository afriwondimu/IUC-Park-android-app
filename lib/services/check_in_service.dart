import 'database_service.dart';
import '../models/motorbike.dart';
import 'auth_service.dart';

class CheckInService {
  final DatabaseService _databaseService;
  final AuthService _authService;

  CheckInService(this._databaseService, this._authService);

  Future<String> checkIn(int couponCode, String plateNumber) async {
    try {
      if (couponCode < 1 || couponCode > 300) {
        return 'የሚያስገቡት ኩፖን ቁጥር ከ 300 መብለጥ የለበትም';
      }

      if (await _databaseService.isCouponActive(couponCode)) {
        return 'ኩፓኑ ተይዟል፣ እባክዎን ሌላ ኩፓን ይምረጡ';
      }

      if (plateNumber.isEmpty) {
        return 'ታርጋ ቁጥር መሞላት አለበት';
      }

      final auth1 = _authService.getCurrentUsername();
      if (auth1 == null) {
        return 'እባክዎ መጀመሪያ ይግቡ';
      }

      final vehicle = Motorbike(
        couponCode,
        plateNumber.trim().toUpperCase(),
        DateTime.now(),
        auth1: auth1,
      );

      await _databaseService.insertVehicle(vehicle, auth1);
      return 'ታርጋ ቁጥር: $plateNumber, በኩፓን ቁጥር: $couponCode ተመዝግቧል።';
    } catch (e) {
      return 'ስህተት ተፈጥሯል: ${e.toString()}';
    }
  }
}