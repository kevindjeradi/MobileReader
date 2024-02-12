import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generic/custom_snackbar.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/models/novel.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:mobile_reader_front/views/novel_detail.dart';
import 'package:provider/provider.dart';

class BookTile extends StatefulWidget {
  final Novel novel;
  final double width;
  final bool showFavorite;

  const BookTile({
    Key? key,
    required this.novel,
    this.width = 200,
    this.showFavorite = true,
  }) : super(key: key);

  @override
  BookTileState createState() => BookTileState();
}

class BookTileState extends State<BookTile> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.novel.isFavorite;
  }

  void _toggleFavorite() async {
    // Toggle the local isFavorite state right away to ensure UI updates immediately
    // and prevents sending multiple requests with the same status.
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      Log.logger.i("Sending updateFavoriteStatus with isFavorite: $isFavorite");
      // Send the updated isFavorite status to the backend.
      await NovelService.updateFavoriteStatus(
          widget.novel.novelTitle, isFavorite);

      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.toggleFavoriteStatus(widget.novel.novelTitle);
      }
    } catch (e) {
      // If there's an error, revert the isFavorite state to its previous value
      // to reflect that the update didn't go through successfully.
      setState(() {
        isFavorite = !isFavorite; // Revert the change
      });

      if (mounted) {
        Log.logger.e("An error occurred in _toggleFavorite: $e");
        showCustomSnackBar(
            context, 'Impossible de modifier le favori.', SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress based on chapters if needed
    double progress =
        widget.novel.lastReadChapter / widget.novel.numberOfChapters;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NovelDetail(novel: widget.novel),
          ),
        );
      },
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.showFavorite
                ? Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Image.network(
                            widget.novel.coverUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: _toggleFavorite,
                            child: Icon(
                              color: isFavorite
                                  ? Colors.red
                                  : Theme.of(context).iconTheme.color,
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Image.network(
                        widget.novel.coverUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              widget.novel.novelTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.novel.author,
              style: const TextStyle(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
