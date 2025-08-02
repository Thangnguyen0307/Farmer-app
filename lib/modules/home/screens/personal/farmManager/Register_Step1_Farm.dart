import 'package:farmrole/modules/auth/services/CRUD_Farm_Service.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Question_Step2_Screen.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';

class RegisterStep1Farm extends StatefulWidget {
  const RegisterStep1Farm({Key? key}) : super(key: key);

  @override
  _RegisterStep1FarmState createState() => _RegisterStep1FarmState();
}

class _RegisterStep1FarmState extends State<RegisterStep1Farm> {
  final _formKey = GlobalKey<FormState>();
  FarmModel _newFarm = FarmModel.empty();

  bool _isLoading = false;

  //chuyen data ve tieng viet
  final Map<String, String> SERVICE_MAP = {
    "Bán trực tiếp": "direct_selling",
    "Bán thức ăn": "feed_selling",
    "Trộn thức ăn": "custom_feed_blending",
    "Chế biến": "processing_service",
    "Kho bãi": "storage_service",
    "Vận chuyển": "transport_service",
    "Khác": "other_services",
  };

  final Map<String, String> FEATURE_MAP = {
    "Aquaponic": "aquaponic_model",
    "RAS": "ras_ready",
    "Thủy canh": "hydroponic",
    "Nhà kính": "greenhouse",
    "Đa tầng": "vertical_farming",
    "VietGAP": "viet_gap_cert",
    "Organic": "organic_cert",
    "GlobalGAP": "global_gap_cert",
    "HACCP": "haccp_cert",
    "Camera": "camera_online",
    "Drone": "drone_monitoring",
    "Pest AI": "automated_pest_detection",
    "Irrigation AI": "precision_irrigation",
    "Tự động": "auto_irrigation",
    "Cảm biến đất": "soil_based_irrigation",
    "Không khí": "air_quality_sensor",
  };

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

  List<String> selServ = [], selFeat = [], selTags = [];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Tạo Farm Mới',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: Colors.white24, height: 1, thickness: 0.5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SectionCard(
                title: 'Thông tin cơ bản',
                child: Column(
                  children: [
                    _buildTextField(
                      'Tên farm',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(name: v),
                    ),
                    _buildTextField(
                      'Địa chỉ',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(location: v),
                    ),
                    _buildTextField(
                      'Diện tích (m²)',
                      keyboardType: TextInputType.number,
                      onSaved:
                          (v) =>
                              _newFarm = _newFarm.copyWith(
                                area: double.tryParse(v ?? '') ?? 0,
                              ),
                    ),
                    _buildTextField(
                      'Diện tích đang canh tác (m²)',
                      keyboardType: TextInputType.number,
                      onSaved:
                          (v) =>
                              _newFarm = _newFarm.copyWith(
                                cultivatedArea: double.tryParse(v ?? '') ?? 0,
                              ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Dịch vụ & Tính năng',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterGroup(
                      'Dịch vụ cung cấp',
                      SERVICE_MAP.keys.toList(),
                      selServ,
                    ),
                    const SizedBox(height: 12),
                    _buildFilterGroup(
                      'Tính năng nổi bật',
                      FEATURE_MAP.keys.toList(),
                      selFeat,
                    ),
                    const SizedBox(height: 12),
                    _buildTagsInput(),
                  ],
                ),
              ),
              SectionCard(
                title: 'Liên hệ',
                child: Column(
                  children: [
                    _buildTextField(
                      'Số điện thoại',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(phone: v),
                      required: false,
                    ),
                    _buildTextField(
                      'Zalo',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(zalo: v),
                      required: false,
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Địa chỉ chi tiết',
                child: Column(
                  children: [
                    _buildTextField(
                      'Tỉnh/TP',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(province: v),
                    ),
                    _buildTextField(
                      'Quận/Huyện',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(district: v),
                    ),
                    _buildTextField(
                      'Phường/Xã',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(ward: v),
                    ),
                    _buildTextField(
                      'Đường',
                      onSaved: (v) => _newFarm = _newFarm.copyWith(street: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // trong build():
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _isLoading ? null : _handleSubmit,
                    child: Center(
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Tiếp theo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        onSaved: onSaved,
        keyboardType: keyboardType,
        validator:
            required
                ? (v) => v == null || v.isEmpty ? 'Vui lòng nhập $label' : null
                : null,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterGroup(
    String title,
    List<String> items,
    List<String> selected,
  ) {
    final isService = title.contains('Dịch vụ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              items.map((item) {
                final isSel = selected.contains(item);
                final imagePath =
                    isService
                        ? SERVICE_ICON_PATHS[item]
                        : FEATURE_ICON_PATHS[item];

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imagePath != null)
                        Image.asset(imagePath, width: 24, height: 24)
                      else
                        const Icon(Icons.help_outline, size: 24),
                      const SizedBox(width: 4),
                      Text(item, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  selected: isSel,
                  onSelected: (sel) {
                    setState(() {
                      sel ? selected.add(item) : selected.remove(item);
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  //widget tag
  Widget _buildTagsInput() {
    final tagController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags mô tả',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: tagController,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !selTags.contains(value.trim())) {
              setState(() {
                selTags.add(value.trim());
              });
              tagController.clear();
            }
          },
          decoration: InputDecoration(
            hintText: 'Nhập tag rồi Enter',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              selTags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey.shade200,
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      selTags.remove(tag);
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selServ.isEmpty || selFeat.isEmpty || selTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đủ Dịch vụ, Tính năng và Tags.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _formKey.currentState!.save();

    final services = selServ.map((e) => SERVICE_MAP[e] ?? e).toList();
    final features = selFeat.map((e) => FEATURE_MAP[e] ?? e).toList();

    _newFarm = _newFarm.copyWith(
      services: services,
      features: features,
      tags: selTags,
    );

    setState(() => _isLoading = true);

    final response = await CrudFarmService().createFarm(
      context,
      _newFarm.toJson(),
    );

    setState(() => _isLoading = false);

    if (response != null && response['id'] != null) {
      final String farmId = response['id'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuestionStep2Screen(farmId: farmId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo farm thất bại, thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({required this.title, required this.child, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            Divider(height: 20, thickness: 0.5, color: Colors.grey.shade300),
            child,
          ],
        ),
      ),
    );
  }
}
