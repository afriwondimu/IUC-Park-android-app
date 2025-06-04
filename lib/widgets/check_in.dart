import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  _CheckInState createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  final _checkInCouponController = TextEditingController();
  final _checkInPlateController = TextEditingController();
  String? _checkInResult;
  bool _isLoading = false;

  void _checkIn() async {
    setState(() {
      _isLoading = true;
      _checkInResult = null;
    });

    try {
      final couponCode = int.parse(_checkInCouponController.text);
      final plateNumber = _checkInPlateController.text;
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.checkInService.checkIn(couponCode, plateNumber);
      await appState.saveData();
      setState(() {
        _checkInResult = result;
        _checkInCouponController.clear();
        _checkInPlateController.clear();
      });
    } catch (e) {
      setState(() {
        _checkInResult = 'የተሳሳተ አሞላል';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _checkInCouponController.dispose();
    _checkInPlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenHeight * 0.02;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHECK IN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _checkInCouponController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.confirmation_number, color: Colors.grey.shade600),
                labelText: 'ኩፖን ቁጥር',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _checkInPlateController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.directions_car, color: Colors.grey.shade600),
                labelText: 'ታርጋ ቁጥር',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'ለማስገባት ይጫኑ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            if (_checkInResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _checkInResult!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}