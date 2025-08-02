import 'package:farmrole/modules/auth/services/Answer_Service.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Edit_Step2_Screen.dart';
import 'package:flutter/material.dart';

class FarmSurveyDetailScreen extends StatefulWidget {
  final String farmId;
  const FarmSurveyDetailScreen({Key? key, required this.farmId})
    : super(key: key);

  @override
  State<FarmSurveyDetailScreen> createState() => _FarmSurveyDetailScreenState();
}

class _FarmSurveyDetailScreenState extends State<FarmSurveyDetailScreen> {
  List<Map<String, dynamic>> surveyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyData();
  }

  Future<void> _loadSurveyData() async {
    try {
      final data = await AnswerService().fetchAnswersByFarm(
        context,
        widget.farmId,
      );
      setState(() {
        surveyData = data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải khảo sát: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khảo sát'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : surveyData.isEmpty
              ? const Center(child: Text('Chưa có dữ liệu khảo sát'))
              : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: surveyData.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = surveyData[index];
                  final q = item['question'] ?? {};
                  final a = item['answer'] ?? {};
                  final options =
                      (a['selectedOptions'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [];
                  final other = a['otherText'] ?? '';
                  final files =
                      (a['uploadedFiles'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Câu hỏi
                          Text(
                            q['text'] ?? '',
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Câu trả lời
                          if (options.isNotEmpty) ...[
                            Text(
                              'Lựa chọn:',
                              style: theme.textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children:
                                  options
                                      .map(
                                        (o) => Chip(
                                          label: Text(o),
                                          visualDensity: VisualDensity.compact,
                                          backgroundColor: theme
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (other.isNotEmpty) ...[
                            Text(
                              'Khác:',
                              style: theme.textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(other, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                          ],

                          // Ảnh đính kèm (nếu có)
                          if (files.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: files.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 8),
                                itemBuilder: (_, i) {
                                  final imageUrl = AuthService.getFullAvatarUrl(
                                    files[i],
                                  );
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          surveyData.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditStep2Screen(
                            farmId: widget.farmId,
                            existingAnswers: surveyData, // Truyền dữ liệu đã có
                          ),
                    ),
                  );
                },
                label: const Text("Chỉnh sửa khảo sát"),
                icon: const Icon(Icons.edit),
                backgroundColor: theme.primaryColor,
              )
              : null,
    );
  }
}
