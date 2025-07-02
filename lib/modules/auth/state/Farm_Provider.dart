import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';

class FarmProvider extends ChangeNotifier {
  List<FarmModel> _farms = [];

  List<FarmModel> get farms => _farms;

  void setFarms(List<FarmModel> farms) {
    _farms = farms;
    notifyListeners();
  }

  void clearFarms() {
    _farms = [];
    notifyListeners();
  }

  FarmModel? getFarmById(String id) {
    try {
      return _farms.firstWhere((farm) => farm.id == id);
    } catch (_) {
      return null;
    }
  }
}
