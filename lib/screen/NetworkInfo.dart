import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/utilities/TextStyles.dart';

class NetworkInfo extends StatelessWidget {
  Map<String, dynamic> wifiInfo;

  NetworkInfo({Key key, this.wifiInfo}) : super(key: key);

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
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
    return Scaffold(
        body: Container(
          child: Column(
            children: [
              Flexible(
                flex: 4,
                child: Center(
                  child: Icon(
                    Icons.wifi_sharp,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              InfoLineWidget('Wi-Fi Name', wifiInfo['ssid']),
              Divider(
                height: 0.5.h,
                color: Colors.grey,
              ),
              InfoLineWidget(
                  'Wi-Fi Signal Strength', wifiInfo['wifiSignalStrength'].toString()),
              Divider(
                height: 0.5.h,
                color: Colors.grey,
              ),
              InfoLineWidget('Frequency', wifiInfo['freq'].toString()),
              Divider(
                height: 0.5.h,
                color: Colors.grey,
              ),
              InfoLineWidget('IP Address', wifiInfo['ip'].toString()),
              Divider(
                height: 0.5.h,
                color: Colors.grey,
              ),
              InfoLineWidget('MAC Address', wifiInfo['bssid'].toString()),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          toolbarHeight: 10.h,
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.light,
          leadingWidth: 6.h,
          leading: backWidget,
          title: Text(
            "Network Info",
            style: Theme.of(context).textTheme.headline1,
          ),
        ));
  }

  Widget InfoLineWidget(String text, String value) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.all(2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyles.black14Normal,
            ),
            Text(value, style: TextStyles.black14Normal)
          ],
        ),
      ),
    );
  }
}
