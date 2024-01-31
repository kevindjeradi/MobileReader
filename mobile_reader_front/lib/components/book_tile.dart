import 'package:flutter/material.dart';

class BookTile extends StatefulWidget {
  final String coverUrl;
  final String title;
  final String author;
  final double width;
  final double progress;
  final bool favorite;

  const BookTile({
    Key? key,
    required this.coverUrl,
    required this.title,
    required this.author,
    required this.width,
    required this.progress,
    this.favorite = false,
  }) : super(key: key);

  @override
  BookTileState createState() => BookTileState();
}

class BookTileState extends State<BookTile> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.favorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Image.network(
                    widget.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        favorite = !favorite;
                      });
                    },
                    child: favorite
                        ? const Icon(Icons.favorite)
                        : const Icon(Icons.favorite_border),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.author,
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
                  value: widget.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
