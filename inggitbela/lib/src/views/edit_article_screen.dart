import 'package:flutter/material.dart';
import 'package:inggitbela/src/controller/news_controller.dart';
import 'package:inggitbela/src/widgets/custom_text_field.dart';

class EditArticleScreen extends StatefulWidget {
  final String articleId;
  final Map<String, dynamic> initialData;

  const EditArticleScreen({
    super.key,
    required this.articleId,
    required this.initialData,
  });

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
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
    // Initialize controllers with the article data to be edited
    _titleController = TextEditingController(text: widget.initialData['title']);
    _categoryController = TextEditingController(
      text: widget.initialData['category'],
    );
    _contentController = TextEditingController(
      text: widget.initialData['content'],
    );
    _tagsController = TextEditingController(
      text: (widget.initialData['tags'] as List).join(', '),
    );
    _imageUrlController = TextEditingController(
      text: widget.initialData['imageUrl'],
    );
    _readTimeController = TextEditingController(
      text: widget.initialData['readTime'],
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
      };

      final success = await _newsService.updateArticle(
        widget.articleId,
        articleData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil diperbarui')),
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
        title: const Text('Edit Artikel'),
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
