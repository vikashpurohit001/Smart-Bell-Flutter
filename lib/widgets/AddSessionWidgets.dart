import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/utilities/TextStyles.dart';


class LineDivider extends StatelessWidget {
  const LineDivider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 1.h, right: 1.h),
        child: Divider(
          height: 1,
          color: Color(0xff717171),
        ));
  }
}

class SessionListForwardTile extends StatelessWidget {
  String label, value;
  Function onTap;

  SessionListForwardTile({this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles().black18Normal,
          ),
          SizedBox(
            width: 3.h,
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              textAlign: TextAlign.end,
              style:  TextStyles.black14Normal,
            ),
          ),
          SizedBox(
            width: 3.h,
          ),
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: Color(0xff3B3B3B),
            size: 2.h,
          ),
        ],
      ),
      // isThreeLine: true,
    );
  }
}

class SessionListSwitchTile extends StatelessWidget {
  String label;
  bool value;
  Function(bool) onChanged;

  SessionListSwitchTile({this.label, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style:  TextStyles().black18Normal,
      ),
      trailing: Switch(
        value: value,
        inactiveTrackColor: Colors.grey,
        activeColor: Theme.of(context).primaryColor,
        onChanged: onChanged,
      ),
    );
  }
}
