abstract class Vehicle {
  int couponCode;
  String plateNumber;
  DateTime checkInTime;

  Vehicle(this.couponCode, this.plateNumber, this.checkInTime);

  String getDetails();

  Map<String, dynamic> toJson();

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}