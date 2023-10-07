import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/components/api/api_service.dart';
import 'package:eroswatch/components/container/container_screen.dart';
import 'package:eroswatch/helper/videos.dart';

class TagsCard extends StatefulWidget {
  final String param;

  const TagsCard({Key? key, required this.param}) : super(key: key);

  @override
  State<TagsCard> createState() => _TagsCardState();
}

class _TagsCardState extends State<TagsCard> {
  late APITags apiTags;
  List<Tags> tags = [];
  bool isLoading = false;
  final int extraItems = 4;

  @override
  void initState() {
    super.initState();
    apiTags = APITags(
      params: widget.param,
    );
    fetchTags();
  }

  Future<void> fetchTags() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Tags> newTags = await apiTags.fetchWallpapers();

      setState(() {
        tags.addAll(newTags);

        isLoading = false;
      });
      // print(tags);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load tags: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Adjust the number of columns as needed
            mainAxisExtent: 45,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount:
              tags.length + extraItems, // Assuming Tags has a videos property
          itemBuilder: (context, index) {
            if (index < tags.length) {
              Tags tag = tags[index];
              return buildVideoCard(tag);
            } else {
              // Return a placeholder for white space
              return Container(color: Colors.transparent);
            }
          },
        ),
        if (isLoading)
          const Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }

  Widget buildVideoCard(Tags tags) {
    final title = tags.title;
    // Implement this function to return a widget representing a video card
    // You can customize the appearance and layout of the video card here
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
      height: 45,
      decoration: BoxDecoration(
          color: Colors.blue[400], borderRadius: BorderRadius.circular(2000)),
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
            if (title.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewContainer(passedData: title),
                ),
              );
            }
          },
          child: Text(
            tags.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
