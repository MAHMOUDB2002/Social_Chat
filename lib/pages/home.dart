import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_finalproject/pages/profile.dart';
import 'package:f_finalproject/pages/search.dart';
import 'package:f_finalproject/pages/upload.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'activity_feed.dart';
import 'create_user.dart';

// بنصللهم من وين ما بدنا ومن وين مكان
final googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection("users");
final postsRef = Firestore.instance.collection("posts");
final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();
late User currentUser;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    // حتتنفذ اول شي قبل البيلد
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (error) {
      print("error is $error");
    });

    try {
      //  عشان اذا المستخدم عامل لوجن يوديه للواجهة الرئيسية وا يرجعه عالبداية تسجيل الدخول
      googleSignIn.signInSilently(suppressErrors: false).then((account) {
        handleSignIn(account);
      }).catchError((err) {
        print("error in reopen $err");
      });
    } catch (e) {
      print("signInSilently error $e");
    }
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // get current user
    final GoogleSignInAccount user = googleSignIn.currentUser;
    // اخدت اليوزر الكرت وانشات دخول بواسطة غوغل
    // check user by id
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    String username = "";

    if (!doc.exists) {
      // if not create user go to create widget
      username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateUser()));

      // ننفحص اذا المستخدم موجود في كولكشن الفيربيز ولا لا
      // add user data personal to firestore
      usersRef.document(user.id).setData({
        "id": user.id,
        "userName": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
      // insert data in table users

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocuments(doc);
    print(currentUser);
    print(currentUser.displayName);
  }

  @override
  void dispose() {
    // so dont use alot of catch
    super.dispose();
    pageController.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
      // اذا تغير شي في البيج فيو روح عليه عالانديكس اللي حيتغير مثلا 3 حيصير حيروح ع 3
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(microseconds: 200), curve: Curves.bounceInOut);
  }

  Widget BuildAuthScreen() {
    // في حال تحقق تسجيل الدخول
    return Scaffold(
      body: PageView(
          children: <Widget>[
            MaterialButton(
                child: Text("logout"),
                onPressed: () {
                  logout();
                }),
            //const TimeLine(),
            ActivityFeed(),
            Upload(currentUser: currentUser),
            Search(),
            Profile(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          // for navigate between pages
          physics: NeverScrollableScrollPhysics() // no scroll in page view ...,
          ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          activeColor: Theme.of(context).primaryColor,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none)),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt)),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.person)),
          ]),
    );
  }

  Widget BuildUnAuthScreen() {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 60.0, left: 20.0, bottom: 30.0),
            alignment: Alignment.bottomLeft,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Login"),
                  Text("Welcome to Social Chat")
                ]),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                )),
            child: SingleChildScrollView(
                // عشان اذا كانت صغيرة او كبيرة ما يطلعلي مشاكل في التصميم
                child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    login();
                  },
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    margin: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    child: Text(
                      "Sign in google",
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                )
              ],
            )),
          ))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? BuildAuthScreen() : BuildUnAuthScreen();
  }
}
