import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shimmer/shimmer.dart';

class ExploreItem {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String author;
  final String publishedAt;

  ExploreItem({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
  });
}

class ExploreScreen extends HookWidget {
  ExploreScreen({super.key});

  final List<ExploreItem> dummyItems = [
    ExploreItem(
      id: '1',
      title: 'Cara Membuat Aplikasi Flutter yang Efisien',
      category: 'Teknologi',
      imageUrl:
          'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
      author: 'John Doe',
      publishedAt: '2 jam lalu',
    ),
    ExploreItem(
      id: '2',
      title: 'Tips Memulai Bisnis Online di Tahun 2023',
      category: 'Bisnis',
      imageUrl:
          'https://img.freepik.com/free-photo/online-business-concept_23-2149015985.jpg',
      author: 'Jane Smith',
      publishedAt: '1 hari lalu',
    ),
    ExploreItem(
      id: '3',
      title: 'Resep Masakan Tradisional Indonesia',
      category: 'Kuliner',
      imageUrl:
          'https://img.freepik.com/free-photo/indonesian-food-rendang_23-2149153252.jpg',
      author: 'Chef Andi',
      publishedAt: '3 hari lalu',
    ),
    ExploreItem(
      id: '4',
      title: 'Panduan Lengkap Belajar Bahasa Inggris',
      category: 'Pendidikan',
      imageUrl:
          'https://img.freepik.com/free-photo/english-book-concept_23-2149484996.jpg',
      author: 'Prof. Johnson',
      publishedAt: '1 minggu lalu',
    ),
    ExploreItem(
      id: '5',
      title: 'Work From Home Produktif',
      category: 'Karir',
      imageUrl:
          'https://img.freepik.com/free-photo/home-office-concept_23-2148535165.jpg',
      author: 'Sarah Williams',
      publishedAt: '2 minggu lalu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final isLoading = useState(false);
    final filteredItems = useState<List<ExploreItem>>([]);

    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 500), () {
        if (searchQuery.value.isEmpty) {
          filteredItems.value = [];
          isLoading.value = false;
          return;
        }

        isLoading.value = true;

        // Simulasi delay request ke server
        Future.delayed(const Duration(seconds: 1), () {
          filteredItems.value = dummyItems.where((item) {
            return item.title.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                item.category.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                item.author.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                );
          }).toList();
          isLoading.value = false;
        });
      });

      return () => timer.cancel();
    }, [searchQuery.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari artikel...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onChanged: (value) {
                isLoading.value = true;
                searchQuery.value = value;
              },
            ),
            SizedBox(height: 16.h),

            // Hasil Pencarian
            Expanded(
              child: Builder(
                builder: (context) {
                  if (searchQuery.value.isEmpty) {
                    return const Center(
                      child: Text('Masukkan kata kunci untuk mencari'),
                    );
                  }

                  if (isLoading.value) {
                    return _buildShimmerLoading();
                  }

                  if (filteredItems.value.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada hasil ditemukan'),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredItems.value.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final item = filteredItems.value[index];
                      return _buildExploreItem(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreItem(ExploreItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                item.imageUrl,
                width: 100.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100.w,
                  height: 80.h,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        item.author,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '•',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        item.publishedAt,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100.w, height: 80.h, color: Colors.white),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60.w,
                          height: 12.h,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          height: 16.h,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          height: 14.h,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 120.w,
                          height: 12.h,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
