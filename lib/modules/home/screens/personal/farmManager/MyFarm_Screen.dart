import 'package:farmrole/modules/home/screens/personal/farmManager/Question_Step2_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/services/CRUD_Farm_Service.dart';
import 'package:farmrole/modules/auth/state/Farm_Provider.dart';

class MyFarmScreen extends StatefulWidget {
  const MyFarmScreen({Key? key}) : super(key: key);

  @override
  State<MyFarmScreen> createState() => _MyFarmScreenState();
}

class _MyFarmScreenState extends State<MyFarmScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      CrudFarmService().getmyFarm(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farms = context.watch<FarmProvider>().farms;

    if (farms.isEmpty) {
      return Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: const Center(
          child: Text(
            'Bạn chưa có farm nào',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    String showOrFallback(String? value) {
      return (value == null || value.isEmpty) ? 'Chưa cập nhật' : value;
    }

    final selectedFarm = farms[selectedIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Farm của tôi',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: "Nunito",
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(90),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, left: 10),
                    child: Text(
                      "Danh sách Farm:",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: farms.length,
                            itemBuilder: (context, index) {
                              final farm = farms[index];
                              final isSelected = index == selectedIndex;
                              return GestureDetector(
                                onTap:
                                    () => setState(() => selectedIndex = index),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      width: 70,
                                      height: 70,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? theme.colorScheme.onPrimary
                                                : Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'lib/assets/image/tree.png',
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Farm ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected
                                                ? theme.colorScheme.onPrimary
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedFarm.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFarm.images.length,
                        itemBuilder: (context, idx) {
                          final img = selectedFarm.images[idx];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(img.getFullUrl()),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoRow(
                      Icons.location_on,
                      "Địa chỉ: ${showOrFallback(selectedFarm.location)}",
                    ),
                    _buildInfoRow(
                      Icons.square_foot,
                      selectedFarm.area > 0
                          ? 'Diện tích: ${selectedFarm.area} m²'
                          : 'Diện tích: Chưa cập nhật',
                    ),
                    _buildInfoRow(
                      Icons.check_circle,
                      selectedFarm.isAvailable
                          ? 'Trạng thái: Có sẵn'
                          : 'Trạng thái: Không có sẵn',
                    ),
                    _buildInfoRow(
                      Icons.bar_chart,
                      'Tình trạng: ${showOrFallback(selectedFarm.status)}',
                    ),
                    _buildInfoRow(
                      Icons.star,
                      'Đánh giá: ${selectedFarm.ratings} (${selectedFarm.reviewCount} lượt)',
                    ),
                    _buildInfoRow(
                      Icons.phone,
                      'Điện thoại: ${showOrFallback(selectedFarm.phone)}',
                    ),
                    _buildInfoRow(
                      Icons.chat,
                      'Zalo: ${showOrFallback(selectedFarm.zalo)}',
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Giờ hoạt động: ${showOrFallback(selectedFarm.operationTime)}',
                    ),
                    _buildInfoRow(
                      Icons.place,
                      'Tỉnh/TP: ${showOrFallback(selectedFarm.province)}',
                    ),
                    _buildInfoRow(
                      Icons.place,
                      'Quận/Huyện: ${showOrFallback(selectedFarm.district)}',
                    ),
                    _buildInfoRow(
                      Icons.place,
                      'Phường/Xã: ${showOrFallback(selectedFarm.ward)}',
                    ),
                    _buildInfoRow(
                      Icons.place,
                      'Đường: ${showOrFallback(selectedFarm.street)}',
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Dịch vụ:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children:
                          selectedFarm.services
                              .map(
                                (s) => Chip(
                                  label: Text(s),
                                  backgroundColor: Colors.green.shade50,
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  side: BorderSide(
                                    color: Colors.green.shade300,
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'Tính năng:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children:
                          selectedFarm.features
                              .map(
                                (f) => Chip(
                                  label: Text(f),
                                  backgroundColor: Colors.blue.shade50,
                                  labelStyle: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  side: BorderSide(color: Colors.blue.shade300),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'Tags:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children:
                          selectedFarm.tags
                              .map(
                                (t) => Chip(
                                  label: Text(t),
                                  backgroundColor: Colors.orange.shade50,
                                  labelStyle: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  side: BorderSide(
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final farmId = selectedFarm.id;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => QuestionStep2Screen(farmId: farmId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment),
                        label: const Text("Làm khảo sát cho farm này"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
