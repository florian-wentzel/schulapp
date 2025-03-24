import 'package:schulapp/code_behind/abi_calculator.dart';
import 'package:schulapp/code_behind/save_manager.dart';

class AbiCalculatorManager {
  static final AbiCalculatorManager _instance =
      AbiCalculatorManager._privateConstructor();

  AbiCalculatorManager._privateConstructor() {
    _abiCalculator = SaveManager().loadAbiCalculator();
  }

  factory AbiCalculatorManager() {
    return _instance;
  }

  late AbiCalculator _abiCalculator;

  AbiCalculator get calculator => _abiCalculator;
}
