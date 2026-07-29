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
import 'unsubscribe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  bool unsubscribing = false;
  bool isSubscribed = false;

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
    final subscribed = await AuthService.checkCurrentSubscription();

    if (!mounted) return;

    // Always let the user browse stories once they are logged in.
    // We refresh the subscription flag so the home screen can show a
    // reminder banner for lapsed users, but we never bounce them back to
    // the landing page.
    setState(() {
      isSubscribed = subscribed;
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
  //
  // Opens the dedicated UnsubscribeScreen where the user enters the
  // mobile number and confirms. After a successful unsubscribe we
  // refresh the local subscription state and bounce back to the
  // landing page (because the local session has been cleared).
  // ============================================================

  Future<void> unsubscribe() async {
    setState(() {
      unsubscribing = true;
    });

    try {
      // The new screen handles its own confirmation, API call, and
      // Firestore update. We just push it on top and wait for the
      // result via Navigator.pop.
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const UnsubscribeScreen()),
      );

      if (!mounted) return;

      if (result == true) {
        // User successfully unsubscribed. Mirror Firestore locally
        // and send the user back to the landing screen so they can
        // either log in with a different number or subscribe again.
        setState(() {
          isSubscribed = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LandingScreen()),
          (route) => false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          unsubscribing = false;
        });
      }
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
            // HEADER (mobile-safe two-row layout)
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: logo + title (Expanded) + language toggle
                  Row(
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              loc.appTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const LanguageToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: 4 compact action buttons, unsubscribe pushed right
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        _HeaderActionButton(
                          tooltip: loc.tooltipHome,
                          icon: Icons.home_rounded,
                          onPressed: _goHome,
                        ),
                        const SizedBox(width: 8),
                        _HeaderActionButton(
                          tooltip: loc.tooltipBookmarks,
                          icon: Icons.bookmark_rounded,
                          onPressed: () {
                            Navigator.pushNamed(context, '/bookmarks');
                          },
                        ),
                        const SizedBox(width: 8),
                        const ThemeToggleButton(),
                        const Spacer(),
                        _HeaderActionButton(
                          tooltip: loc.tooltipUnsubscribe,
                          icon: Icons.cancel_outlined,
                          iconColor: AppColors.error,
                          onPressed: unsubscribing ? null : unsubscribe,
                        ),
                      ],
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
                    return Center(child: Text(loc.failedLoadCategories));
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
            // SUBSCRIPTION REMINDER (only for lapsed users)
            // ======================================================
            if (!isSubscribed) _buildSubscribeBanner(loc),

            // ======================================================
            // STORIES (paged, with bookmark icon overlay)
            // ======================================================
            Expanded(child: _buildStoriesList(loc)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeBanner(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pushNamed(context, '/phone-login');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.accent.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.subscribeBannerMessage,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  loc.subscribeBannerCta,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
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
              ElevatedButton(onPressed: _loadFirstPage, child: Text(loc.retry)),
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

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }
}
