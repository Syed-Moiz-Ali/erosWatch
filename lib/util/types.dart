// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../model/Channels/channel_screen.dart';
import '../model/pages/pages.dart';

class TrendingScreen extends StatelessWidget {
  dynamic type;
  TrendingScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return PageScreen(
      key: key,
      type: type,
    );
  }
}

class PopularScreen extends StatelessWidget {
  dynamic type;
  PopularScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return PageScreen(
      key: key,
      type: type,
    );
  }
}

class UpcomingScreen extends StatelessWidget {
  dynamic type;
  UpcomingScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return PageScreen(
      key: key,
      type: type,
    );
  }
}

class NewScreen extends StatelessWidget {
  dynamic type;
  NewScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return PageScreen(
      key: key,
      type: type,
    );
  }
}

class ChannelPopularScreen extends StatelessWidget {
  dynamic type;
  ChannelPopularScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return ChannelScreen(
      key: key,
      param: type,
    );
  }
}

class ChannelHotScreen extends StatelessWidget {
  dynamic type;
  ChannelHotScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return ChannelScreen(
      key: key,
      param: type,
    );
  }
}

class ChannelNewScreen extends StatelessWidget {
  dynamic type;
  ChannelNewScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return ChannelScreen(
      key: key,
      param: type,
    );
  }
}

class ChannelNameScreen extends StatelessWidget {
  dynamic type;
  ChannelNameScreen({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return ChannelScreen(
      key: key,
      param: type,
    );
  }
}
