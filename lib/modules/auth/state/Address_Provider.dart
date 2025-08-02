import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Address_Model.dart';
import 'package:farmrole/modules/auth/services/Address_Service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();
  List<AddressModel> _addresses = [];

  List<AddressModel> get addresses => _addresses;

  Future<void> fetchAddresses(BuildContext context) async {
    _addresses = await _addressService.getUserAddresses(context);
    notifyListeners();
  }

  Future<bool> addAddress({
    required BuildContext context,
    required String addressName,
    required String address,
    required String ward,
    required String province,
  }) async {
    try {
      final success = await _addressService.createUserAddress(
        context: context,
        addressName: addressName,
        address: address,
        ward: ward,
        province: province,
      );

      await fetchAddresses(context);
      return true;
    } catch (e) {
      return false;
    }
  }
}
