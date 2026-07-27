import 'package:flutter/material.dart';

import '../../../models/story_model.dart';
import '../../../services/admin_story_service.dart';

class ManageStoriesScreen extends StatelessWidget {
  const ManageStoriesScreen({super.key});

  Future<void> deleteStory(BuildContext context, StoryModel story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Story?'),
          content: Text('Delete "${story.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await AdminStoryService.deleteStory(story.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Story deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Stories')),
      body: StreamBuilder<List<StoryModel>>(
        stream: AdminStoryService.getAllStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stories = snapshot.data ?? [];

          if (stories.isEmpty) {
            return const Center(child: Text('No stories found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];

              return Card(
                child: ListTile(
                  leading: story.coverImageUrl.isNotEmpty
                      ? Image.network(
                          story.coverImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.menu_book),

                  title: Text(story.title),

                  subtitle: Text(
                    '${story.categoryName}\n'
                    '${story.isPublished ? 'Published' : 'Draft'}',
                  ),

                  isThreeLine: true,

                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await deleteStory(context, story);
                      }

                      if (value == 'toggle') {
                        await AdminStoryService.updatePublishStatus(
                          storyId: story.id,
                          isPublished: !story.isPublished,
                        );
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            story.isPublished ? 'Unpublish' : 'Publish',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
