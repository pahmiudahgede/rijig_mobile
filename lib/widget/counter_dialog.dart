import 'package:flutter/material.dart';

class EditAmountDialog extends StatefulWidget {
  final double initialAmount;
  final String itemName;
  final double pricePerKg;
  final ValueChanged<double> onSave;

  const EditAmountDialog({
    super.key,
    required this.initialAmount,
    required this.itemName,
    required this.pricePerKg,
    required this.onSave,
  });

  @override
  EditAmountDialogState createState() => EditAmountDialogState();
}

class EditAmountDialogState extends State<EditAmountDialog> {
  late double _currentAmount;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.initialAmount;
  }

  String formatAmount(double value) {
    String formattedValue = value.toStringAsFixed(2);

    if (formattedValue.endsWith('.00')) {
      return formattedValue.split('.').first;
    }

    return formattedValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Jumlah ${widget.itemName}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: formatAmount(_currentAmount),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                _currentAmount = double.tryParse(value) ?? 0.0;
              });
            },
            decoration: InputDecoration(
              labelText: "Jumlah (kg)",
              border: OutlineInputBorder(),
              suffixText: 'kg',
            ),
          ),
          SizedBox(height: 20),

          Text(
            "Estimasi Harga: Rp ${(widget.pricePerKg * _currentAmount).toStringAsFixed(0)}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_currentAmount);
            Navigator.of(context).pop();
          },
          child: Text("Simpan"),
        ),
      ],
    );
  }
}
