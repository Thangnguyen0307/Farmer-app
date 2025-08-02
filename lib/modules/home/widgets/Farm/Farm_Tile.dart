import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';

class FarmTile extends StatelessWidget {
  final FarmModel farm;
  final VoidCallback? onTap;

  FarmTile({Key? key, required this.farm, this.onTap}) : super(key: key);

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

    return parts.isEmpty ? 'Chưa cập nhật' : parts.join(', ');
  }

  String _getVietnameseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Đang hoạt động';
      case 'inactive':
        return 'Ngừng hoạt động';
      case 'pending':
        return 'Đang chờ duyệt';
      default:
        return 'Chưa rõ';
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

  @override
  Widget build(BuildContext context) {
    if (farm.status.toLowerCase() != 'active') return const SizedBox.shrink();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // không dùng boxShadow để giữ phẳng
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh lớn ở trên full width
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  farm.images.isNotEmpty
                      ? Image.network(
                        farm.images.first.getFullUrl(),
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
            ),

            // 2. Thông tin bên dưới
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên farm
                  Text(
                    farm.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Địa chỉ
                  Text(
                    _formatAddress(
                      farm.street,
                      farm.ward,
                      farm.district,
                      farm.province,
                    ),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),

                  // Trạng thái & diện tích
                  Row(
                    children: [
                      Text(
                        'Trạng thái: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _getVietnameseStatus(farm.status),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Diện tích: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        farm.area > 0 ? '${farm.area} m²' : 'Chưa cập nhật',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Liên hệ
                  if (farm.phone != null || farm.zalo != null)
                    Text(
                      'SĐT: ${farm.phone ?? '---'}  |  Zalo: ${farm.zalo ?? '---'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Tính năng
                  if (farm.features.isNotEmpty) ...[
                    Text(
                      'Tính năng:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          farm.features.map((featureKey) {
                            final name =
                                FEATURE_MAP_REVERSE[featureKey] ?? featureKey;
                            final path = FEATURE_ICON_PATHS[name];
                            return _buildIconLabel(path, name);
                          }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Dịch vụ
                  if (farm.services.isNotEmpty) ...[
                    Text(
                      'Dịch vụ:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          farm.services.map((serviceKey) {
                            final name =
                                SERVICE_MAP_REVERSE[serviceKey] ?? serviceKey;
                            final path = SERVICE_ICON_PATHS[name];
                            return _buildIconLabel(path, name);
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconLabel(String? iconPath, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconPath != null) Image.asset(iconPath, width: 16, height: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
