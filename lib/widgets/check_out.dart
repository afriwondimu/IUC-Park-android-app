import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart'; // Updated import path

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final _checkOutCouponController = TextEditingController();
  String? _checkOutResult;
  bool _checkOutConfirmMode = false;
  bool _isLoading = false;

  void _checkOut() async {
    setState(() {
      _isLoading = true;
      _checkOutResult = null;
    });

    try {
      final couponCode = int.parse(_checkOutCouponController.text);
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.checkOutService.checkOut(couponCode, _checkOutConfirmMode);
      if (result.startsWith('Plate:') && !_checkOutConfirmMode) {
        setState(() {
          _checkOutResult = result;
          _checkOutConfirmMode = true;
        });
      } else {
        await appState.saveData(); // Calls the restored saveData method
        setState(() {
          _checkOutResult = result;
          _checkOutConfirmMode = false;
          _checkOutCouponController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _checkOutResult = 'የተሳሳተ አሞላል';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _checkOutCouponController.dispose();
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
              'CHECK OUT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _checkOutCouponController,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _checkOutConfirmMode ? Colors.green : Colors.red,
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
                    : Text(
                        _checkOutConfirmMode ? 'ለማረጋገጥ ይጫኑ' : 'ለማስወጣት ይጫኑ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            if (_checkOutResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _checkOutResult!,
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