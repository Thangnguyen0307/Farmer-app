import 'package:farmrole/modules/home/screens/personal/canhan/Address_Detail_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/Address_Provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AddressProvider>().fetchAddresses(context),
    );
  }

  void _showAddDialog() {
    final addressCtrl = TextEditingController();
    final wardCtrl = TextEditingController();
    final provinceCtrl = TextEditingController();

    String? selectedAddressName;

    final List<String> addressOptions = [
      'Nhà riêng',
      'Văn phòng',
      'Công ty',
      'Kho hàng',
    ];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Thêm địa chỉ'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedAddressName,
                    hint: const Text('Chọn loại địa chỉ'),
                    items:
                        addressOptions.map((e) {
                          return DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedAddressName = value;
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
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.clearSnackBars();

                  if (selectedAddressName == null ||
                      selectedAddressName!.isEmpty) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Vui lòng chọn loại địa chỉ.'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.grey.shade900,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  if (addressCtrl.text.trim().isEmpty ||
                      wardCtrl.text.trim().isEmpty ||
                      provinceCtrl.text.trim().isEmpty) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vui lòng nhập đầy đủ Số nhà, Phường/Xã, Tỉnh/TP.',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.grey.shade900,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  final success = await context
                      .read<AddressProvider>()
                      .addAddress(
                        context: context,
                        addressName: selectedAddressName!,
                        address: addressCtrl.text.trim(),
                        ward: wardCtrl.text.trim(),
                        province: provinceCtrl.text.trim(),
                      );

                  if (!mounted) return;

                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            success
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: success ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              success
                                  ? 'Thêm địa chỉ thành công.'
                                  : 'Thêm địa chỉ thất bại. Vui lòng thử lại.',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.grey.shade900,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  if (success) Navigator.pop(context);
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressProvider>().addresses;
    final primary = Theme.of(context).colorScheme.primary;

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
          "Địa chỉ của tôi",
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),

      // List địa chỉ với separator mảnh
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: addresses.length,
        separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
        itemBuilder: (_, index) {
          final addr = addresses[index];
          return ListTile(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddressDetailScreen(addressId: addr.id),
                  ),
                ),
            leading: Icon(Icons.location_on_outlined, color: primary),
            title: Text(
              addr.addressName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${addr.address}, ${addr.ward}, ${addr.province}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),

            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          );
        },
      ),

      // Nút thêm địa chỉ mảnh
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
