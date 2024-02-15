import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reader_front/components/generics/custom_image.dart';

class FriendCard extends StatefulWidget {
  final Map<String, dynamic> friendData;

  const FriendCard({Key? key, required this.friendData}) : super(key: key);
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: widget.friendData['profileImage'] != null
                  ? CustomImage(
                      imagePath: FriendCard.baseUrl +
                          widget.friendData['profileImage'])
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(widget.friendData['username'] ?? 'Unknown'),
              subtitle: Text(
                  'Compte crée le: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.friendData['dateJoined']))}'),
            ),
          ),
        ],
      ),
    );
  }
}
