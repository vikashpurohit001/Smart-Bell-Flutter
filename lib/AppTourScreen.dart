import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_url/open_url.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:url_launcher/url_launcher.dart';

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({Key key}) : super(key: key);

  @override
  _AppTourScreenState createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  int _currentPage = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );
  List<AppTourData> appTour = [];

  @override
  void initState() {
    appTour = [
      AppTourData(
          "Tap on Home to see Home Screen, includes connected device List or we can add Device from here.",
          "screen1.png"),
      AppTourData("Click on Profile to see profile details and other settings",
          "screen2.png"),
      AppTourData(
          "Click on Add Device to add new Device. See the video to go through add Device process.",
          "screen3.png",
          url: Platform.isAndroid
              ? "https://www.youtube.com/watch?v=FgcoN3zYSKA"
              : "https://www.youtube.com/watch?v=U2N2M5SeXCs"),
      AppTourData(
          "It is Device Details. Tap the item to view session Details along with Device Info and add and Edit Session Details.",
          "screen4.png"),
      AppTourData(
          "Click on Edit Icon to change the name of Device.", "screen5.png"),
    ];
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < appTour.length) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget backWidget = Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Color(0xff3E3E3E),
        ),
        iconSize: 4.h,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        toolbarHeight: 10.h,
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
        leadingWidth: 6.h,
        leading: backWidget,
        title: Text(
          "App Tour",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (ctx, index) {
            AppTourData item = appTour.elementAt(index);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset("assets/images/tour/${item.image}"),
                    ),
                    flex: 4,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          Text(
                            item.description,
                            style: TextStyles.black14Normal,
                          ),
                          if (item.url != null)
                            InkWell(
                              onTap: () {
                                launch(item.url);
                                // launch(item.url);
                              },
                              child: Text(
                                item.url,
                                style: TextStyles.blueUnderline14Normal,
                              ),
                            )
                        ],
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            );
          },
          itemCount: appTour.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(() {});
    _pageController.dispose();
    super.dispose();
  }
}

class AppTourData {
  String description;
  String image, url;

  AppTourData(this.description, this.image, {this.url});
}
