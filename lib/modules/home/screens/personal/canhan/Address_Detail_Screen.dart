import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Address_Service.dart';
import 'package:farmrole/shared/types/Address_Model.dart';

class AddressDetailScreen extends StatefulWidget {
  final String addressId;
  const AddressDetailScreen({Key? key, required this.addressId})
    : super(key: key);

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  AddressModel? address;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddressDetail();
  }

  Future<void> _fetchAddressDetail() async {
    try {
      final result = await AddressService().getAddressDetail(
        context: context,
        addressId: widget.addressId,
      );
      if (mounted) {
        setState(() {
          address = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _showEditDialog() {
    final addressOptions = ['Nhà riêng', 'Văn phòng', 'Công ty', 'Kho hàng'];
    String selectedAddressName = address!.addressName;
    final addressCtrl = TextEditingController(text: address!.address);
    final wardCtrl = TextEditingController(text: address!.ward);
    final provinceCtrl = TextEditingController(text: address!.province);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cập nhật địa chỉ'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedAddressName,
                    items:
                        addressOptions.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedAddressName = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Loại địa chỉ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Số nhà/Đường',
                    ),
                  ),
                  TextField(
                    controller: wardCtrl,
                    decoration: const InputDecoration(labelText: 'Phường/Xã'),
                  ),
                  TextField(
                    controller: provinceCtrl,
                    decoration: const InputDecoration(labelText: 'Tỉnh/TP'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await AddressService().updateUserAddress(
                    context: context,
                    id: widget.addressId,
                    addressName: selectedAddressName,
                    address: addressCtrl.text,
                    ward: wardCtrl.text,
                    province: provinceCtrl.text,
                  );
                  await _fetchAddressDetail();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAddress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: const Text('Bạn có chắc muốn xoá địa chỉ này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xoá'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await AddressService().deleteUserAddress(
        context: context,
        id: widget.addressId,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade800,
    );
    final valueStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết địa chỉ',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : address == null
              ? const Center(child: Text('Không tìm thấy địa chỉ'))
              : Column(
                children: [
                  // Loại địa chỉ
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey.shade300),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text('Loại địa chỉ', style: labelStyle),
                    trailing: Text(address!.addressName, style: valueStyle),
                  ),

                  // Số nhà / Đường
                  Divider(height: 1, color: Colors.grey.shade300),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text('Số nhà / Đường', style: labelStyle),
                    trailing: Text(address!.address, style: valueStyle),
                  ),

                  // Phường / Xã
                  Divider(height: 1, color: Colors.grey.shade300),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text('Phường / Xã', style: labelStyle),
                    trailing: Text(address!.ward, style: valueStyle),
                  ),

                  // Tỉnh / TP
                  Divider(height: 1, color: Colors.grey.shade300),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text('Tỉnh / Thành phố', style: labelStyle),
                    trailing: Text(address!.province, style: valueStyle),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  const Spacer(),

                  // Nút Sửa / Xoá
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showEditDialog,
                            icon: Icon(Icons.edit, color: primary),
                            label: Text(
                              'Sửa',
                              style: TextStyle(color: primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _deleteAddress,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Xoá',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
