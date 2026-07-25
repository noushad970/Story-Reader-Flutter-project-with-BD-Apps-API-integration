import 'package:flutter/material.dart';

import '../../models/story_model.dart';

class StoryDetailsScreen extends StatelessWidget {
  final StoryModel story;

  const StoryDetailsScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.coverImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  story.coverImageUrl,
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            Text(
              story.title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'By ${story.author}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 8),

            Chip(label: Text(story.categoryName)),

            const SizedBox(height: 20),

            Text(
              story.description,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const Divider(height: 40),

            Text(
              story.content,
              style: const TextStyle(fontSize: 18, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
