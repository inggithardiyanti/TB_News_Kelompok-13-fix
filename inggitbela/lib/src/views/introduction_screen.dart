import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inggitbela/src/configs/app_routes.dart';
import 'package:inggitbela/src/models/introduction_item.dart';
import 'package:inggitbela/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<IntroductionItem> _introductionItems = [
    IntroductionItem(
      image: 'assets/images/intro1.png',
      title: 'Selamat Datang',
      description: 'Temukan berita terkini dan terpercaya dari berbagai sumber',
    ),
    IntroductionItem(
      image: 'assets/images/intro2.png',
      title: 'Baca Dimana Saja',
      description: 'Akses berita favorit Anda kapan saja dan dimana saja',
    ),
    IntroductionItem(
      image: 'assets/images/intro3.png',
      title: 'Personalized Content',
      description: 'Dapatkan rekomendasi berita sesuai minat Anda',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    if (!isFirstLaunch) {
      _redirectUser();
    }
  }

  Future<void> _completeIntroduction() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);

    _redirectUser();
  }

  void _redirectUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _introductionItems.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = _introductionItems[index];
                return _buildPage(item);
              },
            ),
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildPageIndicator(),
                  SizedBox(height: 30.h),
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroductionItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(item.image, height: 250.h, fit: BoxFit.contain),
          SizedBox(height: 40.h),
          Text(
            item.title,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _introductionItems.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_currentPage == _introductionItems.length - 1) {
                    _completeIntroduction();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _currentPage == _introductionItems.length - 1
                      ? 'Mulai Sekarang'
                      : 'Lanjut',
                  style: TextStyle(fontSize: 16.sp),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
