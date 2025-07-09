import 'package:flutter/material.dart';
import 'package:farmrole/modules/home/widgets/Create_PostTab.dart';
import 'package:farmrole/modules/home/widgets/Create_VideoTab.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,

        // AppBar mảnh, có TabBar custom
        appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: const Border(bottom: BorderSide.none),
          title: const Text(
            'Tạo nội dung mới',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Material(
              color: Colors.white,
              elevation: 0,
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2, color: primary),
                ),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                labelColor: primary,
                unselectedLabelColor: Colors.grey.shade600,
                tabs: const [Tab(text: 'Bài viết'), Tab(text: 'Video')],
              ),
            ),
          ),
        ),

        body: const Padding(
          padding: EdgeInsets.all(16),
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [PostTab(), VideoTab()],
          ),
        ),
      ),
    );
  }
}
