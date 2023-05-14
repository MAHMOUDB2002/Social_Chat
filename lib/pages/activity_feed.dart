import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/header.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: header(context,titleText: "ActivityFeed"),
      body: Center(
        child: Text("ActivityFeed"),
      ),
    ));
  }
}
