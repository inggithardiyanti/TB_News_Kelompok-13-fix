import 'package:flutter/material.dart';
import 'package:inggitbela/src/views/create_edit_article_screen.dart';
import 'package:inggitbela/src/views/login_screen.dart';
import 'package:inggitbela/src/views/main_screen.dart';
import 'package:inggitbela/src/views/my_articles_screen.dart';
import 'package:inggitbela/src/views/register_screen.dart';
import 'package:inggitbela/src/views/splash_screen.dart';
import 'package:inggitbela/src/views/article_detail_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const introduction = '/intro';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const articleDetail = '/article';
  static const profile = '/profile';
  static const explore = '/explore';
  static const trending = '/trending';
  static const saved = '/saved';
  static const myArticles = '/my-articles';
  static const createArticle = '/create-article';
  static const editArticle = '/edit-article';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainWrapperScreen());
      case articleDetail:
        final articleId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(articleId: articleId),
        );
      case myArticles:
        return MaterialPageRoute(builder: (_) => const MyArticlesScreen());
      case createArticle:
        return MaterialPageRoute(
          builder: (_) => const CreateEditArticleScreen(),
        );
      case editArticle:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CreateEditArticleScreen(
            articleId: args['articleId'],
            initialData: args['initialData'],
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
