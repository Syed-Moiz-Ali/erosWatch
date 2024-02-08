import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cardProvider.dart';
import '../../util/utils.dart';
import 'components/library_screen_body.dart';

class LibraryScreen extends StatelessWidget {
  LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var cardProvider = Provider.of<CardProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Library',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (cardProvider.isLoading == false)
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0, right: 5.0),
                  child: Container(
                    width: 25,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Text(
                        getLibraryLength(cardProvider).toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: const LibraryScreenBody(),
    );
  }

  int getLibraryLength(CardProvider cardProvider) {
    if (cardProvider.libraryType == 'video') {
      return cardProvider.videosLength;
    } else if (cardProvider.libraryType == 'star') {
      return cardProvider.starsLength;
    } else {
      return cardProvider.channelsLength;
    }
  }
}
