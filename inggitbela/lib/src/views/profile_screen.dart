import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inggitbela/src/configs/app_routes.dart';
import 'package:inggitbela/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigasi ke halaman pengaturan
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(authProvider),
            SizedBox(height: 32.h),
            _buildGeneralSettings(),
            SizedBox(height: 24.h),
            _buildArticleSettings(context),
            SizedBox(height: 24.h),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(AuthProvider authProvider) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.grey[200],
            backgroundImage: authProvider.currentUser?.avatar != null
                ? CachedNetworkImageProvider(authProvider.currentUser!.avatar)
                : null,
            child: authProvider.currentUser?.avatar == null
                ? Icon(Icons.person, size: 50.sp, color: Colors.grey)
                : null,
          ),
          SizedBox(height: 16.h),
          Text(
            authProvider.currentUser?.name ?? 'Nama Pengguna',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            authProvider.currentUser?.email ?? 'email@example.com',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            authProvider.currentUser?.title ?? 'Penulis',
            style: TextStyle(fontSize: 14.sp, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan Umum',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        _buildSettingItem(
          icon: Icons.edit,
          title: 'Edit Profil',
          onTap: () {
            // Navigasi ke halaman edit profil
          },
        ),
        _buildSettingItem(
          icon: Icons.notifications,
          title: 'Notifikasi',
          onTap: () {
            // Navigasi ke halaman notifikasi
          },
        ),
        _buildSettingItem(
          icon: Icons.lock,
          title: 'Keamanan',
          onTap: () {
            // Navigasi ke halaman keamanan
          },
        ),
        _buildSettingItem(
          icon: Icons.help_outline,
          title: 'Bantuan',
          onTap: () {
            // Navigasi ke halaman bantuan
          },
        ),
      ],
    );
  }

  Widget _buildArticleSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artikel Saya',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        _buildSettingItem(
          icon: Icons.article,
          title: 'Artikel yang Ditulis',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.myArticles);
          },
        ),
        _buildSettingItem(
          icon: Icons.bookmark,
          title: 'Artikel Disimpan',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.saved);
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24.sp, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      trailing: Icon(Icons.chevron_right, size: 24.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.red,
          backgroundColor: Colors.red[50],
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        child: Text(
          'Keluar',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            child: Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
