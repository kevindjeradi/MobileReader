// novel_details_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/expandable_text.dart';

class NovelDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> novelDetails;
  final bool isNovelLoading;
  final VoidCallback onAddNovel;

  const NovelDetailsWidget({
    Key? key,
    required this.novelDetails,
    required this.isNovelLoading,
    required this.onAddNovel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Image.network(
            novelDetails['coverUrl'],
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('${novelDetails['title']}',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        Text('Author: ${novelDetails['author']}'),
        const SizedBox(height: 12),
        ExpandableText(text: 'Description: ${novelDetails['description']}'),
        const SizedBox(height: 12),
        Text('Chapters:', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        isNovelLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => theme.colorScheme.surface),
                  foregroundColor: MaterialStateProperty.resolveWith(
                      (states) => theme.colorScheme.onBackground),
                ),
                onPressed: onAddNovel,
                child: const Text('Ajouter le novel à ma bibliotheque'),
              ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: novelDetails['chapters'].length > 20
              ? 21
              : novelDetails['chapters'].length,
          itemBuilder: (context, index) {
            if (index >= 20) {
              return const Center(
                child: Text('...',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              );
            }
            final chapter = novelDetails['chapters'][index];
            return ListTile(
              title: Text(chapter['title']),
            );
          },
        ),
      ],
    );
  }
}
