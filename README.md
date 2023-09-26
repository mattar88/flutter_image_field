# flutter image field
Flutter package enables users to add Image field in form with upload functionality locally or remotely.

### Screenshot
<img src="https://raw.githubusercontent.com/mattar88/flutter_image_field/master/example/screenshots/tutorial1.gif" alt="wait a moment" width="255" hspace="4">

### Features
<ul dir="auto">
<li>Best structure supports the upload to a server</li>
<li>localizations, override all texts</li>
<li>Support multiple upload</li>
<li>Manage the limit number of image uploads</li>
<li>Upload progress</li>
</ul>


## Usage
1.Install Package
With Dart:
```
$ dart pub add image_field
```
With Flutter:
```
$ flutter pub add image_field
```
This will add a line like this to you package's pubspec.yaml (and run an implicit `dart pub get`):
```
dependencies:
  image_field: ^0.0.1
```
2.Implementation
</br>Upload locally by adding ``` ImageField() ``` to a form like the following example:
```
import 'package:flutter/material.dart';
import 'package:image_field/image_field.dart';
import 'package:image_field/linear_progress_Indicator.dart';


class UploadLocalImageForm extends StatefulWidget {
  const UploadLocalImageForm({super.key, required this.title});

  final String title;

  @override
  State<UploadLocalImageForm> createState() => _UploadLocalImageFormState();
}

class _UploadLocalImageFormState extends State<UploadLocalImageForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
          key: _formKey,
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                //...
                // textfield
                // checkbox
                // datefield
                // ....

              //Local image upload
                ImageField(onSave:(List<ImageAndCaptionModel>? imageAndCaptionList) {
                    //you can save imageAndCaptionList using local storage
                    //or in a simple variable
                },),
 
                 //....
                 //Submit button
                 //....
              ],
            ),
          ),
        );
  }
}
```

</br>You can use   ``` ImageField() ```   for upload to a server by following the example below:

```

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_field/image_field.dart';
import 'package:image_field/linear_progress_Indicator.dart';
import 'package:image_picker/image_picker.dart';

typedef Progress = Function(double percent);

class UploadRemoteImageForm extends StatefulWidget {
  const UploadRemoteImageForm({super.key, required this.title});
  final String title;
  @override
  State<UploadRemoteImageForm> createState() => _UploadRemoteImageFormState();
}

class _UploadRemoteImageFormState extends State<UploadRemoteImageForm> {
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  dynamic remoteFiles;

 
  Future<dynamic> uploadToServer(XFile? file,
      {Progress? uploadProgress}) async {
    //implement your code using Rest API or other technology
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
          key: _formKey,
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                //Remote Image upload
                ImageField(
                    texts: const {
                      'fieldFormText': 'Upload to server',
                      'titleText': 'Upload to server'
                    },
                    defaultFiles: remoteFiles != null
                        ? remoteFiles!.map((image) {
                            return ImageAndCaptionModel(
                                file: image, caption: image.alt.toString());
                          }).toList()
                        : [],
                    remoteImage: true,
                    onUpload: (dynamic pickedFile,
                        ControllerLinearProgressIndicator?
                            controllerLinearProgressIndicator) async {
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
      
              ],
            ),
     
        ));
  }
}

```
