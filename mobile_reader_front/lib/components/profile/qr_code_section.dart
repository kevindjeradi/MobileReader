import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_navigation.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/services/user_service.dart';
import 'package:mobile_reader_front/views/social/add_friend.dart';
import 'package:mobile_reader_front/views/social/friends_list.dart';
import 'package:mobile_reader_front/views/social/scan_qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';

class QrCodeSection extends StatelessWidget {
  const QrCodeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Card(
      color: theme.colorScheme.background,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (userProvider.uniqueIdentifier.isNotEmpty)
                Column(
                  children: [
                    Text(
                      "Partager votre compte",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Partager mon code ami",
                                    style: theme.textTheme.displayMedium,
                                  ),
                                  QrImageView(
                                    data: userProvider.uniqueIdentifier,
                                    version: QrVersions.auto,
                                    size:
                                        MediaQuery.of(context).size.width * 0.8,
                                    gapless: false,
                                    dataModuleStyle: QrDataModuleStyle(
                                        color: theme.colorScheme.onBackground),
                                    eyeStyle: QrEyeStyle(
                                        color: theme.colorScheme.onBackground),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: QrImageView(
                        data: userProvider.uniqueIdentifier,
                        version: QrVersions.auto,
                        size: 100.0,
                        gapless: false,
                        dataModuleStyle: QrDataModuleStyle(
                            color: theme.colorScheme.onBackground),
                        eyeStyle:
                            QrEyeStyle(color: theme.colorScheme.onBackground),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => theme.colorScheme.surface),
                          foregroundColor: MaterialStateProperty.resolveWith(
                              (states) => theme.colorScheme.onBackground)),
                      onPressed: () {
                        CustomNavigation.push(context, const FriendsList());
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_alt),
                          SizedBox(width: 10),
                          Text("Vos amis"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => theme.colorScheme.surface),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith((states) =>
                                      theme.colorScheme.onBackground)),
                          onPressed: () => _navigateAndScanQR(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_alt_1),
                              SizedBox(width: 10),
                              Text("Ajouter un ami"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateAndScanQR(BuildContext context) async {
    final scannedData = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScanQR()),
    );

    if (scannedData != null) {
      final result = await UserService().userExists(scannedData);

      if (result['exists']) {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return AddFriend(
                scannedUserId: scannedData,
                username: result['username'],
                profileImage: result['profileImage'],
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          showCustomSnackBar(
              context, "Utilisateur introuvable", SnackBarType.error);
        }
      }
    }
  }
}
