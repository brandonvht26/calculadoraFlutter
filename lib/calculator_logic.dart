class CalculatorLogic {
  String _expression = '';
  String _currentInput = '';
  bool _shouldResetInput = false;
  double? _lastResult;
  String? _lastOperator;
  bool _justEvaluated = false;

  String get display {
    if (_currentInput.isEmpty && _expression.isEmpty) return '0';
    if (_currentInput.isEmpty) return _expression;
    return _currentInput;
  }

  String get expression => _expression;

  void inputNumber(String digit) {
    if (_justEvaluated) {
      _expression = '';
      _currentInput = '';
      _justEvaluated = false;
    }

    if (_shouldResetInput) {
      _currentInput = digit;
      _shouldResetInput = false;
    } else {
      if (_currentInput == '0' && digit != '.') {
        _currentInput = digit;
      } else {
        _currentInput += digit;
      }
    }
  }

  void inputDecimal() {
    if (_justEvaluated) {
      _expression = '';
      _currentInput = '0.';
      _justEvaluated = false;
      _shouldResetInput = false;
      return;
    }

    if (!_currentInput.contains('.')) {
      if (_currentInput.isEmpty) {
        _currentInput = '0.';
      } else {
        _currentInput += '.';
      }
      _shouldResetInput = false;
    }
  }

  void inputOperator(String op) {
    final cleanOp = _cleanOperator(op);

    if (_justEvaluated && _lastResult != null) {
      _expression = _formatNumber(_lastResult!);
      _currentInput = '';
      _justEvaluated = false;
    }

    if (_currentInput.isNotEmpty) {
      if (_expression.isNotEmpty &&
          _isOperator(_expression[_expression.length - 1].toString())) {
        _expression += _currentInput;
      } else {
        _expression += _currentInput;
      }
      _currentInput = '';
    } else if (_expression.isEmpty && _lastResult != null) {
      _expression = _formatNumber(_lastResult!);
    }

    if (_expression.isNotEmpty &&
        _isOperator(_expression[_expression.length - 1].toString())) {
      _expression = _expression.substring(0, _expression.length - 1) + cleanOp;
    } else if (_expression.isNotEmpty || cleanOp == '-') {
      if (cleanOp == '-' &&
          (_expression.isEmpty ||
              _isOperator(_expression[_expression.length - 1].toString()))) {
        _currentInput = '-';
        _shouldResetInput = false;
        return;
      }
      _expression += cleanOp;
    }

    _lastOperator = op;
    _shouldResetInput = true;
  }

  void inputPercent() {
    if (_currentInput.isNotEmpty) {
      final value = double.tryParse(_currentInput);
      if (value != null) {
        _currentInput = _formatNumber(value / 100);
      }
    } else if (_expression.isNotEmpty) {
      final result = _evaluateExpression(_expression);
      if (result != null) {
        _currentInput = _formatNumber(result / 100);
        _expression = '';
      }
    }
    _shouldResetInput = true;
  }

  void toggleSign() {
    if (_currentInput.isNotEmpty) {
      if (_currentInput.startsWith('-')) {
        _currentInput = _currentInput.substring(1);
      } else {
        _currentInput = '-$_currentInput';
      }
    }
  }

  void backspace() {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      if (_currentInput.isEmpty || _currentInput == '-') {
        _currentInput = '';
      }
    }
  }

  void clear() {
    _expression = '';
    _currentInput = '';
    _shouldResetInput = false;
    _lastResult = null;
    _lastOperator = null;
    _justEvaluated = false;
  }

  String? calculate() {
    if (_justEvaluated && _lastOperator != null && _lastResult != null) {
      final secondOperand =
          double.tryParse(_currentInput.isNotEmpty ? _currentInput : '0');
      if (secondOperand != null) {
        _lastResult = _applyOperator(_lastResult!, secondOperand, _lastOperator!);
        _expression = '';
        _currentInput = _formatNumber(_lastResult!);
        _justEvaluated = true;
        return _currentInput;
      }
    }

    if (_currentInput.isNotEmpty) {
      _expression += _currentInput;
    }

    if (_expression.isEmpty) return '0';

    final cleanExpr = _expression.replaceAll('×', '*').replaceAll('÷', '/');
    final result = _evaluateExpression(cleanExpr);

    if (result != null) {
      _lastResult = result;
      // Guardar el último operador para operaciones repetidas
      final match = RegExp(r'[+\-*/]').firstMatch(_expression);
      if (match != null && _currentInput.isNotEmpty) {
        _lastOperator = match.group(0);
      }
      _expression = '';
      _currentInput = _formatNumber(result);
      _shouldResetInput = true;
      _justEvaluated = true;
      return _currentInput;
    }

    return null;
  }

  String get clearButtonLabel {
    return (_expression.isNotEmpty || _currentInput.isNotEmpty) ? 'C' : 'AC';
  }

  // --- Private helpers ---

  String _cleanOperator(String op) {
    switch (op) {
      case '×':
        return '×';
      case '÷':
        return '÷';
      case '+':
        return '+';
      case '−':
        return '−';
      default:
        return op;
    }
  }

  bool _isOperator(String char) {
    return char == '+' || char == '−' || char == '×' || char == '÷';
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    String str = value.toString();
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      if (str.endsWith('.')) str = str.substring(0, str.length - 1);
    }
    return str;
  }

  double? _evaluateExpression(String expression) {
    try {
      final tokens = _tokenize(expression);
      if (tokens.isEmpty) return null;
      final result = _parseExpression(tokens, 0);
      return result.value;
    } catch (_) {
      return null;
    }
  }

  List<_Token> _tokenize(String expr) {
    final tokens = <_Token>[];
    int i = 0;

    while (i < expr.length) {
      final char = expr[i];

      if (char == ' ') {
        i++;
        continue;
      }

      if (_isOperatorChar(char)) {
        if (char == '-' &&
            (tokens.isEmpty ||
                tokens.last.type == _TokenType.op ||
                tokens.last.type == _TokenType.lparen)) {
          tokens.add(_Token.num(-1));
          tokens.add(_Token.op('*'));
        } else {
          tokens.add(_Token.op(char));
        }
        i++;
      } else if (char == '(') {
        tokens.add(_Token.lparen());
        i++;
      } else if (char == ')') {
        tokens.add(_Token.rparen());
        i++;
      } else if (_isDigit(char) || char == '.') {
        final buffer = StringBuffer();
        while (i < expr.length && (_isDigit(expr[i]) || expr[i] == '.')) {
          buffer.write(expr[i]);
          i++;
        }
        final value = double.tryParse(buffer.toString());
        if (value != null) {
          tokens.add(_Token.num(value));
        }
      } else {
        i++;
      }
    }

    return tokens;
  }

  bool _isOperatorChar(String char) {
    return char == '+' || char == '−' || char == '-' || char == '×' || char == '*' || char == '÷' || char == '/';
  }

  bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }

  _ParseResult _parseExpression(List<_Token> tokens, int pos) {
    var result = _parseTerm(tokens, pos);
    pos = result.pos;

    while (pos < tokens.length &&
        tokens[pos].type == _TokenType.op &&
        (tokens[pos].op == '+' || tokens[pos].op == '−' || tokens[pos].op == '-')) {
      final op = tokens[pos].op == '−' ? '-' : tokens[pos].op!;
      pos++;
      final right = _parseTerm(tokens, pos);
      pos = right.pos;
      result = _ParseResult(_applyOperator(result.value, right.value, op), pos);
    }

    return result;
  }

  _ParseResult _parseTerm(List<_Token> tokens, int pos) {
    var result = _parseFactor(tokens, pos);
    pos = result.pos;

    while (pos < tokens.length &&
        tokens[pos].type == _TokenType.op &&
        (tokens[pos].op == '×' || tokens[pos].op == '*' || tokens[pos].op == '÷' || tokens[pos].op == '/')) {
      final op = tokens[pos].op == '÷' ? '/' : tokens[pos].op == '×' ? '*' : tokens[pos].op!;
      pos++;
      final right = _parseFactor(tokens, pos);
      pos = right.pos;
      result = _ParseResult(_applyOperator(result.value, right.value, op), pos);
    }

    return result;
  }

  _ParseResult _parseFactor(List<_Token> tokens, int pos) {
    if (pos >= tokens.length) return _ParseResult(0, pos);

    final token = tokens[pos];

    if (token.type == _TokenType.num) {
      return _ParseResult(token.value!, pos + 1);
    }

    if (token.type == _TokenType.op && token.op == '−') {
      final right = _parseFactor(tokens, pos + 1);
      return _ParseResult(-right.value, right.pos);
    }

    if (token.type == _TokenType.lparen) {
      pos++;
      final result = _parseExpression(tokens, pos);
      pos = result.pos;
      if (pos < tokens.length && tokens[pos].type == _TokenType.rparen) {
        pos++;
      }
      return _ParseResult(result.value, pos);
    }

    return _ParseResult(0, pos);
  }

  double _applyOperator(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
      case '−':
        return a - b;
      case '*':
      case '×':
        return a * b;
      case '/':
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }
}

class _Token {
  final _TokenType type;
  final double? value;
  final String? op;

  _Token.num(this.value)
      : type = _TokenType.num,
        op = null;
  _Token.op(this.op)
      : type = _TokenType.op,
        value = null;
  _Token.lparen()
      : type = _TokenType.lparen,
        value = null,
        op = null;
  _Token.rparen()
      : type = _TokenType.rparen,
        value = null,
        op = null;
}

enum _TokenType { num, op, lparen, rparen }

class _ParseResult {
  final double value;
  final int pos;
  _ParseResult(this.value, this.pos);
}
