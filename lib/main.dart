
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainBody(),
    );
  }
}


class MainBody extends StatefulWidget {
  const MainBody({Key? key}) : super(key: key);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
   File? image ;
   final imagepicker = ImagePicker();
   final firestor = FirebaseFirestore.instance;
   final storag = FirebaseStorage.instance;
   bool progress = false ;

  @override

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print('Height ${size.height}');
    print('Width ${size.width}');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Image Upload (Hamza javaid)',
        ),
      ),
      body: ModalProgressHUD(
        blur: 7,
        inAsyncCall: progress,
        child: Column(
          children: [
            SizedBox(height: 10,),
            Expanded(child: Container(

              width: double.infinity,

              child: Center(
                child:image!=null ? Image.file(image!,fit: BoxFit.cover,) : Icon(
                  Icons.add_a_photo,
                  color: Colors.black,
                  size: 50,
                ),
              ),


            )),
            SizedBox(height: 10,),
            Expanded(child: Container(
              width: size.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                            child: InkWell(
                              onTap: () async {
                                final pick = await imagepicker.pickImage(source: ImageSource.gallery);
                                setState(() {
                                  image = File(pick!.path);
                                });
                              },
                              child: Container(

                                decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.all(Radius.circular(13))
                                ),
                                width: size.height/15,
                                height: size.height/12,
                                child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Center(child: Icon(Icons.image),),
                                        Text('Browse Gallery',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20
                                          ),
                                        )
                                      ],
                                    )
                                ),

                              ),
                            )

                        ),),
                        Expanded(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                          child: InkWell(
                              onTap: ()async{
                                final pick = await imagepicker.pickImage(source: ImageSource.camera);
                                setState(() {
                                  image = File(pick!.path);
                                });
                              },
                              child:Container(

                                decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.all(Radius.circular(13))
                                ),

                                width: size.height/15,
                                height: size.height/12,
                                child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                         Icon(Icons.camera_alt),
                                        Text('Capture Image',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17
                                          ),
                                        )
                                      ],
                                    )
                                ),

                              )),

                        ),),
                      ],
                    ),
                    image!=null ? Lottie.asset(
                      'assets/success.json',
                      repeat: true,
                      height: size.height/6,
                    ) :  Lottie.asset(
                      'assets/searching.json',
                      repeat: true,
                      height: size.height/6,
                    )





                  ]
              ),
            )),
            Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10
                ),
                child: InkWell(
                  onTap: ()async {

                    setState(() {
                      progress= true;
                    });
                    // final path = await storag.ref('/Upload Image/${DateTime.now().millisecondsSinceEpoch}');
                    final path = await storag.ref().child('UploadImage').child(DateTime.now().millisecondsSinceEpoch.toString());
                    UploadTask upload_image =    path.putFile(image!.absolute);

                    print('Getting Link');
                    Future.value(upload_image).then((value)async{
                      var piclink = await path.getDownloadURL();
                      print('Link is '+piclink);

                      await   firestor.collection('UploadImage').doc(DateTime.now().millisecondsSinceEpoch.toString()).set(
                          {
                            'Type' : "Image",
                            'Link' : piclink,

                          });
                      var length1 =    firestor.collection('UploadImage');
                      var length2 = await length1.count().get();
                      var length_origin = length2.count;
                      print("Length is ${length_origin}");
                      setState(() {
                        progress = false;
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> imageshow(piclink,length_origin)));

                    });

                  },

                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                      borderRadius: BorderRadius.all(Radius.circular(18))
                    ),

                    width: size.width/1.1,
                      height: size.height/12,
                    child: Center(
                      child: Text(
                          'Upload Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),

                      ),
                    ),

                  ),
                )

            ),


          ],
        ),
      )
    );
  }
}


class imageshow extends StatefulWidget {
  String lnk ;
  var length;

   imageshow( this.lnk,this.length);
  @override
  _imageshowState createState() => _imageshowState();
}

class _imageshowState extends State<imageshow> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('All Pics'),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);

        },
        child: Icon(Icons.upload_outlined),

      ),
      body: ListView.builder(
          itemCount: 1,
          itemBuilder: (context,index){
            return Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),child: Container(

              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage('${widget.lnk}'),
                      fit: BoxFit.contain
                  )
              ),


              width: double.infinity,
              height: size.height/2,
              child: Center(

              ),


            ),);
          }),
    );
  }
}
