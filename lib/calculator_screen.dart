import 'package:flutter/material.dart';
import 'calculator_logic.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorLogic _logic = CalculatorLogic();
  bool _showExpression = false;

  void _onNumber(String digit) {
    setState(() {
      _logic.inputNumber(digit);
    });
  }

  void _onOperator(String op) {
    setState(() {
      _logic.inputOperator(op);
      _showExpression = _logic.expression.isNotEmpty;
    });
  }

  void _onEquals() {
    setState(() {
      _logic.calculate();
      _showExpression = false;
    });
  }

  void _onClear() {
    setState(() {
      _logic.clear();
      _showExpression = false;
    });
  }

  void _onPercent() {
    setState(() {
      _logic.inputPercent();
    });
  }

  void _onDecimal() {
    setState(() {
      _logic.inputDecimal();
    });
  }

  void _onBackspace() {
    setState(() {
      _logic.backspace();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            _buildDisplay(),
            _buildButtonGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_showExpression && _logic.expression.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _logic.expression,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _logic.display,
                style: const TextStyle(
                  fontSize: 56,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            _buildButtonRow([
              _calcButton(_logic.clearButtonLabel, _onClear,
                  bgColor: const Color(0xFFA5A5A5), textColor: Colors.black),
              _calcButton('\u232B', _onBackspace,
                  bgColor: const Color(0xFFA5A5A5), textColor: Colors.black),
              _calcButton('%', _onPercent,
                  bgColor: const Color(0xFFA5A5A5), textColor: Colors.black),
              _calcButton('\u00F7', () => _onOperator('\u00F7'),
                  bgColor: const Color(0xFFFF9F0A), textColor: Colors.white),
            ]),
            _buildButtonRow([
              _calcButton('7', () => _onNumber('7')),
              _calcButton('8', () => _onNumber('8')),
              _calcButton('9', () => _onNumber('9')),
              _calcButton('\u00D7', () => _onOperator('\u00D7'),
                  bgColor: const Color(0xFFFF9F0A), textColor: Colors.white),
            ]),
            _buildButtonRow([
              _calcButton('4', () => _onNumber('4')),
              _calcButton('5', () => _onNumber('5')),
              _calcButton('6', () => _onNumber('6')),
              _calcButton('\u2212', () => _onOperator('\u2212'),
                  bgColor: const Color(0xFFFF9F0A), textColor: Colors.white),
            ]),
            _buildButtonRow([
              _calcButton('1', () => _onNumber('1')),
              _calcButton('2', () => _onNumber('2')),
              _calcButton('3', () => _onNumber('3')),
              _calcButton('+', () => _onOperator('+'),
                  bgColor: const Color(0xFFFF9F0A), textColor: Colors.white),
            ]),
            _buildButtonRow([
              _calcButton('0', () => _onNumber('0')),
              _calcButton('.', _onDecimal),
              _calcButton('=', _onEquals,
                  bgColor: const Color(0xFFFF9F0A), textColor: Colors.white),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) => Expanded(child: btn)).toList(),
      ),
    );
  }

  Widget _calcButton(
    String label,
    VoidCallback onTap, {
    Color? bgColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: bgColor ?? const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
