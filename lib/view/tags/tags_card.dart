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
  List<Tags> filteredItems = [];
  bool isLoading = false;
  final int extraItems = 4;
  TextEditingController searchController = TextEditingController();

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
        filteredItems.addAll(newTags);

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

  void filterList(String query) {
    setState(() {
      filteredItems = tags
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              seachBar(),
              filteredItems.isEmpty
                  ? const Center(
                      child: Text('no tags found'),
                    )
                  : Wrap(
                      children: filteredItems.map((Tags tag) {
                        return buildVideoCard(tag);
                      }).toList(),
                    ),
            ],
          ),
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

  Padding seachBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: (v) {
          filterList(v);
        },
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16.0,
        ),
        cursorColor: Colors.blue,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          hintText: 'Type to search...',
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget buildVideoCard(Tags tags) {
    final title = tags.title;

    return GestureDetector(
      onTap: () {
        if (title.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewContainer(passedData: title),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
        child: Chip(
          label: Text(
            tags.title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.blue[400],
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6000),
          ),
        ),
      ),
    );
  }
}
