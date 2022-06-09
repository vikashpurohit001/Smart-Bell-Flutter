import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/model/single.dart';
import 'package:smart_bell/screen/AddSessionTime.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bell/dao/DeviceList.dart';

class SetupSessionTime extends StatefulWidget {
  String deviceToken;
  DeviceList deviceData;
  List<SessionData> sessionList;
  Function(SessionData) onAdd;
  List<DeviceList> _deviceDataList = [];

  SetupSessionTime(
      {Key key,
      this.deviceToken,
      this.deviceData,
      this.sessionList,
      this.onAdd})
      : super(key: key);

  @override
  _SetupSessionTimeState createState() => _SetupSessionTimeState();
}

class _SetupSessionTimeState extends State<SetupSessionTime> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 30, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            // direction: Axis.vertical,
            children: [
              Image.asset(
                'assets/images/time_icon.png',
                width: 200,
                height: 200,
              ),
              ImageNoteText(
                'There are currently no Session Time. First add Session Time.',
              ),
            ],
          ),
          Spacer(),
          AppElevatedButtons(
            'Add Schedule',
            onPressed: () async {
              SessionData sessionData =
                  await Navigators.push(context, AddSessionTime());

              // widget.sessionList.add(sessionData);
              // setState(() {});
              widget.onAdd(sessionData);
            },
          )
        ],
      ),
    );
  }
}
