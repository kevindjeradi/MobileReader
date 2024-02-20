import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/models/novel.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:provider/provider.dart';

class NovelDetailSliverAppBar extends StatefulWidget {
  final Novel novel;

  const NovelDetailSliverAppBar({super.key, required this.novel});

  @override
  State<NovelDetailSliverAppBar> createState() =>
      _NovelDetailSliverAppBarState();
}

class _NovelDetailSliverAppBarState extends State<NovelDetailSliverAppBar> {
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

      // Update the provider's state only if the backend update is successful.
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.toggleFavoriteStatus(widget.novel.novelTitle);
      }
    } catch (e) {
      // If there's an error, revert the isFavorite state to its previous value
      setState(() {
        isFavorite = !isFavorite;
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
    final theme = Theme.of(context);

    return SliverAppBar(
      elevation: 0,
      expandedHeight: MediaQuery.of(context).size.height * 0.50,
      backgroundColor: theme.colorScheme.background,
      floating: false,
      pinned: true,
      leading: IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: theme.colorScheme.onBackground,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16.0),
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(
            widget.novel.novelTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground,
                shadows: const <Shadow>[
                  Shadow(
                    offset: Offset(0.0, 2.0),
                    blurRadius: 5.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ]),
          ),
        ),
        background: Hero(
          tag: 'novel-cover-${widget.novel.coverUrl}',
          child: Container(
            color: theme.colorScheme.background,
            child: Image.network(
              widget.novel.coverUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: _toggleFavorite,
          icon: Icon(
            color: isFavorite ? Colors.red : Theme.of(context).iconTheme.color,
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
        ),
      ],
    );
  }
}
