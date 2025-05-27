import 'package:iucpark/models/motorbike.dart';
import 'database_service.dart';

class CheckInService {
  final DatabaseService _databaseService;
  final List<bool> couponAvailability;

  CheckInService(this._databaseService, this.couponAvailability);

  Future<String> checkIn(int couponCode, int plateNumber) async {
    if (couponCode < 1 || couponCode > 300) {
      return 'የሚያስገቡት ኩፖን ቁጥር ከ 300 መብለጥ የለበትም';
    }
    if (!couponAvailability[couponCode - 1]) {
      return 'ኩፓኑ ተይዟል፣ እባክዎን ሌላ ኩፓን ይምረጡ';
    }
    if (plateNumber <= 0) {
      return 'ታርጋ ቁጥር መሞላት አለበት ወይም ከ 0 ማነስ የለበትም';
    }
    couponAvailability[couponCode - 1] = false;
    final vehicle = Motorbike(couponCode, plateNumber, DateTime.now());
    await _databaseService.insertVehicle(vehicle);
    return 'ታርጋ ቁጥር :  $plateNumber, በኩፓን ቁጥር :  $couponCode ተመዝግቧል።';
  }
}