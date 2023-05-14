import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/header.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
      appBar: header(context,titleText: "Profile"),
      body: Center(
        child: Text("Profile"),
      ),
    )
    );
  }
}