import 'package:iucpark/models/motorbike.dart';
import 'database_service.dart';

class CheckInService {
  final DatabaseService _databaseService;

  CheckInService(this._databaseService);

  Future<String> checkIn(int couponCode, String plateNumber) async {
    if (couponCode < 1 || couponCode > 300) {
      return 'የሚያስገቡት ኩፖን ቁጥር ከ 300 መብለጥ የለበትም';
    }

    if (await _databaseService.isCouponActive(couponCode)) {
      return 'ኩፓኑ ተይዟል፣ እባክዎን ሌላ ኩፓን ይምረጡ';
    }

    if (plateNumber.isEmpty) {
      return 'ታርጋ ቁጥር መሞላት አለበት';
    }

    final vehicle = Motorbike(couponCode, plateNumber, DateTime.now());
    await _databaseService.insertVehicle(vehicle);
    return 'ታርጋ ቁጥር : $plateNumber, በኩፓን ቁጥር : $couponCode ተመዝግቧል።';
  }
}