import 'package:flutter/material.dart';
import 'package:inggitbela/src/controller/news_controller.dart';
import 'package:inggitbela/src/widgets/custom_text_field.dart';

class CreateEditArticleScreen extends StatefulWidget {
  final String? articleId;
  final Map<String, dynamic>? initialData;

  const CreateEditArticleScreen({super.key, this.articleId, this.initialData});

  @override
  State<CreateEditArticleScreen> createState() =>
      _CreateEditArticleScreenState();
}

class _CreateEditArticleScreenState extends State<CreateEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final NewsService _newsService = NewsService();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _imageUrlController;
  late TextEditingController _readTimeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with dummy data
    _titleController = TextEditingController(
      text:
          widget.initialData?['title'] ??
          'Cara Membuat Aplikasi Flutter yang Efisien',
    );
    _categoryController = TextEditingController(
      text: widget.initialData?['category'] ?? 'Teknologi',
    );
    _contentController = TextEditingController(
      text:
          widget.initialData?['content'] ??
          '''
<h1>Pendahuluan</h1>
<p>Flutter adalah framework open-source yang dikembangkan oleh Google untuk membangun antarmuka pengguna yang indah, dikompilasi secara native, untuk mobile, web, dan desktop dari satu basis kode.</p>

<h2>Langkah Pertama</h2>
<p>Untuk memulai dengan Flutter, Anda perlu menginstal Flutter SDK dan menyiapkan lingkungan pengembangan Anda. Pastikan Anda memiliki:</p>
<ul>
  <li>Android Studio atau VS Code</li>
  <li>Flutter SDK terbaru</li>
  <li>Dart plugin</li>
</ul>

<h2>Best Practices</h2>
<p>Berikut beberapa praktik terbaik dalam pengembangan Flutter:</p>
<ol>
  <li>Gunakan widget stateless ketika memungkinkan</li>
  <li>Pisahkan logika bisnis dari UI</li>
  <li>Manfaatkan package dari pub.dev</li>
</ol>
''',
    );
    _tagsController = TextEditingController(
      text:
          widget.initialData?['tags']?.join(', ') ??
          'Flutter, Dart, Mobile Development',
    );
    _imageUrlController = TextEditingController(
      text:
          widget.initialData?['imageUrl'] ??
          'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
    );
    _readTimeController = TextEditingController(
      text: widget.initialData?['readTime'] ?? '8 min',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    _readTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final articleData = {
        'title': _titleController.text,
        'category': _categoryController.text,
        'content': _contentController.text,
        'tags': _tagsController.text.split(',').map((e) => e.trim()).toList(),
        'imageUrl': _imageUrlController.text,
        'readTime': _readTimeController.text,
        'publishedAt': DateTime.now().toIso8601String(),
      };

      bool success;
      if (widget.articleId != null) {
        success = await _newsService.updateArticle(
          widget.articleId!,
          articleData,
        );
      } else {
        success = await _newsService.createArticle(articleData);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.articleId != null
                  ? 'Artikel berhasil diperbarui'
                  : 'Artikel berhasil dibuat',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.articleId != null ? 'Edit Artikel' : 'Buat Artikel Baru',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Judul Artikel',
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _categoryController,
                label: 'Kategori',
                validator: (value) =>
                    value!.isEmpty ? 'Kategori tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                label: 'Konten',
                maxLines: 10,
                validator: (value) =>
                    value!.isEmpty ? 'Konten tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _tagsController,
                label: 'Tag (pisahkan dengan koma)',
                validator: (value) =>
                    value!.isEmpty ? 'Tag tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageUrlController,
                label: 'URL Gambar',
                validator: (value) =>
                    value!.isEmpty ? 'URL gambar tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _readTimeController,
                label: 'Waktu Baca (contoh: 5 min)',
                validator: (value) =>
                    value!.isEmpty ? 'Waktu baca tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
