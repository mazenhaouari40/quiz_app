import 'dart:collection';
import 'dart:math';

class UniqueCodeGenerator {
  final Queue<String> _generatedCodes = Queue();
  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);
  final int maxSize;

  UniqueCodeGenerator({this.maxSize = 1000});

  String generateCode() {
    String newCode;
    do {
      int firstPart = _random.nextInt(900) + 100;
      int secondPart = _random.nextInt(900) + 100;
      newCode = '$firstPart$secondPart';
    } while (_generatedCodes.contains(newCode));

    if (_generatedCodes.length >= maxSize) {
      _generatedCodes.removeFirst(); // Remove oldest code
    }

    _generatedCodes.add(newCode);
    return newCode;
  }
}
