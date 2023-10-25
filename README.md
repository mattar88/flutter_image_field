# flutter image field
Flutter package enables users to upload and manage images by adding image field to a form,
in addition to strong functionality to adapt images before uploading to the server and alter 
the widget before rendering it and a lot of other features.

### Screenshot
<img src="https://raw.githubusercontent.com/mattar88/flutter_image_field/master/example/screenshots/tutorial1.gif" alt="wait a moment" width="255" hspace="4">

### Features
<ul dir="auto">
<li>Best structure supports the upload to a server</li>
<li>localizations, override all texts</li>
<li>Support multiple upload</li>
<li>You can specify the limited number of image uploads</li>
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
 
2.Implementation
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

</br>Simple locally upload by adding ``` ImageField() ``` to a form like the following example:
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

### Main Parameters

| Parameter       | Type    | Description                                                                                                                                        |
|-----------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `defaultFiles`    | List<ImageAndCaptionModel> |Used to add default images on load                                             |  
| `remoteImage`   | Widget  |  Used for remote upload image, if True should implement onUpload() function   |
| `texts`   |   Map<String, String>  | key/value variable used for localizations or to override the defaults texts used by the Imagefield.      |
| `multipleUpload`    | bool  | Enable user to pick multiple files.         |
| `cardinality`            | int  |  Maximum number of files that can be uploaded.    

### Main Functions

| Function       | Parameter    | Description                                                                                                                                        |
|-----------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `onUpload`    | dynamic Function(dynamic, ControllerLinearProgressIndicator?)? | This function has [dataSource] image that uploaded by a user to send them to the server and [controllerLinearProgressIndicator] used as a reference variable to indicate the uploading progress to the server and return the result to store it in the [fileList] that used in the field.                                             |  
| `onSave`   | void Function(List<ImageAndCaptionModel>?)?  |  Used to update the form with the uploaded files, it called when back from the listview  |
| `alterFieldForm`   |   Widget Function(List<ImageAndCaptionModel>?, Widget)?  | It's a hook function used to alter the widget of the field(Thumbnail List) in the form before rendering it      |

 ## License

This package is licensed under the [MIT License](https://github.com/mattar88/flutter_image_field/blob/main/LICENSE)


