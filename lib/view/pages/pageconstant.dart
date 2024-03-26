import 'package:eroswatch/models/spankbang.dart';
import 'package:flutter/material.dart';

import '../card/card_screen.dart';
import '../../helper/videos.dart';

class PageConstant extends StatefulWidget {
  final VoidCallback? fetchWallpapers;
  final List<VideoItem> content;
  final bool isLoading;

  const PageConstant({
    super.key,
    required this.fetchWallpapers,
    required this.content,
    required this.isLoading,
  });

  @override
  State<PageConstant> createState() => _PageConstantState();
}

class _PageConstantState extends State<PageConstant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // creen Width:: AppBar(title: const Text("Latest Wallpapers")),
      body: Stack(
        children: [
          // const SizedBox(
          //   height: 500,
          //   width: double.infinity,
          // ),
          CardScreen(
            content: widget.content,
          ),
          if (widget.isLoading)
            // Loader widget displayed in the center of the screen
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
