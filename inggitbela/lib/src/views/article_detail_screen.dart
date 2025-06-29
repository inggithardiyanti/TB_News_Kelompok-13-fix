import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inggitbela/src/configs/app_routes.dart';
import 'package:inggitbela/src/controller/news_controller.dart';
import 'package:inggitbela/src/models/news_model.dart';
import 'package:inggitbela/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final NewsService _newsService = NewsService();
  late Future<NewsArticle> _articleFuture;
  late Future<List<NewsArticle>> _relatedArticlesFuture;
  bool _isBookmarked = false;
  bool _isLoadingBookmark = false;

  @override
  void initState() {
    super.initState();
    _loadData(widget.articleId);
  }

  void _loadData(String articleId) {
    setState(() {
      _articleFuture = _newsService.fetchArticleById(articleId);
      _relatedArticlesFuture = _newsService.fetchRelatedArticles('technology');
      _checkBookmarkStatus(articleId);
    });
  }

  Future<void> _checkBookmarkStatus(String articleId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    setState(() => _isLoadingBookmark = true);
    try {
      final isBookmarked = await _newsService.checkBookmarkStatus(articleId);
      setState(() => _isBookmarked = isBookmarked);
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoadingBookmark = false);
    }
  }

  Future<void> _toggleBookmark(String articleId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save articles')),
      );
      return;
    }

    setState(() => _isLoadingBookmark = true);
    try {
      if (_isBookmarked) {
        await _newsService.removeBookmark(articleId);
      } else {
        await _newsService.addBookmark(articleId);
      }
      setState(() => _isBookmarked = !_isBookmarked);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoadingBookmark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<NewsArticle>(
        future: _articleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return _buildNoDataWidget();
          }

          final article = snapshot.data!;
          return CustomScrollView(
            slivers: [
              _buildAppBar(article),
              _buildArticleContent(article),
              _buildRelatedArticles(),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(NewsArticle article) {
    return SliverAppBar(
      expandedHeight: 250.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: article.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[200]),
          errorWidget:
              (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child:
                _isLoadingBookmark
                    ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 20.sp,
                    ),
          ),
          onPressed: () => _toggleBookmark(article.id),
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share, color: Colors.white, size: 20.sp),
          ),
          onPressed: () => _shareArticle(article),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildArticleContent(NewsArticle article) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  article.readTime,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  article.publishedAt,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              article.title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: CachedNetworkImageProvider(
                    article.author.avatar,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.author.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      article.author.title,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                if (article.tags.isNotEmpty) ...[
                  Icon(
                    Icons.local_offer_outlined,
                    size: 16.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    article.tags.join(', '),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),
            Html(
              data: article.content,
              style: {
                "body": Style(
                  fontSize: FontSize(16.sp),
                  lineHeight: const LineHeight(1.6),
                  color: Colors.grey[800],
                ),
                "h1": Style(
                  fontSize: FontSize(22.sp),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 12.h),
                ),
                "h2": Style(
                  fontSize: FontSize(20.sp),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 10.h),
                ),
                "a": Style(
                  color: Theme.of(context).primaryColor,
                  textDecoration: TextDecoration.none,
                ),
              },
            ),
            SizedBox(height: 32.h),
            Divider(height: 1, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRelatedArticles() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Artikel Terkait',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            FutureBuilder<List<NewsArticle>>(
              future: _relatedArticlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildRelatedArticlesShimmer();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox();
                }

                return SizedBox(
                  height: 180.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => SizedBox(width: 16.w),
                    itemBuilder: (context, index) {
                      final article = snapshot.data![index];
                      return _buildRelatedArticleCard(article);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticleCard(NewsArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.articleDetail,
          arguments: article.id,
        );
      },
      child: SizedBox(
        width: 200.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[200]),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.h,
          pinned: true,
          flexibleSpace: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100.w, height: 20.h, color: Colors.white),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    height: 30.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      CircleAvatar(radius: 20.r, backgroundColor: Colors.white),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.w,
                            height: 16.h,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            width: 80.w,
                            height: 14.h,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Container(
                        width: double.infinity,
                        height: 16.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedArticlesShimmer() {
    return SizedBox(
      height: 180.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Jumlah placeholder shimmer
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: SizedBox(
              width: 200.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  Container(width: 150.w, height: 16.h, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Gagal memuat artikel',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                final articleId =
                    ModalRoute.of(context)!.settings.arguments as String;
                _loadData(articleId);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'Artikel tidak ditemukan',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Artikel yang Anda cari mungkin telah dihapus atau tidak tersedia',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareArticle(NewsArticle article) async {
    try {
      await Share.share(
        '${article.title}\n\nBaca selengkapnya di aplikasi kami!',
        subject: article.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal berbagi artikel: ${e.toString()}')),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tidak dapat membuka link: $url')));
    }
  }
}
