import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/FarmSurveyDetailScreen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Question_Step2_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Register_Step1_Farm.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Farm_image.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
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
  String _getVietnameseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Đang hoạt động';
      case 'inactive':
        return 'Ngừng hoạt động';
      case 'pending':
        return 'Đang chờ duyệt';
      default:
        return 'Chưa cập nhật';
    }
  }

  final Map<String, String> SERVICE_ICON_PATHS = {
    "Bán trực tiếp": "lib/assets/Enum/Direct.png",
    "Bán thức ăn": "lib/assets/Enum/Feed.png",
    "Trộn thức ăn": "lib/assets/Enum/Custom_feed.png",
    "Chế biến": "lib/assets/Enum/Processing.png",
    "Kho bãi": "lib/assets/Enum/Storage.png",
    "Vận chuyển": "lib/assets/Enum/Transport.png",
    "Khác": "lib/assets/Enum/Other.png",
  };

  final Map<String, String> FEATURE_ICON_PATHS = {
    "Aquaponic": "lib/assets/Enum/Aquaponic.png",
    "RAS": "lib/assets/Enum/Ras.png",
    "Thủy canh": "lib/assets/Enum/Hydroponic.png",
    "Nhà kính": "lib/assets/Enum/Greenhouse.png",
    "Đa tầng": "lib/assets/Enum/Vertical.png",
    "VietGAP": "lib/assets/Enum/Vietgap.png",
    "Organic": "lib/assets/Enum/Organic.png",
    "GlobalGAP": "lib/assets/Enum/Global.png",
    "HACCP": "lib/assets/Enum/HACCP.png",
    "Camera": "lib/assets/Enum/Camera.png",
    "Drone": "lib/assets/Enum/Drone.png",
    "Pest AI": "lib/assets/Enum/Auto_pest.png",
    "Irrigation AI": "lib/assets/Enum/Precision_irri.png",
    "Tự động": "lib/assets/Enum/auto_irrigation.png",
    "Cảm biến đất": "lib/assets/Enum/Soil_based.png",
    "Không khí": "lib/assets/Enum/Air_quality.png",
  };

  final Map<String, String> SERVICE_MAP_REVERSE = {
    "direct_selling": "Bán trực tiếp",
    "feed_selling": "Bán thức ăn",
    "custom_feed_blending": "Trộn thức ăn",
    "processing_service": "Chế biến",
    "storage_service": "Kho bãi",
    "transport_service": "Vận chuyển",
    "other_services": "Khác",
  };

  final Map<String, String> FEATURE_MAP_REVERSE = {
    "aquaponic_model": "Aquaponic",
    "ras_ready": "RAS",
    "hydroponic": "Thủy canh",
    "greenhouse": "Nhà kính",
    "vertical_farming": "Đa tầng",
    "viet_gap_cert": "VietGAP",
    "organic_cert": "Organic",
    "global_gap_cert": "GlobalGAP",
    "haccp_cert": "HACCP",
    "camera_online": "Camera",
    "drone_monitoring": "Drone",
    "automated_pest_detection": "Pest AI",
    "precision_irrigation": "Irrigation AI",
    "auto_irrigation": "Tự động",
    "soil_based_irrigation": "Cảm biến đất",
    "air_quality_sensor": "Không khí",
  };

  String _formatAddress(
    String? street,
    String? ward,
    String? district,
    String? province,
  ) {
    final parts =
        [
          street?.trim(),
          ward?.trim(),
          district?.trim(),
          province?.trim(),
        ].where((part) => part != null && part.isNotEmpty).toList();

    if (parts.isEmpty) return 'Chưa cập nhật';
    return parts.join(', ');
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => CrudFarmService().getmyFarm(context));
  }

  void _showFarmImagesViewer(
    BuildContext context,
    List<FarmImage> images,
    int initialIndex,
  ) {
    final imageWidgets =
        images
            .map(
              (img) => PhotoView(
                imageProvider: NetworkImage(img.getFullUrl()),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              ),
            )
            .toList();

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: imageWidgets.length,
                  itemBuilder: (_, i) => imageWidgets[i],
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  //xoa anh
  Future<void> _deleteFarmImage(String imageId) async {
    try {
      final user = context.read<UserProvider>().user!;
      await CrudFarmService.deleteFarmImage(
        token: user.token!,
        imageId: imageId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xoá ảnh thành công')));
      await CrudFarmService().getmyFarm(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xoá ảnh thất bại: $e')));
    }
  }

  Future<void> _pickAndUploadImage(FarmModel farm) async {
    if (farm.status.toLowerCase() == 'inactive') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Farm đã ngừng hoạt động.')));
      return;
    }
    if (farm.status.toLowerCase() == 'pending') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Farm đang chờ duyệt.')));
      return;
    }

    if (farm.images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ được tải tối đa 5 ảnh cho mỗi farm.'),
        ),
      );
      return;
    }
    final picker = UploadFarmImage();
    final file = await picker.pickImageWithDialog(context);
    if (file != null) {
      final user = context.read<UserProvider>().user!;
      await CrudFarmService.uploadFarmImage(
        token: user.token!,
        farmId: farm.id,
        imageFile: file,
        description: 'Ảnh farm thêm từ app',
        isDefault: false,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tải ảnh lên thành công')));
      await CrudFarmService().getmyFarm(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farms = context.watch<FarmProvider>().farms;
    final theme = Theme.of(context);

    if (farms.isEmpty) {
      return _buildEmptyFarm(theme);
    }

    final selectedFarm = farms[selectedIndex];
    return WillPopScope(
      onWillPop: () async {
        context.go('/manager');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/manager');
              }
            },
          ),
          title: Text(
            'Farm của tôi',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildFarmSelector(theme, farms),
            _buildFarmDetail(theme, selectedFarm),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFarm(ThemeData theme) => Scaffold(
    backgroundColor: theme.colorScheme.primary,
    appBar: AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text('Farm của tôi'),
      centerTitle: true,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/icon/Signup.png',
            height: 130,
            width: 130,
            fit: BoxFit.cover,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          const Text(
            'Bạn chưa có farm nào',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterStep1Farm()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo farm ngay'),
          ),
        ],
      ),
    ),
  );

  Widget _buildFarmSelector(ThemeData theme, List<FarmModel> farms) =>
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
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: farms.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 70,
                              height: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
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
            ],
          ),
        ),
      );

  Widget _buildFarmDetail(ThemeData theme, FarmModel farm) => Expanded(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              farm.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildFarmImages(farm),
            const SizedBox(height: 24),
            ..._buildFarmInfos(farm),
            const SizedBox(height: 16),
            if (farm.services.isNotEmpty)
              _buildIconWrap(
                'Dịch vụ',
                farm.services.map((e) => SERVICE_MAP_REVERSE[e] ?? e).toList(),
                SERVICE_ICON_PATHS,
              ),

            if (farm.features.isNotEmpty)
              _buildIconWrap(
                'Công nghệ',
                farm.features.map((e) => FEATURE_MAP_REVERSE[e] ?? e).toList(),
                FEATURE_ICON_PATHS,
              ),

            if (farm.tags.isNotEmpty) _buildTagWrap('Thẻ tag', farm.tags),
            const SizedBox(height: 24),
            _buildSurveyButton(theme, farm.id),
          ],
        ),
      ),
    ),
  );

  Widget _buildFarmImages(FarmModel farm) {
    final images = farm.images;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4 / 3,
            ),
            itemCount: images.length,
            itemBuilder: (context, idx) {
              final image = images[idx];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showFarmImagesViewer(context, images, idx),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        image.getFullUrl(),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () async {
                        await _deleteFarmImage(image.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        else
          Column(
            children: [
              const Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              const Text(
                'Chưa có ảnh farm',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        if (images.length < 5)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () => _pickAndUploadImage(farm),
              icon: Image.asset(
                'lib/assets/icon/Upload.png',
                width: 24,
                height: 24,
              ),
              label: const Text("Thêm ảnh farm"),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildFarmInfos(FarmModel farm) => [
    _infoRow(
      Image.asset('lib/assets/icon/Adr.png', width: 24, height: 24),
      'Địa chỉ: ${_formatAddress(farm.street, farm.ward, farm.district, farm.province)}',
    ),
    _infoRow(
      Image.asset('lib/assets/icon/Area.png', width: 24, height: 24),
      farm.area > 0 ? 'Diện tích: ${farm.area} m²' : 'Diện tích: Chưa cập nhật',
    ),
    _infoRow(
      Image.asset('lib/assets/icon/Area.png', width: 24, height: 24),
      farm.area > 0
          ? 'Diện tích canh tác: ${farm.cultivatedArea} m²'
          : 'Diện tích canh tác: Chưa cập nhật',
    ),
    _infoRow(
      Image.asset('lib/assets/icon/Status_Product.png', width: 24, height: 24),
      farm.isAvailable
          ? 'Trạng thái sản phẩm: Có sẵn'
          : 'Trạng thái: Không có sẵn',
    ),
    _infoRow(
      Image.asset('lib/assets/icon/Status.png', width: 24, height: 24),
      'Tình trạng trang trại: ${_getVietnameseStatus(farm.status)}',
    ),
    _infoRow(
      Image.asset('lib/assets/icon/Phone.png', width: 24, height: 24),
      'Điện thoại: ${_showOrFallback(farm.phone)}',
    ),
    _infoRow(
      Image.asset('lib/assets/icon/Zalo2.png', width: 24, height: 24),
      'Zalo: ${_showOrFallback(farm.zalo)}',
    ),
  ];

  Widget _infoRow(Widget iconWidget, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 24, height: 24, child: Center(child: iconWidget)),
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

  Widget _buildIconWrap(
    String title,
    List<String> items,
    Map<String, String> iconPaths,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items.map((item) {
                final path = iconPaths[item];
                return Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (path != null)
                        Image.asset(path, width: 24, height: 24)
                      else
                        const Icon(Icons.help_outline, size: 24),
                      const SizedBox(width: 4),
                      Text(item, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTagWrap(String title, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 13)),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSurveyButton(ThemeData theme, String farmId) => Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FarmSurveyDetailScreen(farmId: farmId),
                ),
              ),
          icon: const Icon(Icons.visibility),
          label: const Text("Xem khảo sát"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  String _showOrFallback(String? value) =>
      (value == null || value.isEmpty) ? 'Chưa cập nhật' : value;
}
