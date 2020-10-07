import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
// import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class TfLiteHome extends StatefulWidget {
  @override
  _TfLiteHomeState createState() => _TfLiteHomeState();
}

class _TfLiteHomeState extends State<TfLiteHome> {
  String _model = yolo;
  File _img;
  double _imgw;
  double _imgh;
  bool _busy = false;
  List _recognitions;

  @override
  void initState() {
    super.initState();
    _busy = true;
    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  loadModel() async {
    Tflite.close();
    try {
      String res;
      if (_model == yolo) {
        res = await Tflite.loadModel(
          model: "assets/tflite/yolov2_tiny.tflite",
          labels: "assets/tflite/yolov2_tiny.txt",
        );
      } else {
        res = await Tflite.loadModel(
          model: "assets/tflite/ssd_mobilenet.tflite",
          labels: "assets/tflitessd_mobilenet.txt",
        );
      }
      print(res);
    } on PlatformException {
      // Text("Size too large!!");

      // Navigator.pop(context);
      print("Failed!");
    }
  }

  ///upto 37 minutes

  selectImage() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(img);
  }

  predictImage(File img) async {
    if (img == null) return;
    if (_model == yolo) {
      await yolov2Tiny(img);
    } else {
      await ssdMobileNet(img);
    }

    FileImage(img)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imgw = info.image.width.toDouble();
            _imgh = info.image.height.toDouble();
          });
        })));

    setState(() {
      _img = img;
      _busy = false;
    });
  }

  yolov2Tiny(File img) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: img.path,
      model: "YOLO",
      threshold: 0.3,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  ssdMobileNet(File img) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: img.path,
      numResultsPerClass: 1,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imgh == null || _imgw == null) return [];

    double factorX = screen.width;
    double factorY = _imgh / _imgh + screen.width;
    Color col = Colors.redAccent;
    return _recognitions.map((re) {
      return Positioned(
          left: re["rect"]["x"] * factorX,
          top: re["rect"]["y"] * factorY,
          width: re["rect"]["w"] * factorX,
          height: re["rect"]["w"] * factorY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: col,
                width: 3,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidencenClass"] * 100).toStringAsFixed(0)}",
              style: TextStyle(
                background: Paint()..color = col,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackchildren = [];
    stackchildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _img == null ? Text("Please Select an Image") : Image.file(_img),
    ));

    stackchildren.addAll(renderBoxes(size));

    return Scaffold(
      appBar: AppBar(
        title: Text("Object Detector"),
      ),
      drawer: Drawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.image),
        tooltip: "Pick Image from Gallery",
        onPressed: selectImage,
      ),
      body: Stack(
        children: stackchildren,
      ),
    );
  }
}
