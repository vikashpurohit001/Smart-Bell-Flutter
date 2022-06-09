import 'dart:io';

import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/AuthWifiScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/utilities/LifeCycleEventHandler.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:smart_bell/widgets/ProgressIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bell/widgets/ShowCase.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:sizer/sizer.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WifiScanScreen extends StatefulWidget {
  String deviceToken,deviceId;

  WifiScanScreen({Key key, this.deviceToken,this.deviceId}) : super(key: key);

  @override
  _WifiScanScreenState createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends BaseState<WifiScanScreen> {
  List<String> wifis = [];
  List<String> imgList = ["assets/images/wifi_info_1.png","assets/images/wifi_info_2.png","assets/images/wifi_info_3.png"];
  bool isLoading = true;

  @override
  void initState() {

    registerWifi();
    callAPI();
    super.initState();
  }

  registerWifi() {
    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async => callAPI()));
  }

  void callAPI() {
    if(Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(true);
    }
    isLoading = true;
    setState(() {});
    RestServerApi().getWifiList(context).then((value) {
      if (value != null) {
        wifis = value;
      } else {
       showSnackBar('No list found',isError: true);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
      showSnackBar('Error fetching Wifi list. Please try again later.',isError: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget backWidget = Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Colors.black,
        ),
        iconSize: 24,
        onPressed: () {
          Navigators.push(context, ShowCase());
        },
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: AppStackView(
          alignment: Alignment.center,
          child: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                       EdgeInsets.only( bottom: 2.h, top: 2.h),
                  child: Row(
                    children: [
                      backWidget,
                      TitleText(
                        'Wifi Search',
                      ),
                    ],
                  ),
                ),
                if(wifis.isEmpty)
                Spacer(),
                if(wifis.isEmpty)
                  CarouselSlider(
                      items: imgList
                          .map((item) => Image.asset(item, fit: BoxFit.cover))
                          .toList(),
                      options: CarouselOptions(
                        height: 50.h,
                        aspectRatio: 16/9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 2),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.easeInOutQuart,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      )
                  ),
                if(wifis.isEmpty)
                Spacer(),
                Padding(
                  padding:  EdgeInsets.only(left: 2.h, right: 2.h),
                  child: Text(
                    (wifis.isEmpty)
                        ? 'Connect with Smart bell to get Wifi List. Please connect with Smart Bell manually and Retry.'
                        : 'The Search process may take up to two minutes. Please do not perform any operations during  this time',
                    style: TextStyles.black14Normal,
                  ),
                ),
                if(wifis.isEmpty)
                Spacer(),
                (wifis.isEmpty)?AppElevatedButtons(
                  "Retry",
                  onPressed: () {
                    callAPI();
                  },
                ):Expanded(
                  child: isLoading
                          ? AppIndicator()
                          : Container(
                              child: ListView.builder(
                                  itemCount: wifis.length,
                                  itemBuilder: (context, index) {
                                    String wifiData = wifis.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        Navigators.push(
                                            context,
                                            AuthWifiScreen(
                                                wifiNetwork: wifiData,
                                                deviceToken:
                                                    widget.deviceToken,deviceId:widget.deviceId));
                                      },
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal: 2.h,vertical: 1.h),
                                        child: Wrap(
                                          direction: Axis.horizontal,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 3.h,
                                              backgroundColor: Colors.white,
                                              child: Icon(
                                                Icons.wifi,
                                                size: 3.h,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2.h,
                                            ),
                                            Text(
                                              wifis.elementAt(index),
                                              style: TextStyles().black12Normal)
                                          ],
                                        ),
                                      ),
                                    );
                                  })),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

}
