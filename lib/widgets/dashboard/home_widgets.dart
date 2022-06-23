import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/dao/DeviceBell.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/dashboard/navigation.dart';

SwipeAction swipeDelete({onTap}) => SwipeAction(
    title: "Delete",
    style: TextStyles.white18Normal,
    onTap: (CompletionHandler handler) {
      onTap();
    },
    color: Colors.red);

Widget BellIcon({bool isActive, bool isPaused}) => Image.asset(
      'assets/images/app_icon.png',
      color: isActive
          ? isPaused
              ? Colors.green.withOpacity(0.3)
              : Colors.green
          : isPaused
              ? Colors.red.withOpacity(0.3)
              : Colors.red,
      width: 4.h,
    );

Widget DeviceName(context, DeviceBell _data) {
  return Flexible(
    child: Text(
      '${_data.name}',
      style: _data.isPaused
          ? Theme.of(context).textTheme.headline1.copyWith(color: Colors.grey)
          : Theme.of(context).textTheme.headline1,
    ),
  );
}

Widget IconWidget(context, {Function() onPressed, DeviceBell data}) =>
    IconButton(
      splashColor: Colors.grey,
      splashRadius: 3.h,
      iconSize: 1.h,
      onPressed: onPressed,
      icon: Image.asset(
        'assets/images/edit.png',
        width: 2.h,
        color:
            data.isPaused ? Color(0xffC9C9C9) : Theme.of(context).primaryColor,
      ),
    );

Widget EditIconShowCase(context, {GlobalKey key, Widget child}) =>
    MyShowCaseWidget(
        key: key, description: 'Edit Device Name from here.', child: child);
