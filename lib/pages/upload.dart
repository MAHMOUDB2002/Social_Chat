import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:f_finalproject/pages/home.dart';
import 'package:f_finalproject/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'package:image/image.dart' as Im;

class Upload extends StatefulWidget {
  late final User currentUser;

  Upload({required this.currentUser});

  // Upload(this.currentUser);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  late File file; // for camera and gallery
  bool isUploading = false;
  TextEditingController textPost = TextEditingController();
  TextEditingController textGeolocator = TextEditingController();
  String postId =
      Uuid().v4(); // for random number for photo to store  in storage

  handleCamera() async {
    Navigator.pop(context);
    File file = (await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960)) as File;
    setState(() {
      this.file = file;
    });
  }

  handleGallery() async {
    Navigator.pop(context);
    File file = (await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960)) as File;
    setState(() {
      this.file = file;
    });
  }

  compressImage() async {
    // عشان ياخد الصورة اللي ضفتها ويرفعها على الستورج
    //async for waiting عشان بياخد وقت لحتى يرفع محتاجها
    final tempDirection = await getTemporaryDirectory();
    // مكان مؤقت لتخزين المسار
    final path = tempDirection.path;
    Im.Image imageFile =
        Im.decodeImage(file.readAsBytesSync()); // to take file we have
    final compressImageFile = File('$path/Img $postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressImageFile;
    });
  }

  uploadImage(imageFile) async {
    // for image and where we have to put it in storage
    StorageUploadTask uploadTask =
        storageRef.child("posts_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
    // هيك عملنا رفع للصورة عالستورج
  }

  chooseImage(parrentContext) {
    return showDialog(
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: () {
                  handleCamera();
                },
              ),
              SimpleDialogOption(
                child: Text("Photo from Gallery"),
                onPressed: () {
                  handleGallery();
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
        context: parrentContext);
  }

  createPostFirestore(
      // store in firestore
      {String? mediaUrl,
      String? location,
      String? description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("usersPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": [],
    });
  }

  buildSplashScreen() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //SvgPic
          Image.asset(
            "assets/images/upload.svg",
            height: 200.0,
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Colors.orange,
              child: Text(
                "Upload Image",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: () {
                chooseImage(context);
              })
        ],
      ),
    );
  }

  handleSubmit() async {
    setState(() {
      isUploading = true; // عشان يطلع البروجرس ديالوج تبع التحميل
    });
    await compressImage(); //اضغط الصورة
    String mediaUrl =
        await uploadImage(file); // بعدها حمل الصورة عالستورج وحيرجع رابطها
    createPostFirestore(
      mediaUrl: mediaUrl,
      location: textGeolocator.text,
      description: textPost.text,
    );
    textGeolocator.clear();
    textPost.clear();
    setState(() {
      isUploading = false;
      postId = Uuid().v4();// بعطيه id  جديد
    });
  }

  buildForm() {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            onPressed: () {
              handleSubmit();
            },
            child: Text(
              "Post",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          )
        ],
        title: Text(
          "Upload Post",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          isUploading ? linerProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            //بياخدش العرض كامل بياخد من اليمين واليسار
            child: Center(
              child: AspectRatio(
                // بيعطينا حجم الصورة اللي بياخدها نسبة وتناسب وع التدوير والوضعية الطبيعية للهاتف
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file as File),
                  )),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: TextField(
              controller: textPost,
              decoration: InputDecoration(
                  hintText: "Write here post", border: InputBorder.none),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: TextField(
              controller: textGeolocator,
              decoration: InputDecoration(
                  hintText: "Where was this taken", border: InputBorder.none),
            ),
          ),
          Container(
            width: 100.0,
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(60.0),
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30.0)),
            child: ElevatedButton.icon(
                onPressed: () {
                  getUserLocation();
                },
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: Text(
                  "Use current location",
                  style: TextStyle(color: Colors.white),
                )),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0]; // first index in array
    print("placemark is $placemark");
    String fullAddress = "${placemark.locality}" + "," + "${placemark.country}";
    print("fullAddress is $fullAddress");
    textGeolocator.text = fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildForm();
  }
}
