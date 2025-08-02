import 'dart:convert';
import 'package:farmrole/env/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../state/User_Provider.dart';
import '../../../shared/types/Address_Model.dart';

class AddressService {
  static final String _baseUrl = Environment.config.baseUrl;

  Future<void> createUserAddress({
    required BuildContext context,
    required String addressName,
    required String address,
    required String ward,
    required String province,
  }) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse('$_baseUrl/user-addresses');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
      body: jsonEncode({
        'addressName': addressName,
        'address': address,
        'ward': ward,
        'province': province,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm địa chỉ thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm địa chỉ thất bại: ${response.body}')),
      );
    }
  }

  Future<List<AddressModel>> getUserAddresses(BuildContext context) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse('$_baseUrl/user-addresses');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => AddressModel.fromJson(e)).toList();
    } else {
      throw Exception('Lấy danh sách địa chỉ thất bại: ${response.statusCode}');
    }
  }

  //get address by id
  Future<AddressModel> getAddressDetail({
    required BuildContext context,
    required String addressId,
  }) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse('$_baseUrl/user-addresses/$addressId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return AddressModel.fromJson(jsonMap);
    } else {
      throw Exception('Lấy chi tiết địa chỉ thất bại: ${response.statusCode}');
    }
  }

  //Update dia chi
  Future<void> updateUserAddress({
    required BuildContext context,
    required String id,
    required String addressName,
    required String address,
    required String ward,
    required String province,
  }) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse('$_baseUrl/user-addresses/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
      body: jsonEncode({
        'addressName': addressName,
        'address': address,
        'ward': ward,
        'province': province,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật địa chỉ thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật địa chỉ thất bại: ${response.body}')),
      );
    }
  }

  //xoá địa chỉ
  Future<void> deleteUserAddress({
    required BuildContext context,
    required String id,
  }) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse('$_baseUrl/user-addresses/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xoá địa chỉ thành công')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xoá địa chỉ thất bại: ${response.body}')),
      );
    }
  }
}
