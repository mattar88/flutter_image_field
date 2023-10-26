import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_field/image_field.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Field',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

typedef Progress = Function(double percent);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  dynamic remoteFiles;

  ///
  /// Its a simple example to lead how to implement remote upload, it not work
  /// when run example because it needs upload endpoint API
  /// and crednetials to the server, you can implement your own
  ///
  Future<dynamic> uploadToServer(XFile? file,
      {Progress? uploadProgress}) async {
    final stream = file!.openRead();
    int length = await file.length();
    final client = new HttpClient();

    final request = await client.postUrl(Uri.parse('URI'));
    request.headers.add('Content-Type', 'application/octet-stream');
    request.headers.add('Accept', '*/*');
    request.headers.add('Content-Disposition', 'file; filename="${file.name}"');
    request.headers.add('Authorization', 'Bearer ACCESS_TOKEN');
    request.contentLength = length;

    int byteCount = 0;
    double percent = 0;
    Stream<List<int>> stream2 = stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          byteCount += data.length;
          if (uploadProgress != null) {
            percent = (byteCount / length) * 100;
            uploadProgress(percent);
          }
          sink.add(data);
        },
        handleError: (error, stack, sink) {},
        handleDone: (sink) {
          sink.close();
        },
      ),
    );

    await request.addStream(stream2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Enter you name.'),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                //Local image upload
                ImageField(),

                const SizedBox(
                  height: 50,
                ),

                //Remote Image upload
                ImageField(
                    texts: const {
                      'fieldFormText': 'Upload to server',
                      'titleText': 'Upload to server'
                    },
                    files: remoteFiles != null
                        ? remoteFiles!.map((image) {
                            return ImageAndCaptionModel(
                                file: image, caption: image.alt.toString());
                          }).toList()
                        : [],
                    remoteImage: true,
                    onUpload:
                        (pickedFile, controllerLinearProgressIndicator) async {
                      dynamic fileUploaded = await uploadToServer(
                        pickedFile,
                        uploadProgress: (percent) {
                          var uploadProgressPercentage = percent / 100;
                          controllerLinearProgressIndicator!
                              .updateProgress(uploadProgressPercentage);
                        },
                      );
                      return fileUploaded;
                    },
                    onSave: (List<ImageAndCaptionModel>? imageAndCaptionList) {
                      remoteFiles = imageAndCaptionList;
                    }),
                const SizedBox(
                  height: 50,
                ),
                Center(
                    child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Submit'),
                )),
              ],
            ),
          ),
        ));
  }
}
