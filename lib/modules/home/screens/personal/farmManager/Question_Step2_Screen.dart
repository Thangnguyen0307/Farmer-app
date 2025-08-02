import 'dart:io';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Farm_image.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/CRUD_Farm_Service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QuestionStep2Screen extends StatefulWidget {
  final String farmId;
  const QuestionStep2Screen({super.key, required this.farmId});

  @override
  State<QuestionStep2Screen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionStep2Screen> {
  List<dynamic> questions = [];
  final List<File> farmImages = [];
  final Map<String, dynamic> answers = {};
  final Map<String, List<File>> uploadedImages = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final data = await CrudFarmService().fetchQuestions(context);
    setState(() {
      questions = data;
      isLoading = false;
    });
  }

  Future<void> handleSubmit() async {
    final token = context.read<UserProvider>().user?.token ?? '';
    // Kiểm tra câu hỏi isRequired phải có câu trả lời
    final missingQuestions =
        questions.where((q) {
          if (q['isRequired'] != true) return false;
          final id = q['_id'];
          final type = q['type'];
          if (type == 'single-choice') {
            return (answers[id] ?? '').toString().isEmpty;
          } else if (type == 'multi-choice') {
            return (answers[id] ?? []).isEmpty;
          } else if (type == 'text') {
            return (answers[id] ?? '').toString().trim().isEmpty;
          } else if (type == 'upload') {
            return (uploadedImages[id] ?? []).isEmpty;
          }
          return false;
        }).toList();

    if (missingQuestions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng trả lời đầy đủ các câu hỏi bắt buộc.'),
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> formattedAnswers = await Future.wait(
      questions.map((q) async {
        final id = q['_id'];
        final type = q['type'];
        final allowOtherText = q['allowOtherText'] == true;

        List<String> selectedOptions = [];
        String otherText = '';
        List<String> filePaths = [];

        if (type == 'single-choice') {
          final selected = answers[id] ?? '';
          selectedOptions = [selected];

          if (allowOtherText &&
              selected.toLowerCase().contains('khác') &&
              answers.containsKey('${id}_otherText')) {
            otherText = answers['${id}_otherText'] ?? '';
          }
        } else if (type == 'multi-choice') {
          selectedOptions = List<String>.from(answers[id] ?? []);
        } else if (type == 'text') {
          otherText = answers[id] ?? '';
        } else if (type == 'upload') {
          final files = uploadedImages[id] ?? [];
          filePaths = await Future.wait(
            files.map((file) async {
              final url = await CrudFarmService().uploadImageAnswer(
                file: file,
                farmId: widget.farmId,
                questionId: id,
                token: token,
              );
              return url ?? '';
            }),
          );
        }

        return {
          "questionId": id,
          "selectedOptions": selectedOptions,
          "otherText": otherText,
          "uploadedFiles": filePaths,
        };
      }),
    );

    final success = await CrudFarmService().submitAnswers(
      context,
      widget.farmId,
      formattedAnswers,
    );
    print("Farm ID: ${widget.farmId}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Đăng ký thành công!" : "Thất bại, thử lại."),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success && mounted) {
      context.go('/my-farm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Câu hỏi khảo sát"),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...questions.map((q) => _buildQuestion(q)).toList(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0.5,
              ),
              child: const Text("Gửi đăng kí", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> q) {
    final id = q['_id'];
    final type = q['type'];
    final options = List<String>.from(q['options'] ?? []);
    final title = q['text'];
    final allowOtherText = q['allowOtherText'] == true;
    final isOtherSelected =
        answers[id] != null &&
        answers[id].toString().toLowerCase().contains('khác(vui lòng mô tả)');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (type == 'single-choice')
            Column(
              children: [
                ...options.map((opt) {
                  return RadioListTile<String>(
                    title: Text(opt, style: const TextStyle(fontSize: 13)),
                    value: opt,
                    groupValue: answers[id]?.toString(),
                    onChanged: (val) => setState(() => answers[id] = val ?? ''),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                if (allowOtherText && isOtherSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TextField(
                      onChanged: (val) => answers['${id}_otherText'] = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Vui lòng mô tả thêm',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.blue.shade300),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          else if (type == 'multi-choice')
            Column(
              children:
                  options.map((opt) {
                    final selected = (answers[id] ?? []).contains(opt);
                    return CheckboxListTile(
                      title: Text(opt, style: const TextStyle(fontSize: 13)),
                      value: selected,
                      onChanged: (val) {
                        final list = List<String>.from(answers[id] ?? []);
                        val! ? list.add(opt) : list.remove(opt);
                        setState(() => answers[id] = list);
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
            )
          else if (type == 'text')
            TextField(
              onChanged: (val) => answers[id] = val,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.blue.shade300),
                ),
              ),
            )
          else if (type == 'upload')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...(uploadedImages[id] ?? []).map(
                      (file) => Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              file,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 2),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                setState(
                                  () => uploadedImages[id]!.remove(file),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((uploadedImages[id]?.length ?? 0) < 5)
                      GestureDetector(
                        onTap: () async {
                          final picker = UploadFarmImage();
                          final img = await picker.pickImageWithDialog(context);
                          if (img != null) {
                            final list = uploadedImages[id] ?? [];
                            setState(() => uploadedImages[id] = [...list, img]);
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(Icons.add_a_photo, size: 20),
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
