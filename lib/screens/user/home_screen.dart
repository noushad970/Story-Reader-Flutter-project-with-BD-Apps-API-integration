import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/story_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/story_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/story_card.dart';
import '../landing/landing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  bool unsubscribing = false;

  String? selectedCategoryId;

  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    verifySubscription();
  }

  // ============================================================
  // VERIFY SUBSCRIPTION
  // ============================================================

  Future<void> verifySubscription() async {
    final isSubscribed = await AuthService.checkCurrentSubscription();

    if (!mounted) return;

    if (!isSubscribed) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );

      return;
    }

    setState(() {
      loading = false;
    });
  }

  // ============================================================
  // UNSUBSCRIBE
  // ============================================================

  Future<void> unsubscribe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.cancel_outlined,
                    size: 32,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unsubscribe?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will lose access to subscriber stories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(
                        label: 'UNSUBSCRIBE',
                        colors: const [AppColors.error, Color(0xFFFF6B6B)],
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      unsubscribing = true;
    });

    final result = await AuthService.unsubscribe();

    if (!mounted) return;

    setState(() {
      unsubscribing = false;
    });

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Unsubscribe failed'),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH FILTER
  // ============================================================

  List<StoryModel> filterStories(List<StoryModel> stories) {
    if (searchQuery.trim().isEmpty) {
      return stories;
    }

    final query = searchQuery.toLowerCase();

    return stories.where((story) {
      return story.title.toLowerCase().contains(query) ||
          story.author.toLowerCase().contains(query) ||
          story.description.toLowerCase().contains(query) ||
          story.categoryName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingWidget(fullScreen: true, message: 'Loading…');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppGradients.hero,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x556A5AE0),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Story Reader',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: unsubscribing ? null : unsubscribe,
                    tooltip: 'Unsubscribe',
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // SEARCH FIELD
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search stories, authors, categories...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                searchQuery = '';
                              });
                            },
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // CATEGORIES
            // ======================================================
            SizedBox(
              height: 50,
              child: StreamBuilder<List<CategoryModel>>(
                stream: CategoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load categories'),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _AllChip(
                        selected: selectedCategoryId == null,
                        onTap: () {
                          setState(() {
                            selectedCategoryId = null;
                          });
                        },
                      ),

                      const SizedBox(width: 10),

                      ...categories.map((category) {
                        return CategoryChip(
                          category: category,
                          selected: selectedCategoryId == category.id,
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ======================================================
            // STORIES
            // ======================================================
            Expanded(
              child: StreamBuilder<List<StoryModel>>(
                stream: selectedCategoryId == null
                    ? StoryService.getPublishedStories()
                    : StoryService.getStoriesByCategory(selectedCategoryId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      children: const [
                        StoryCardSkeleton(),
                        StoryCardSkeleton(),
                        StoryCardSkeleton(),
                      ],
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Failed to load stories:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  final stories = filterStories(snapshot.data ?? []);

                  if (stories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No stories found',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Check back later for new stories',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 60 * index),
                        child: StoryCard(story: stories[index]),
                      );
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
}

class _AllChip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _AllChip({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.divider,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x556A5AE0),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.apps_rounded,
                    size: 16,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'All',
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
