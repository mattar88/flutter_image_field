import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skeletons/skeletons.dart';
import 'package:image_field/linear_progress_indicator.dart' as lpi;

class ImageField extends StatefulWidget {
  const ImageField(
      {super.key,
      this.files,
      this.remoteImage = false,
      this.texts,
      this.thumbnailCount = 3,
      this.width,
      this.height = 90,
      this.thumbnailHeight = 90,
      this.thumbnailWidth = 90,
      this.thumbnailAddMoreDecoration,
      this.listPadding = const EdgeInsets.all(2),
      this.label,
      this.pickerIconColor,
      this.pickerBackgroundColor,
      this.scrollingAfterUpload = true,
      this.multipleUpload = true,
      this.cardinality,
      this.onSave,
      this.onUpload,
      this.alterFieldForm})
      : assert(
          (remoteImage == true && onUpload != null) || (remoteImage == false),
          'You should implement onUpload() function when remoteImage argument is true',
        );

  ///
  /// [files] used to add default images on load
  ///
  final List<ImageAndCaptionModel>? files;

  /// label of field
  final Widget? label;

  /// Number of images shown in the field
  final int thumbnailCount;

  /// Width of the small image shown in the field
  final double thumbnailWidth;

  /// Height of the small image shown in the field
  final double thumbnailHeight;

  /// Uses for styling the button add more on thumbnail list
  final BoxDecoration? thumbnailAddMoreDecoration;

  ///Width of the image in the listview
  final double? width;

  /// Height of the image in the listview
  final double height;

  ///Enable user to pick multiple files
  final bool multipleUpload;

  ///Enable user to scroll listview to the end to see uploaded file
  final bool scrollingAfterUpload;

  ///Maximum number of files that can be uploaded.
  final int? cardinality;

  /// Padding of the listview page of files
  final EdgeInsets listPadding;

  /// Icon color of the buttons that used to upload files
  /// that exist in the listview page
  final Color? pickerIconColor;

  /// Background color of the buttons that used to upload files
  /// that exist in the listview page
  final Color? pickerBackgroundColor;

  ///Used for remote upload image
  ///Note: if True should implement onUpload function
  final bool remoteImage;

  ///[texts] key/value variable used for localizations and to override
  ///the defaults texts used by the ImageFieldText.
  final Map<String, String>? texts;

  ///
  ///This function has [dataSource] image that uploaded by user
  ///to send them to the server and [controllerLinearProgressIndicator] used as
  ///reference variable to indicate the uploading progress to the server and
  ///return the result to store it in the [fileList] that used in the field.
  ///
  ///Note: this function can used as hook to alter the [dataSource] not
  ///necessarily for remote upload
  ///
  final dynamic Function(
      dynamic dataSource,
      lpi.ControllerLinearProgressIndicator?
          controllerLinearProgressIndicator)? onUpload;

  /// It's a hook function used to alter the widget of the field(Thumbnail List)
  /// in the form before rendering it
  final Widget Function(
          List<ImageAndCaptionModel>? defaultFiles, Widget fieldForm)?
      alterFieldForm;

  ///Used to update the form with the uploaded files, it called
  ///when back from the listview
  final void Function(List<ImageAndCaptionModel>? imageAndCaptionList)? onSave;

  @override
  State<ImageField> createState() => _ImageFieldState();
}

final Map<String, String> defaultTexts = {
  'title': 'Upload Image',
  'imagePickerFromGalleryTooltipText': 'Pick Image from gallery',
  'multipleImagePickerFromGalleryTooltipText':
      'Pick Multiple Image from gallery',
  'takePhotoText': 'Take a photo',
  'addCaptionText': 'Add a caption...',
  'doneText': 'Done',
  'titleText': 'Upload',
  'fieldFormText': 'Upload',
  'emptyDataText': 'Empty data',
};

class _ImageFieldState extends State<ImageField> {
  Map<String, String>? texts;
  List<ImageAndCaptionModel>? files;
  @override
  void initState() {
    files = widget.files ?? [];

    texts = widget.texts != null
        ? {...defaultTexts, ...?widget.texts}
        : defaultTexts;

    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getText(String key) {
    return texts![key] ?? '';
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _gotoImageList() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageListActions(
              pickerIconColor: widget.pickerIconColor,
              pickerBackgroundColor: widget.pickerBackgroundColor,
              listPadding: widget.listPadding,
              fileList: files!,
              onSave: widget.onSave,
              onUpload: widget.onUpload,
              scrollingAfterUpload: widget.scrollingAfterUpload,
              multipleUpload: widget.multipleUpload,
              getText: getText,
              remoteImage: widget.remoteImage,
              cardinality: widget.cardinality,
              refresh: refresh)),
    );
  }

  Widget _previewImages() {
    var placeholderImage = Semantics(
        label: 'image_placeholder',
        child: const SkeletonAvatar(
            style: SkeletonAvatarStyle(
          shape: BoxShape.rectangle,
        )));

    List<Widget> field = [];
    int isMore = 0;
    bool cardinalityExceeded =
        (widget.cardinality != null && widget.cardinality! <= files!.length);

    Color? addMoreIconColor = Theme.of(context).colorScheme.primaryContainer;

    Color? addMoreBackgroundColor =
        Theme.of(context).colorScheme.onPrimaryContainer;

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) widget.label!,
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            var width = widget.width;
            width ??= constraints.constrainWidth();
            int screenMaxCount = (width / widget.thumbnailWidth).floor();

            List<Widget> listFiles = [];
            for (int i = 0; i < files!.length; i++) {
              bool isLast = i == files!.length - 1;
              isMore =
                  i == screenMaxCount - 1 && files!.length >= screenMaxCount
                      ? files!.length - screenMaxCount
                      : -1;
              var img = Semantics(
                  label: 'image_picker_example_picked_image',
                  child: widget.remoteImage
                      ? CachedNetworkImage(
                          height: widget.thumbnailHeight,
                          width: widget.thumbnailWidth,
                          imageUrl: files![i].file.uri.toString(),
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) {
                            return placeholderImage;
                          },
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image(
                          height: widget.thumbnailHeight,
                          width: widget.thumbnailWidth,
                          fit: BoxFit.cover,
                          frameBuilder:
                              ((context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) return child;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: frame != null ? child : placeholderImage,
                            );
                          }),
                          image: MemoryImage(
                            files![i].file,
                          )));

              if (isMore != -1) {
                listFiles.add(Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    img,
                    Container(
                      height: widget.thumbnailHeight,
                      width: widget.thumbnailWidth,
                      color: addMoreBackgroundColor.withOpacity(0.6),
                      child: (isMore != 0)
                          ? Center(
                              child: Text(
                              '+$isMore',
                              style: TextStyle(
                                  color: addMoreIconColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.normal),
                            ))
                          : Icon(
                              color: addMoreIconColor,
                              Icons.add,
                              size: 40,
                            ),
                    ),
                  ],
                ));
                break;
              } else {
                listFiles.add(img);
                if (isLast && !cardinalityExceeded) {
                  listFiles.add(SizedBox(
                      height: widget.thumbnailHeight,
                      width: widget.thumbnailWidth,
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2))),
                          ),
                          onPressed: _gotoImageList,
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: addMoreIconColor,
                          ))));
                }
              }
            }

            Widget fieldForm = (files == null || files!.isEmpty)
                ? SizedBox(
                    width: constraints.constrainWidth(),
                    child: ElevatedButton.icon(
                      onPressed: _gotoImageList,
                      icon: const Icon(Icons.upload),
                      label: Text(getText('fieldFormText')),
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)))),
                    ),
                  )
                : GestureDetector(
                    onTap: _gotoImageList,
                    child: SizedBox(
                        // padding: EdgeInsets.all(5),
                        width: constraints.constrainWidth(),
                        height: widget.height,
                        child: Row(children: listFiles)));

            if (widget.alterFieldForm != null) {
              fieldForm = widget.alterFieldForm!(files, fieldForm);
            }

            field.add(Semantics(
                label: 'image_picker_picked_images', child: fieldForm));

            return Row(children: field);
          })),
        ]);
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  @override
  Widget build(BuildContext context) {
    return _handlePreview();
  }
}

class ImageAndCaptionModel {
  dynamic file;
  String caption;
  ImageAndCaptionModel({required this.file, required this.caption});
}

class ImageAndCaptionListWidget extends StatefulWidget {
  final List<ImageAndCaptionModel>? fileList;
  final String Function(String) getText;
  final bool remoteImage;
  final bool scrollingAfterUpload;
  final void Function() notifyParent;
  final EdgeInsets listPadding;

  const ImageAndCaptionListWidget(
    this.fileList,
    this.getText, {
    this.listPadding = const EdgeInsets.all(0),
    required this.notifyParent,
    required this.scrollingAfterUpload,
    this.remoteImage = false,
    super.key,
  });

  @override
  State<ImageAndCaptionListWidget> createState() =>
      _ImageAndCaptionListWidgetState();
}

class _ImageAndCaptionListWidgetState extends State<ImageAndCaptionListWidget> {
  bool newItemAdd = false;
  lpi.ControllerLinearProgressIndicator? controllerLinearProgressIndicator;

  final GlobalKey<FormState> imageFieldTextFormKey =
      GlobalKey<FormState>(debugLabel: '__ImageFieldText__');

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  int listLength = 0;

  @override
  void initState() {
    listLength = widget.fileList!.length;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ImageAndCaptionListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listLength < oldWidget.fileList!.length) {
      newItemAdd = true;
      _scrollAfterUpload();
    }
    listLength = widget.fileList!.length;
  }

  void _scrollAfterUpload({bool reset = false}) {
    if (widget.scrollingAfterUpload) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (newItemAdd) {
          itemScrollController.scrollTo(
              index: widget.fileList!.length - 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic);

          if (reset) newItemAdd = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (widget.fileList!.isEmpty) {
      return Expanded(
          child: Center(
              child: Text(
        widget.getText('emptyDataText'),
        textAlign: TextAlign.center,
      )));
    }

    List<Widget> imgs = [];

    Widget? placeholderImage = Semantics(
        label: 'image_placeholder',
        child: SkeletonAvatar(
            style: SkeletonAvatarStyle(
                shape: BoxShape.rectangle,
                height: screenWidth * 0.7,
                width: screenWidth)));

    for (var imageAndCaption in widget.fileList!) {
      imgs.insert(
          imgs.length,
          Column(
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Semantics(
                      label: 'image_picker',
                      child: SizedBox(
                          width: screenWidth,
                          // height: 100,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              widget.remoteImage
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          imageAndCaption.file.uri.toString(),
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) {
                                        _scrollAfterUpload(reset: true);

                                        return placeholderImage;
                                      },
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : Image(
                                      frameBuilder: ((context, child, frame,
                                          wasSynchronouslyLoaded) {
                                        if (wasSynchronouslyLoaded) {
                                          return child;
                                        }

                                        _scrollAfterUpload();
                                        return AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: frame != null
                                              ? child
                                              : placeholderImage,
                                        );
                                      }),
                                      image: MemoryImage(
                                        imageAndCaption.file,
                                      )),
                              Container(
                                  margin: const EdgeInsets.all(5),
                                  child: InkWell(
                                      onTap: () {
                                        widget.fileList!.removeWhere((item) =>
                                            item.hashCode ==
                                            imageAndCaption.hashCode);
                                        widget.notifyParent();
                                      },
                                      child: const Icon(
                                        Icons.cancel,
                                      )))
                            ],
                          )))),
              TextField(
                onChanged: (value) {
                  imageAndCaption.caption = value;
                },
                controller:
                    TextEditingController(text: imageAndCaption.caption),
                key: UniqueKey(),

                textAlign: TextAlign.start,
                decoration:
                    InputDecoration(hintText: widget.getText('addCaptionText')),

                // controller: _controllers[imageAndCaption.hashCode],
                // autofocus: false,
                keyboardType: TextInputType.text,
              )
            ],
          ));
    }

    return Form(
        key: imageFieldTextFormKey,
        child: Expanded(
            child: ScrollablePositionedList.builder(
                padding: widget.listPadding,
                // cacheExtent: 9999,
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                // controller: _scrollController,
                // key: UniqueKey(),
                itemScrollController: itemScrollController,
                scrollOffsetController: scrollOffsetController,
                itemPositionsListener: itemPositionsListener,
                scrollOffsetListener: scrollOffsetListener,
                itemCount: imgs.length,
                itemBuilder: (BuildContext context, int index) {
                  return imgs[index];
                })));
  }
}

class ImageListActions extends StatefulWidget {
  const ImageListActions(
      {super.key,
      this.title,
      this.remoteImage = true,
      this.multipleUpload = true,
      this.pickerIconColor,
      this.pickerBackgroundColor,
      this.cardinality,
      this.listPadding = const EdgeInsets.all(0),
      required this.scrollingAfterUpload,
      this.onSave,
      required this.onUpload,
      required this.getText,
      required this.refresh,
      required this.fileList});

  final Color? pickerIconColor;
  final Color? pickerBackgroundColor;
  final EdgeInsets listPadding;
  final bool remoteImage;
  final bool multipleUpload;
  final int? cardinality;
  final bool scrollingAfterUpload;
  final List<ImageAndCaptionModel> fileList;
  final ValueChanged<List<ImageAndCaptionModel>?>? onSave;
  final void Function() refresh;
  final dynamic Function(
      dynamic dataSource,
      lpi.ControllerLinearProgressIndicator?
          controllerLinearProgressIndicator)? onUpload;
  final String Function(String) getText;
  final String? title;

  @override
  State<ImageListActions> createState() => _ImageListActionsState();
}

class _ImageListActionsState extends State<ImageListActions> {
  bool isLoading = false;
  //Used to stop scrolling down for first page load
  bool pickedFiles = false;
  Uint8List? localFileUploaded;
  double uploadProgressPercentage = 0;

  lpi.ControllerLinearProgressIndicator? controllerLinearProgressIndicator;

  @override
  void initState() {
    controllerLinearProgressIndicator = lpi.ControllerLinearProgressIndicator();
    super.initState();
  }

  @override
  void dispose() {
    controllerLinearProgressIndicator = null;

    super.dispose();
  }

  void _setFileListFromfileListUploaded(dynamic fileListUploaded) {
    pickedFiles = true;
    fileListUploaded.forEach((fileUploaded) {
      widget.fileList
          .add(ImageAndCaptionModel(file: fileUploaded, caption: ''));
    });
  }

  void _setFileListFromFileUploaded(dynamic value) {
    pickedFiles = true;
    try {
      widget.fileList.add(ImageAndCaptionModel(file: value, caption: ''));
    } catch (e) {
      throw Exception(
          'An error occurred when trying to upload files ${e.toString()}');
    }
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> _onImageButtonPressed(ImageSource source,
      {required BuildContext context, bool isMultiImage = false}) async {
    if (context.mounted) {
      if (isMultiImage) {
        try {
          final List<XFile> pickedFileList = await _picker.pickMultiImage(
              // maxWidth: maxWidth,
              // maxHeight: maxHeight,
              // imageQuality: quality,
              );

          if (pickedFileList.isNotEmpty) {
            try {
              setState(() {
                isLoading = true;
                // isLocalLoading = true;
              });
              List<dynamic> fileListUploaded = [];

              if (widget.remoteImage) {
                if (widget.onUpload != null) {
                  fileListUploaded = await widget.onUpload!(
                      pickedFileList, controllerLinearProgressIndicator);
                }
              } else {
                for (int i = 0; i < pickedFileList.length; i++) {
                  final bytes = await pickedFileList[i].readAsBytes();
                  fileListUploaded.add(Uint8List.fromList(bytes));
                }

                if (widget.onUpload != null) {
                  var returnedFileUploaded = await widget.onUpload!(
                      pickedFileList, controllerLinearProgressIndicator);

                  if (returnedFileUploaded != null &&
                      returnedFileUploaded != false) {
                    fileListUploaded = returnedFileUploaded;
                  }
                }
              }

              setState(() {
                _setFileListFromfileListUploaded(fileListUploaded);

                uploadProgressPercentage = 0;
                isLoading = false;
              });
            } catch (e) {
              throw Exception(e.toString());
            } finally {}
          }
        } catch (e) {
          throw Exception(e.toString());
        }
      } else {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
          );
          if (pickedFile != null) {
            try {
              setState(() {
                isLoading = true;
              });
              dynamic fileUploaded;

              if (widget.remoteImage) {
                if (widget.onUpload != null) {
                  fileUploaded = await widget.onUpload!(
                      pickedFile, controllerLinearProgressIndicator);
                }
              } else {
                final bytes = await pickedFile.readAsBytes();
                fileUploaded = Uint8List.fromList(bytes);

                if (widget.onUpload != null) {
                  var returnedFileUploaded = await widget.onUpload!(
                      pickedFile, controllerLinearProgressIndicator);

                  if (returnedFileUploaded != null &&
                      returnedFileUploaded != false) {
                    fileUploaded = returnedFileUploaded;
                  }
                }
              }

              setState(() {
                _setFileListFromFileUploaded(fileUploaded);

                uploadProgressPercentage = 0;
                isLoading = false;
              });
            } catch (e) {
              throw Exception(e.toString());
            } finally {}
          }
        } catch (e) {
          throw Exception(e.toString());
        }
      }
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Widget linearProgressIndicatorWidget() {
    return isLoading
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: lpi.LinearProgressIndicator(
                width: double.infinity,
                controllerLinearProgressIndicator:
                    controllerLinearProgressIndicator))
        : const SizedBox.shrink();
  }

  Widget headerWidget() {
    bool cardinalityExceeded = (widget.cardinality != null &&
        widget.cardinality! <= widget.fileList.length);

    Color? pickerBackgroundColor = widget.pickerBackgroundColor ??
        Theme.of(context).colorScheme.primaryContainer;

    var bgColor = isLoading || cardinalityExceeded
        ? pickerBackgroundColor.withOpacity(0.5)
        : pickerBackgroundColor;

    Color? iconColor = widget.pickerIconColor ??
        Theme.of(context).colorScheme.onPrimaryContainer;
    Color? pickerIconColor = isLoading || cardinalityExceeded
        ? iconColor.withOpacity(0.5)
        : iconColor;

    // pickerIconColor = null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Semantics(
            label: 'image_picker_from_gallery',
            child: FloatingActionButton(
              backgroundColor: bgColor,
              onPressed: isLoading || cardinalityExceeded
                  ? null
                  : () {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context);
                    },
              heroTag: 'image0',
              tooltip: widget.getText('imagePickerFromGalleryTooltipText'),
              child: Icon(
                Icons.photo,
                color: pickerIconColor,
              ),
            ),
          ),
          if (widget.multipleUpload)
            Semantics(
              label: widget.getText('imagePickerFromGalleryTooltipText'),
              child: FloatingActionButton(
                backgroundColor: bgColor,
                onPressed: isLoading || cardinalityExceeded
                    ? null
                    : () {
                        _onImageButtonPressed(
                          ImageSource.gallery,
                          context: context,
                          isMultiImage: true,
                        );
                      },
                heroTag: 'image1',
                tooltip:
                    widget.getText('multipleImagePickerFromGalleryTooltipText'),
                child: Icon(
                  Icons.photo_library,
                  color: pickerIconColor,
                ),
              ),
            ),
          Semantics(
            label: 'take_photo',
            child: FloatingActionButton(
              backgroundColor: bgColor,
              onPressed: isLoading || cardinalityExceeded
                  ? null
                  : () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                    },
              heroTag: 'image2',
              tooltip: widget.getText('takePhotoText'),
              child: Icon(Icons.camera_alt, color: pickerIconColor),
            ),
          ),
        ],
      ),
    );
  }

  void notifyParent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (widget.onSave != null) {
            widget.onSave!(widget.fileList);
          }
          widget.refresh();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.getText('titleText')),
            actions: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.transparent;
                          }
                          return Colors
                              .transparent; // Use the component's default.
                        },
                      ),
                    ),

                    // ElevatedButton.styleFrom(
                    //   elevation: 0,
                    //   side:
                    //       const BorderSide(width: 0, color: Colors.transparent),
                    // ),
                    onPressed: () {
                      if (widget.onSave != null) {
                        widget.onSave!(widget.fileList);
                      }
                      widget.refresh();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      widget.getText('doneText'),
                      // style: TextStyle(color: ),
                    ),
                  ))
            ],
          ),
          body: Column(
            children: [
              headerWidget(),
              linearProgressIndicatorWidget(),
              ImageAndCaptionListWidget(
                listPadding: widget.listPadding,
                widget.fileList,
                widget.getText,
                notifyParent: notifyParent,
                remoteImage: widget.remoteImage,
                scrollingAfterUpload: widget.scrollingAfterUpload,
              )
            ],
          ),
        ));
  }
}
