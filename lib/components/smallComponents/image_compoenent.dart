import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageComponent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String time;
  final String duration;

  const ImageComponent({
    Key? key,
    required this.imagePath,
    this.title = "test",
    this.time = '',
    this.duration = '',
  }) : super(key: key);

  text(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uniqueTag = UniqueKey().toString();
    const bool url = true;
    // const errorImage =
    // //     'https://dicdn.bigfuck.tv/Qbc_5-9LHHJQijmVZSAKSkjuET8-WEVK52UdxGdxXGs/rs:fill:360:506/crop:0:0.90:no/enlarge:1/wm:1:nowe:0:0:1/Swmu:aHR0cHM6Ly9jZG42OTY5NjE2NC5haGFjZG4ubWUvcG9ybnN0YXJfYXZhdGFyX3dhdGVybWFyay5wbmc=/aHR0cHM6Ly9pY2RuMDUuYmlnZnVjay50di9wb3Juc3Rhci84NDAvMTU2YTQ4NjlkMDhlZTBiODY0ZDlmMGEwNWY3MmE4ZWIuanBn.webp';
    final image = url == false
        ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnSsLWVn6ZOrtsgl4lhc4C9DnRGk8ituA04w&usqp=CAU"
        : imagePath;
    return Stack(
      children: [
        Hero(
          tag: uniqueTag,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(title == 'channel' ? 1200000 : 8.0),
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              height: title == 'star'
                  ? 300
                  : title == 'channel'
                      ? 150
                      : double.infinity,
              width: title == 'channel' ? 150 : double.infinity,
              errorWidget: (context, url, error) => Stack(children: [
                Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/error_image.webp', // Replace with the path to your error image asset
                    height: title == 'star' ? 300 : 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Center(
                  child: Icon(Icons.error),
                )
              ]),
              // color: Colors.blue38,
              placeholderFadeInDuration: const Duration(milliseconds: 700),
              useOldImageOnUrlChange: true,

              // errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        // if (title != 'star' && title != 'channel')
        //   Positioned(
        //     bottom: 0,
        //     right: 0,
        //     left: 0,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         text(duration),
        //         text(time),
        //       ],
        //     ),
        //   )
      ],
    );
  }

  Widget errorWidget(String alternativeImageUrl) {
    return Image.network(
      alternativeImageUrl,
      width: 200,
      height: 200,
    );
  }
}
