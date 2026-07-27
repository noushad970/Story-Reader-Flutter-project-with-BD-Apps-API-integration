import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/story_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/story_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/language_toggle_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/story_card.dart';
import '../../widgets/theme_toggle_button.dart';
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

  // Pagination state
  static const int pageSize = 10;
  final List<StoryModel> _pagedStories = [];
  DocumentSnapshot? _nextCursor;
  bool _hasMore = true;
  bool _loadingMore = false;
  String? _errorMessage;

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

    _loadFirstPage();
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Future<void> _loadFirstPage() async {
    setState(() {
      _pagedStories.clear();
      _nextCursor = null;
      _hasMore = true;
      _errorMessage = null;
    });

    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final result = await StoryService.getStoriesPaged(
        after: _nextCursor,
        limit: pageSize,
      );
      if (!mounted) return;
      setState(() {
        _pagedStories.addAll(result.stories);
        _nextCursor = result.nextCursor;
        _hasMore =
            result.nextCursor != null && result.stories.length == pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingMore = false;
        });
      }
    }
  }

  // ============================================================
  // UNSUBSCRIBE
  // ============================================================

  Future<void> unsubscribe() async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                Text(
                  loc.unsubscribeTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.unsubscribeBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(loc.cancel.toUpperCase()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(
                        label: loc.unsubscribeConfirm,
                        colors: const [AppColors.error, Color(0xFFFF6B6B)],
                        onPressed: () => Navigator.pop(dialogContext, true),
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
          content: Text(
            result['message']?.toString() ?? loc.unsubscribeFailed,
          ),
        ),
      );
    }
  }

  // ============================================================
  // GO TO HOME (resets to first page and clears filters)
  // ============================================================

  void _goHome() {
    if (searchQuery.isNotEmpty) {
      searchController.clear();
      setState(() {
        searchQuery = '';
      });
    }
    if (selectedCategoryId != null) {
      setState(() {
        selectedCategoryId = null;
      });
    }
    _loadFirstPage();
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
    final loc = AppLocalizations.of(context);

    if (loading) {
      return LoadingWidget(fullScreen: true, message: loc.loading);
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.welcomeBack,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          loc.appTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _goHome,
                    tooltip: loc.tooltipHome,
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const LanguageToggleButton(),
                  const SizedBox(width: 4),
                  const ThemeToggleButton(),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: loc.tooltipBookmarks,
                    onPressed: () {
                      Navigator.pushNamed(context, '/bookmarks');
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: unsubscribing ? null : unsubscribe,
                    tooltip: loc.tooltipUnsubscribe,
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
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
                    hintText: loc.searchHint,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).colorScheme.primary,
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
                    return Center(
                      child: Text(loc.failedLoadCategories),
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
                          _loadFirstPage();
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
                            _loadFirstPage();
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
            // STORIES (paged, with bookmark icon overlay)
            // ======================================================
            Expanded(child: _buildStoriesList(loc)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesList(AppLocalizations loc) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                '${loc.networkError}\n$_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFirstPage,
                child: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_pagedStories.isEmpty && _loadingMore) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: const [
          StoryCardSkeleton(),
          StoryCardSkeleton(),
          StoryCardSkeleton(),
        ],
      );
    }

    final filtered = filterStories(_pagedStories);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              loc.noStoriesFound,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              searchQuery.isNotEmpty
                  ? loc.tryDifferentSearch
                  : loc.checkBackLater,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: filtered.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            // Load-more footer
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator(strokeWidth: 2.4)
                    : ElevatedButton.icon(
                        onPressed: _loadNextPage,
                        icon: const Icon(Icons.expand_more_rounded),
                        label: Text(loc.loadMore),
                      ),
              ),
            );
          }
          final story = filtered[index];
          return FadeInUp(
            delay: Duration(milliseconds: 60 * (index % pageSize)),
            child: StoryCard(story: story),
          );
        },
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
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Theme.of(context).dividerColor,
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
                    color: selected
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loc.allCategory,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
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