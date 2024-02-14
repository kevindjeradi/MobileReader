import 'package:flutter/material.dart';
import 'package:mobile_reader_front/views/add_novel.dart';

class SelectNovelSource extends StatefulWidget {
  const SelectNovelSource({super.key});

  @override
  SelectNovelSourceState createState() => SelectNovelSourceState();
}

class SelectNovelSourceState extends State<SelectNovelSource> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez la source du novel'),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                Card(
                    elevation: 4.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: InkWell(
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const AddNovel(novelSource: 'NovelFull'),
                        ));
                      },
                      child: const Center(
                          child: Text(
                        'NovelFull',
                      )),
                    )),
                const Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Center(
                        child: Text(
                      'Autre source à venir',
                    ))),
                const Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Center(
                        child: Text(
                      'Autre source à venir',
                    ))),
              ]),
        ],
      ),
    );
  }
}
