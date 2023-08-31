import 'package:flutter/material.dart';

import '../../container_screen.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _MyCategoriesState();
}

class _MyCategoriesState extends State<Categories> {
  List<Map<String, dynamic>> imageData = [
    {
      'title': "Superheroes",
      'image': "https://images6.alphacoders.com/705/705204.jpg",
    },
    {
      'title': "Games",
      'image':
          "https://images.pushsquare.com/95c8579c8aaed/best-ps4-games.large.jpg",
    },
    {
      'title': "Creative",
      'image':
          "https://img.etimg.com/thumb/width-1200,height-900,imgsize-454592,resizemode-1,msid-71847479/markets/stocks/news/learning-from-creative-people-at-work-purposeful-inquiry-as-core-to-investing.jpg",
    },
    {
      'title': "Bikes",
      'image': "https://images.hdqwalls.com/download/bikes-1920x1080.jpg",
    },
    {
      'title': "Cars",
      'image':
          "https://www.motorious.com/content/images/2020/04/ash-crest-car-collection.jpg",
    },
    {
      'title': "3D",
      'image':
          "https://w0.peakpx.com/videos/530/696/HD-videos-dark-rubik-s-cube-3d-3d-abstract-abstract-3d-blocks-cube-simple-background-black-background-thumbnail.jpg",
    },
    {
      'title': "Nature",
      'image':
          "https://images.unsplash.com/photo-1552083375-1447ce886485?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bmF0dXJlJTIwd2FsbHBhcGVyfGVufDB8fDB8fA%3D%3D&w=1000&q=80",
    },
    {
      'title': "Tv Shows",
      'image':
          "https://e0.pxfuel.com/wallpapers/136/343/desktop-videos-this-with-of-late-nite-shane-dawson-thumbnail.jpg",
    },
    {
      'title': "Movies",
      'image':
          "https://c4.wallpaperflare.com/videos/862/449/162/jack-reacher-star-wars-interstellar-movie-john-wick-videos-preview.jpg",
    },
    {
      'title': "Celebrities",
      'image': "https://static.alphacoders.com/thumbs_categories/7.jpg",
    },
    {
      'title': "Computer",
      'image':
          "https://videos-mania.com/wp-content/uploads/2018/09/High_resolution_wallpaper_background_ID_77701411396.jpg",
    },
    {
      'title': "Planes",
      'image':
          "https://i.pinimg.com/originals/bb/1c/4a/bb1c4a72d7877f403100bb7cea9fd670.jpg",
    },
    {
      'title': "Sports",
      'image': "http://wallpaperset.com/w/full/5/8/c/119900.jpg"
    },
    {
      'title': "Animals",
      'image': "https://wallpaperaccess.com/full/1748372.jpg"
    },
    {
      'title': "Logo",
      'image':
          "https://i.pinimg.com/originals/09/e9/80/09e980fb3a54bc8e7ab7dc8bbf8131fa.jpg",
    },
    {
      'title': "Inspiration",
      'image': "https://wallpaperaccess.com/full/2306501.jpg",
    },
    {
      'title': "Artist",
      'image':
          "https://www.ie.edu/insights/wp-content/uploads/2020/10/Hindi-Art-for-Busniness-Leaders.jpg",
    },
    {
      'title': "Typography",
      'image':
          "https://www.hdwallpapers.net/previews/world-map-typography-511.jpg",
    },
    {
      'title': "Cute",
      'image':
          "https://i.pinimg.com/736x/c2/bf/74/c2bf74d9ef43bf24dcf73cde5a24f61c.jpg",
    },
    {
      'title': "Girls",
      'image':
          "https://w0.peakpx.com/videos/773/815/HD-videos-girls-cute-girl-girls-single-girl.jpg",
    },
    {
      'title': "Abstract",
      'image':
          "https://wallpapershome.com/images/wallpapers/windows-11-3840x2160-dark-abstract-microsoft-4k-23470.jpg",
    },
    {'title': "Birds", 'image': "https://wallpaperaccess.com/full/3668439.jpg"},
    {
      'title': "Graphics",
      'image':
          "https://w0.peakpx.com/videos/289/222/HD-videos-no-escape-astronaut-graphic-design-colourful-space.jpg",
    },
    {
      'title': "World",
      'image': "https://wallpapers.com/images/featured/0rp0vszrdz909xc9.jpg",
    },
    {
      'title': "Flowers",
      'image':
          "https://images.unsplash.com/photo-1606041008023-472dfb5e530f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8NHx8fGVufDB8fHx8&w=1000&q=80",
    },
    {
      'title': "Photography",
      'image':
          "https://images.unsplash.com/photo-1551728715-941acefa8a3d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8Y2FtZXJhJTIwd2FsbHBhcGVyfGVufDB8fDB8fA%3D%3D&w=1000&q=80",
    },
    {
      'title': "Celebration",
      'image':
          "https://i.pinimg.com/736x/87/84/34/878434b44085e1f0f8cb816cb3b95b42.jpg",
    },
    {
      'title': "Music",
      'image':
          "https://w0.peakpx.com/videos/717/37/HD-videos-moon-black-music-night.jpg",
    },
    {
      'title': "Indian Celebrities",
      'image':
          "https://w0.peakpx.com/videos/658/681/HD-videos-salman-khan-indian-actor-guys-bollywood-celebrity.jpg",
    },
    {
      'title': "Digital Universe",
      'image':
          "https://images.wallpapersden.com/image/download/a-4k-galaxy-digital-universe_bWxmZ2aUmZqaraWkpJRpbWZtrWdtbWU.jpg",
    },
    {
      'title': "Love",
      'image': "https://cdn.wallpapersafari.com/20/79/WPpfUN.jpg",
    },
    {
      'title': "Fantasy Girls",
      'image':
          "https://w0.peakpx.com/videos/517/703/HD-videos-fantasy-girl-fantasy-frumusete-luminos-girl-princess-mbyk-superb-gorgeous.jpg",
    },
    {
      'title': "Anime",
      'image':
          "https://images.wallpapersden.com/image/download/one-piece-hd-luffy-cool-art_bWhmZWWUmZqaraWkpJRoZ2VlrWZtZWU.jpg",
    },
    {
      'title': "Cartoons",
      'image': "https://www.pcclean.io/wp-content/uploads/2020/4/iAjaMn.jpg",
    },
    {
      'title': "Others",
      'image':
          "https://images2.minutemediacdn.com/image/upload/c_fill,w_1440,ar_16:9,f_auto,q_auto,g_auto/shape/cover/sport/istock-000039944040-small-ac98584642f4e4c167d378ac500b3485.jpg",
    },
    {
      'title': "LifeStyle",
      'image':
          "https://lh3.googleusercontent.com/kqVZwZEaFMAU3BeYwFAdkStKyrSm2wwVCBp_F8jyzAUiDhxrb09dqb-K0ovMnaylkiwC",
    },
    {
      'title': "Food",
      'image':
          "https://cdn.britannica.com/36/123536-050-95CB0C6E/Variety-fruits-vegetables.jpg",
    },
    // {title: "",},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          mainAxisExtent: 150,
        ),
        itemCount: imageData.length,
        itemBuilder: (context, index) {
          final item = imageData[index];
          final name = item['title'];
          final image = item['image'];
          final link = name.replaceAll(" ", "-").toLowerCase();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewContainer(passedData: 'wall/$link'),
                ),
              );
              (BuildContext context) {
                Navigator.pop(context, 'reload');
              };
            },
            child: GridTile(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      height: 150,
                      width: double.infinity,
                      // color: Colors.grey,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(6.0),
                      topLeft: Radius.circular(3.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      color: Colors.blue,
                      child: Text(
                        name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
