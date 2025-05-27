import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class ExportForm extends StatefulWidget {
  const ExportForm({super.key});

  @override
  _ExportFormState createState() => _ExportFormState();
}

class _ExportFormState extends State<ExportForm> {
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _plateController = TextEditingController();
  String? _result;
  bool _isLoading = false;

  void _export() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final year = _yearController.text.trim();
    final month = _monthController.text.trim();
    final day = _dayController.text.trim();
    final plateInput = _plateController.text.trim();
    int? plateNumber = plateInput.isEmpty ? null : int.tryParse(plateInput);

    if (year.length != 4 || int.tryParse(year) == null || int.parse(year) < 2000) {
      setState(() {
        _result = 'ዓ/ም በአግባቡ ያስገቡ';
        _isLoading = false;
      });
      return;
    }
    if (month.isEmpty || int.tryParse(month) == null || int.parse(month) < 1 || int.parse(month) > 12) {
      setState(() {
        _result = 'ወር በአግባቡ ያስገቡ';
        _isLoading = false;
      });
      return;
    }
    if (day.isEmpty || int.tryParse(day) == null || int.parse(day) < 1 || int.parse(day) > 31) {
      setState(() {
        _result = 'ቀን በአግባቡ ያስገቡ';
        _isLoading = false;
      });
      return;
    }

    final date = '$year${month.padLeft(2, '0')}${day.padLeft(2, '0')}';
    
    if (!RegExp(r'^\d{8}$').hasMatch(date)) {
      setState(() {
        _result = 'የተሳሳተ ቀን አቆጣጠር አስገብተዋል እባክዎት አስተካክለው ያስገቡ';
        _isLoading = false;
      });
      return;
    }

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.exportService.exportRecords(date, plateNumber);
      setState(() {
        _result = result;
        _yearController.clear();
        _monthController.clear();
        _dayController.clear();
        _plateController.clear();
      });
    } catch (e) {
      setState(() {
        _result = 'Export failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _plateController.dispose();
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
              'EXPORT DATA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ቀን',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      labelText: 'ዓመት',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 4,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _monthController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_view_month, color: Colors.grey.shade600),
                      labelText: 'ወር',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 2,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _dayController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_view_day, color: Colors.grey.shade600),
                      labelText: 'ቀን',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 2,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'ታርጋ ቁጥር (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _plateController,
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
                onPressed: _isLoading ? null : _export,
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
                        'EXPORT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}