import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../services/admin_story_service.dart';
import '../../services/category_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final contentController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverImageUrlController = TextEditingController();

  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  bool loadingCategories = true;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final result = await CategoryService.getCategories().first;
      final Map<String, CategoryModel> uniqueCategoryMap = {};
      for (final category in result) {
        uniqueCategoryMap[category.id] = category;
      }
      if (!mounted) return;
      setState(() {
        categories = uniqueCategoryMap.values.toList();
        loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingCategories = false;
      });
      showMessage('Failed to load categories: $e');
    }
  }

  Future<void> createStory() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory == null) {
      showMessage('Please select a category');
      return;
    }

    setState(() => uploading = true);
    try {
      await AdminStoryService.createStory(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        content: contentController.text.trim(),
        author: authorController.text.trim(),
        categoryId: selectedCategory!.id,
        categoryName: selectedCategory!.name,
        coverImageUrl: coverImageUrlController.text.trim(),
        isPublished: true,
      );
      if (!mounted) return;
      showMessage('Story created successfully');
      clearForm();
    } catch (e) {
      if (!mounted) return;
      showMessage('Failed to create story: $e');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  void clearForm() {
    titleController.clear();
    authorController.clear();
    contentController.clear();
    descriptionController.clear();
    coverImageUrlController.clear();
    setState(() => selectedCategory = null);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    contentController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
    super.dispose();
  }

  Widget _iconPrefix(IconData icon, LinearGradient grad) => Container(
    margin: const EdgeInsets.all(8),
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      gradient: grad,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: Colors.white, size: 18),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Story'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.ocean),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedGradientBackground(
              colors: AppColors.softBackground,
              child: SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 60),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.oceanGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Story',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Publish a story for your readers',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 140),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionLabel(
                            icon: Icons.title_rounded,
                            label: 'Story Details',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Story Title',
                              prefixIcon: _iconPrefix(
                                Icons.title_rounded,
                                AppGradients.primary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter story title'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: authorController,
                            decoration: InputDecoration(
                              labelText: 'Author',
                              prefixIcon: _iconPrefix(
                                Icons.person_rounded,
                                AppGradients.sunset,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter author name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Short Description',
                              prefixIcon: _iconPrefix(
                                Icons.short_text_rounded,
                                AppGradients.ocean,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter description'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionLabel(
                            icon: Icons.folder_special_rounded,
                            label: 'Categorization',
                          ),
                          const SizedBox(height: 12),
                          if (loadingCategories)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            DropdownButtonFormField<CategoryModel>(
                              initialValue: selectedCategory,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.expand_more_rounded,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Select Category',
                                prefixIcon: _iconPrefix(
                                  Icons.category_rounded,
                                  AppGradients.hero,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                              ),
                              items: categories.map((c) {
                                return DropdownMenuItem<CategoryModel>(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          gradient: AppGradients.primary,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.label_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(c.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) =>
                                  setState(() => selectedCategory = v),
                              validator: (v) =>
                                  v == null ? 'Please select a category' : null,
                            ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: coverImageUrlController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: 'Cover Image URL (optional)',
                              hintText: 'https://example.com/cover.jpg',
                              prefixIcon: _iconPrefix(
                                Icons.image_rounded,
                                AppGradients.sunset,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                            validator: (value) {
                              final url = value?.trim() ?? '';
                              if (url.isEmpty) return null;
                              final uri = Uri.tryParse(url);
                              if (uri == null ||
                                  !uri.hasAbsolutePath ||
                                  !(uri.isScheme('HTTP') ||
                                      uri.isScheme('HTTPS'))) {
                                return 'Enter a valid http(s) image URL';
                              }
                              final p = uri.path.toLowerCase();
                              if (!(p.endsWith('.jpg') ||
                                  p.endsWith('.jpeg') ||
                                  p.endsWith('.png') ||
                                  p.endsWith('.webp') ||
                                  p.endsWith('.gif'))) {
                                return 'URL should point to an image';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Leave empty to publish without a cover image.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionLabel(
                            icon: Icons.article_rounded,
                            label: 'Story Content',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: contentController,
                            maxLines: 14,
                            decoration: InputDecoration(
                              labelText: 'Story Content',
                              hintText: 'Write your story...',
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 8,
                                  bottom: 8,
                                ),
                                child: Container(
                                  width: 36,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter story content'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeInUp(
                    delay: const Duration(milliseconds: 380),
                    child: GradientButton(
                      label: 'PUBLISH STORY',
                      icon: Icons.publish_rounded,
                      loading: uploading,
                      colors: AppColors.primaryGradient,
                      onPressed: uploading ? null : createStory,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
