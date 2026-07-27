import 'package:flutter/material.dart';

import '../../app_localizations.dart';
import '../../models/story_model.dart';
import '../../services/auth_service.dart';
import '../../services/bookmark_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/story_card.dart';
import 'home_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final phone = AuthService.currentUserPhone;
    if (phone == null || phone.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.bookmarksTitle)),
        body: Center(child: Text(loc.bookmarksLoginRequired)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.bookmarksTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: StreamBuilder<List<StoryModel>>(
        stream: BookmarkService.watchBookmarks(phone),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget(fullScreen: false, message: loc.loading);
          }
          if (snapshot.hasError) {
            return Center(child: Text(loc.networkError));
          }

          final list = snapshot.data ?? const <StoryModel>[];

          if (list.isEmpty) {
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
                      Icons.bookmark_border_rounded,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.bookmarksEmptyTitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.bookmarksEmptyBody,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: Text(loc.goToHome),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return StoryCard(story: list[index]);
            },
          );
        },
      ),
    );
  }
}
