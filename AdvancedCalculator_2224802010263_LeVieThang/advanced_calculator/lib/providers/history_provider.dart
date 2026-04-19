import 'package:flutter/material.dart';

import '../models/calculation_history.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService _storageService;

  HistoryProvider(this._storageService);

  List<CalculationHistory> _histories = [];

  List<CalculationHistory> get histories => List.unmodifiable(_histories);

  void loadHistory() {
    _histories = _storageService.loadHistory();
    notifyListeners();
  }

  Future<void> addHistory(CalculationHistory item, {int maxSize = 50}) async {
    _histories.insert(0, item);

    if (_histories.length > maxSize) {
      _histories = _histories.take(maxSize).toList();
    }

    await _storageService.saveHistory(_histories);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _histories.clear();
    await _storageService.saveHistory(_histories);
    notifyListeners();
  }

  Future<void> removeHistoryAt(int index) async {
    if (index >= 0 && index < _histories.length) {
      _histories.removeAt(index);
      await _storageService.saveHistory(_histories);
      notifyListeners();
    }
  }
}