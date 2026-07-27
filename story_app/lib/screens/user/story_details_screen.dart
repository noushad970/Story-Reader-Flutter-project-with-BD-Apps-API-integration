import 'package:flutter/material.dart';

import '../../app_localizations.dart';
import '../../models/story_model.dart';
import '../../services/auth_service.dart';
import '../../services/bookmark_service.dart';
import '../../services/story_service.dart';
import '../../theme/app_theme.dart';
import 'story_comments_screen.dart';

class StoryDetailsScreen extends StatefulWidget {
  final StoryModel story;

  const StoryDetailsScreen({super.key, required this.story});

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  bool _bookmarked = false;
  bool _bookmarkBusy = false;
  bool _likeBusy = false;

  @override
  void initState() {
    super.initState();
    _primeBookmarkFromCache();
  }

  Future<void> _primeBookmarkFromCache() async {
    final phone = AuthService.currentUserPhone;
    if (phone == null) return;
    final cached = await BookmarkService.readLocalCache();
    if (!mounted) return;
    setState(() {
      _bookmarked = cached.contains(widget.story.id);
    });
    final fresh = await BookmarkService.isBookmarked(phone, widget.story.id);
    if (!mounted) return;
    setState(() {
      _bookmarked = fresh;
    });
  }

  Future<void> _toggleBookmark() async {
    final loc = AppLocalizations.of(context);
    final phone = AuthService.currentUserPhone;
    if (phone == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.pleaseLoginToBookmark)));
      return;
    }
    setState(() => _bookmarkBusy = true);
    try {
      final nowBookmarked = await BookmarkService.toggle(phone, widget.story);
      if (!mounted) return;
      setState(() => _bookmarked = nowBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowBookmarked ? loc.savedToBookmarks : loc.removedFromBookmarks,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${loc.bookmarkFailed}: $e')));
    } finally {
      if (mounted) setState(() => _bookmarkBusy = false);
    }
  }

  Future<void> _toggleLike() async {
    final loc = AppLocalizations.of(context);
    final phone = AuthService.currentUserPhone;
    if (phone == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.pleaseLoginToLike)));
      return;
    }
    setState(() => _likeBusy = true);
    try {
      await StoryService.toggleLike(storyId: widget.story.id, userPhone: phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${loc.likeFailed}: $e')));
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  void _openComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryCommentsScreen(storyId: widget.story.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final phone = AuthService.currentUserPhone;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.story.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Bookmark icon
          IconButton(
            tooltip: _bookmarked
                ? loc.tooltipRemoveBookmark
                : loc.tooltipBookmark,
            onPressed: _bookmarkBusy ? null : _toggleBookmark,
            icon: Icon(
              _bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _bookmarked ? AppColors.accent : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.story.coverImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.story.coverImageUrl,
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 230,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.hero,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              widget.story.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              loc.byAuthor(widget.story.author),
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.story.categoryName.isNotEmpty)
                  Chip(
                    label: Text(widget.story.categoryName),
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            // ----- Like / Comment / Bookmark action row -----
            Row(
              children: [
                // Like
                StreamBuilder<bool>(
                  stream: phone == null
                      ? const Stream.empty()
                      : StoryService.watchHasLiked(
                          storyId: widget.story.id,
                          userPhone: phone,
                        ),
                  initialData: false,
                  builder: (context, snap) {
                    final liked = snap.data == true;
                    return _ActionButton(
                      icon: liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: loc.like,
                      streamCount: StoryService.watchLikeCount(widget.story.id),
                      active: liked,
                      onTap: _likeBusy ? null : _toggleLike,
                      activeColor: AppColors.error,
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Comments
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: loc.comments,
                  streamCount: StoryService.watchCommentCount(widget.story.id),
                  onTap: _openComments,
                  activeColor: scheme.primary,
                ),
                const SizedBox(width: 12),
                // Bookmark
                _ActionButton(
                  icon: _bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: _bookmarked ? loc.saved : loc.save,
                  onTap: _bookmarkBusy ? null : _toggleBookmark,
                  active: _bookmarked,
                  activeColor: AppColors.accent,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              widget.story.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
                height: 1.5,
              ),
            ),

            const Divider(height: 40),

            Text(
              widget.story.content,
              style: TextStyle(
                fontSize: 17,
                height: 1.7,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Stream<int>? streamCount;
  final VoidCallback? onTap;
  final bool active;
  final Color? activeColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.streamCount,
    this.onTap,
    this.active = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color tint = (active && activeColor != null)
        ? activeColor!
        : scheme.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? tint.withValues(alpha: 0.12) : scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? tint.withValues(alpha: 0.6)
                  : scheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tint, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: tint,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (streamCount != null) ...[
                const SizedBox(width: 6),
                StreamBuilder<int>(
                  stream: streamCount,
                  builder: (context, snap) {
                    final count = snap.data ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return Text(
                      '$count',
                      style: TextStyle(
                        color: tint,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
