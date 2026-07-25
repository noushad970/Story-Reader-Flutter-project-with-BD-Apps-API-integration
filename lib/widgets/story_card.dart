import 'package:flutter/material.dart';

import '../models/story_model.dart';
import '../screens/user/story_details_screen.dart';
import '../theme/app_theme.dart';
import 'animated_widgets.dart';

class StoryCard extends StatelessWidget {
  final StoryModel story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        radius: 22,
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StoryDetailsScreen(story: story)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.coverImageUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      story.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                        );
                      },
                    ),
                    // Bottom gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (story.categoryName.isNotEmpty)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            story.categoryName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.sunset,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'By ${story.author}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
