import 'package:flutter/material.dart';

class CounterInput extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const CounterInput({
    super.key,
    this.initialValue = 0,
    required this.onChanged,
  });

  @override
  CounterInputState createState() => CounterInputState();
}

class CounterInputState extends State<CounterInput> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _value += 0.25;
    });
    widget.onChanged(_value);
  }

  void _decrement() {
    if (_value > 0.25) {
      setState(() {
        _value -= 0.25;
      });
      widget.onChanged(_value);
    }
  }

  void _onChanged(String text) {
    double? parsedValue = double.tryParse(text);
    if (parsedValue != null && parsedValue >= 0) {
      setState(() {
        _value = parsedValue;
      });
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _decrement,
          icon: Icon(Icons.remove),
          color: Colors.red,
        ),

        SizedBox(
          width: 60,
          child: TextField(
            onChanged: _onChanged,
            controller: TextEditingController(text: _value.toStringAsFixed(2)),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        IconButton(
          onPressed: _increment,
          icon: Icon(Icons.add),
          color: Colors.green,
        ),
      ],
    );
  }
}
