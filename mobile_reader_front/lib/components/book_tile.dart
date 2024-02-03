import 'package:flutter/material.dart';
import 'package:mobile_reader_front/models/book.dart';
import 'package:mobile_reader_front/views/book_detail.dart';

class BookTile extends StatefulWidget {
  final Book book;
  final double width;

  const BookTile({
    Key? key,
    required this.book,
    this.width = 200,
  }) : super(key: key);

  @override
  BookTileState createState() => BookTileState();
}

class BookTileState extends State<BookTile> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.book.favorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetail(book: widget.book),
          ),
        );
      },
      child: Container(
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
                      widget.book.coverUrl,
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
                      child: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.book.author,
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
                    value: widget.book.progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(widget.book.progress * 100).toStringAsFixed(0)}%',
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
