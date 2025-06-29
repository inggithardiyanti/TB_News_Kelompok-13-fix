import 'package:flutter/material.dart';
import 'package:inggitbela/src/configs/app_routes.dart';
import 'package:inggitbela/src/controller/news_controller.dart';
import 'package:inggitbela/src/models/news_model.dart';
import 'package:inggitbela/src/widgets/article_card.dart';
import 'package:inggitbela/src/widgets/empty_state.dart';
import 'package:inggitbela/src/widgets/error_state.dart';
import 'package:inggitbela/src/widgets/loading_indicator.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  final NewsService _newsService = NewsService();
  late Future<NewsResponse> _myArticlesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMyArticles();
  }

  void _loadMyArticles() {
    setState(() {
      _myArticlesFuture = _newsService.fetchMyArticles();
    });
  }

  Future<void> _refreshArticles() async {
    _loadMyArticles();
  }

  Future<void> _deleteArticle(String articleId) async {
    try {
      setState(() => _isLoading = true);
      final success = await _newsService.deleteArticle(articleId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus')),
        );
        _loadMyArticles();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmDelete(String articleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteArticle(articleId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.createArticle,
            ).then((_) => _refreshArticles()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: FutureBuilder<NewsResponse>(
          future: _myArticlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }

            if (snapshot.hasError) {
              return ErrorState(
                message: snapshot.error.toString(),
                onRetry: _refreshArticles,
              );
            }

            if (!snapshot.hasData || snapshot.data!.data.articles.isEmpty) {
              return EmptyState(
                icon: Icons.article,
                message: 'Anda belum membuat artikel',
                actionText: 'Buat Artikel',
                onAction: () => Navigator.pushNamed(
                  context,
                  AppRoutes.createArticle,
                ).then((_) => _refreshArticles()),
              );
            }

            final articles = snapshot.data!.data.articles;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Column(
                  children: [
                    ArticleCard(
                      article: article,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.articleDetail,
                        arguments: article.id,
                      ),
                      showMenu: true,
                      onEdit: () => Navigator.pushNamed(
                        context,
                        AppRoutes.editArticle,
                        arguments: {
                          'articleId': article.id,
                          'initialData': {
                            'title': article.title,
                            'category': article.category,
                            'content': article.content,
                            'tags': article.tags,
                            'imageUrl': article.imageUrl,
                            'readTime': article.readTime,
                          },
                        },
                      ).then((_) => _refreshArticles()),
                      onDelete: () => _confirmDelete(article.id),
                    ),
                    if (index < articles.length - 1) const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
