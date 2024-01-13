// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/components/api/api_service.dart';
import 'package:eroswatch/components/container/container_screen.dart';

import '../helper/videos.dart';

class VideoTagsContainer extends StatefulWidget {
  final String id;
  late String text;
  late int choiceIndex;
  VideoTagsContainer(
      {super.key,
      required this.id,
      required this.choiceIndex,
      required this.text});

  @override
  State<VideoTagsContainer> createState() => _VideoTagsState();
}

class _VideoTagsState extends State<VideoTagsContainer> {
  late APIServiveForVideoTags apiService;
  List<VideoTags> tagss = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    apiService = APIServiveForVideoTags(params: widget.id);
    fetchTags();
  }

  Future<List<VideoTags>> fetchTags() async {
    if (isLoading) return tagss;

    setState(() {
      isLoading = true;
    });

    try {
      final List<VideoTags> response = await apiService.fetchWallpapers();
      if (kDebugMode) {
        print(response);
      }

      setState(() {
        tagss.addAll(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print('Failed to load tagss: $e');
      }
    }

    return tagss; // Return the tagss list after processing
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.text);
    }
    final filteredContent =
        tagss.where((tag) => !tag.tagTitle.contains('...')).toList();
    return isLoading == true
        ? const SizedBox.shrink()
        : Row(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredContent.length,
            itemBuilder: (context, index) {
              if (index == filteredContent.length) {
                return const SizedBox.expand();
              }
              final VideoTags tags = filteredContent[index];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2000)),
                child:
                    // ChoiceChip(
                    //   label: Text(tags.tagTitle),
                    //   selected: widget.choiceIndex == index,
                    //   onSelected: (bool selected) {
                    //     setState(() {
                    //       widget.choiceIndex = selected ? index : 0;
                    //       widget.text = tags.tagTitle;
                    //     });
                    //   },
                    //   selectedColor: Colors.blue.shade300,
                    //   backgroundColor: Colors.blue,
                    // ),

                    Center(
                  child: TextButton(
                    onPressed: () {
                      // ViewContainer(passedData: tags.tagTitle);
                      if (tags.tagTitle.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewContainer(passedData: tags.tagTitle),
                          ),
                        );
                      }
                    },
                    child: Text(
                      tags.tagTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
