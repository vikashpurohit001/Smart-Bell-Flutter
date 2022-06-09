import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AddSessionWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddWeekScreen extends StatefulWidget {
  List<String> weekDays;

  AddWeekScreen({Key key, this.weekDays}) : super(key: key);

  @override
  _AddWeekScreenState createState() => _AddWeekScreenState();
}

class _AddWeekScreenState extends State<AddWeekScreen> {
  List<String> weekDays;

  @override
  void initState() {
    if (widget.weekDays != null) {
      weekDays = widget.weekDays;
    } else {
      weekDays = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(widget.weekDays);
        return;
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.light,
          //
          leading: CupertinoNavigationBarBackButton(
            color: Color(0xff3E3E3E),
          ),
          // border: Border(bottom: BorderSide(color: Colors.transparent)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(weekDays);
              },
              child: Text(
                'Save',
                style: TextStyles.theme18Bold,
              ),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
                'Repeat',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
                  'The action will be carried out only once if you do not select it.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline3),
            ),
            SizedBox(height: 20,),
            Column(
              children: [
                WeekWidget('Sunday'),
                LineDivider(),
                WeekWidget('Monday'),
                LineDivider(),
                WeekWidget('Tuesday'),
                LineDivider(),
                WeekWidget('Wednesday'),
                LineDivider(),
                WeekWidget('Thursday'),
                LineDivider(),
                WeekWidget('Friday'),
                LineDivider(),
                WeekWidget('Saturday'),
                LineDivider(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget WeekWidget(String week) {
    return ListTile(
      onTap: () {
        weekDays.contains(week) ? weekDays.remove(week) : weekDays.add(week);
        setState(() {});
      },
      title: Text(
        week,
        style: TextStyle(color: Colors.black),
      ),
      trailing: weekDays.contains(week)
          ? Icon(
        Icons.check,
        color: Theme
            .of(context)
            .primaryColor,
      )
          : SizedBox(
        width: 0,
        height: 0,
      ),
    );
  }

}
