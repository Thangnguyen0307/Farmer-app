import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/screens/home/Search_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFakeSearchBar = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey.withOpacity(0.1),
        centerTitle: false,
        title:
            _showFakeSearchBar
                ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _showFakeSearchBar = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchScreen()),
                    );
                  },
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          "Tìm kiếm cocktails...",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : Row(
                  children: [
                    Image.asset(
                      'lib/assets/image/appbar.png',
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FARMER',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

        actions: [
          IconButton(
            icon: Icon(
              _showFakeSearchBar ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFakeSearchBar = !_showFakeSearchBar;
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Text(
            'Trang chủ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
