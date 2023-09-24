import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skeletons/skeletons.dart';
import 'package:image_field/linear_progress_Indicator.dart' as LPI;

class ImageField extends StatefulWidget {
  static final Map<String, String> _defaultTexts = {
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

  ImageField(
      {super.key,
      this.defaultFiles,
      this.remoteImage = false,
      this.texts,
      this.thumbnailCount = 3,
      this.width,
      this.height = 75,
      this.thumbnailHeight = 75,
      this.thumbnailWidth = 75,
      this.listPadding = const EdgeInsets.all(2),
      this.label = const Padding(
        child: Icon(Icons.image),
        padding: EdgeInsets.only(right: 10),
      ),
      this.pickerIconColor,
      this.scrollingAfterUpload = true,
      this.multipleUpload = true,
      this.cardinality,
      this.onSave,
      this.onUpload,
      this.alterFieldForm})
      : assert(
          (remoteImage == true && onUpload != null) || (remoteImage == false),
          'You should implement onUpload() function when remoteImage argument is true',
        ) {
    defaultFiles = defaultFiles ?? [];
    texts = {..._defaultTexts, ...?texts};
  }

  ///
  /// [defaultFiles] used to add default images on load
  ///
  List<ImageAndCaptionModel>? defaultFiles;

  /// label of field
  Widget? label;

  /// Number of images shown in the field
  int thumbnailCount;

  /// Width of the small image shown in the field
  double thumbnailWidth;

  /// Height of the small image shown in the field
  double thumbnailHeight;

  ///Width of the image in the listview
  double? width;

  /// Height of the image in the listview
  double height;

  ///Enable user to pick multiple file
  bool multipleUpload;

  ///Enable user to scroll listview to the end to see uploaded file
  bool scrollingAfterUpload;

  ///Number of the files can upload
  int? cardinality;

  /// Padding of the listview page of files
  EdgeInsets listPadding;

  /// Icon color of the buttons that used to upload files
  /// that exist in the listview page
  Color? pickerIconColor;

  ///Used for remote upload image
  ///Note: if True should implement onUpload function
  bool remoteImage;

  ///[texts] key/value variable used for localizations or to override
  ///the defaults texts used by the Imagefield.
  Map<String, String>? texts;

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
      LPI.ControllerLinearProgressIndicator?
          controllerLinearProgressIndicator)? onUpload;

  /// Its a hook function used to alter the widget of the field(Thumbnail List)
  /// in the form before render it
  final Widget Function(
          List<ImageAndCaptionModel>? defaultFiles, Widget fieldForm)?
      alterFieldForm;

  ///Used to update the form with the uploaded files, it called
  ///when back from the listview
  final void Function(List<ImageAndCaptionModel>? imageAndCaptionList)? onSave;

  @override
  State<ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField> {
  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getText(String key) {
    return widget.texts![key] ?? '';
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
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
    bool cardinalityExceeded = (widget.cardinality != null &&
        widget.cardinality! <= widget.defaultFiles!.length);

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) widget.label!,
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            var width = widget.width;
            width ??= constraints.constrainWidth();
            int screenMaxCount = (width / widget.thumbnailWidth).floor();

            var index = 0;
            List<Widget> listFiles = [];
            for (int i = 0; i < widget.defaultFiles!.length; i++) {
              bool isLast = i == widget.defaultFiles!.length - 1;
              isMore = i == screenMaxCount - 1 &&
                      widget.defaultFiles!.length >= screenMaxCount
                  ? widget.defaultFiles!.length - screenMaxCount
                  : -1;
              var img = Semantics(
                  label: 'image_picker_example_picked_image',
                  child: widget.remoteImage
                      ? CachedNetworkImage(
                          height: widget.thumbnailHeight,
                          width: widget.thumbnailWidth,
                          imageUrl: widget.defaultFiles![i].file.uri.toString(),
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) {
                            return placeholderImage;
                          },
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
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
                            widget.defaultFiles![i].file,
                          )));

              if (isMore != -1) {
                listFiles.add(Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    img,
                    Row(children: [
                      const Icon(
                        Icons.add_box_rounded,
                        size: 30,
                      ),
                      if (isMore != 0)
                        Text(
                          '${isMore}',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        )
                    ]),
                  ],
                ));
                break;
              } else {
                listFiles.add(img);
                if (isLast && !cardinalityExceeded) {
                  listFiles.add(Container(
                    height: widget.thumbnailHeight,
                    width: widget.thumbnailWidth,

                    // margin: const EdgeInsets.all(15.0),
                    // padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                    child: Icon(
                      Icons.add_box_rounded,
                      size: 50,
                    ),
                  ));
                }
              }
            }

            Widget fieldForm = (widget.defaultFiles == null ||
                    widget.defaultFiles!.isEmpty)
                ? Container(
                    width: constraints.constrainWidth(),

                    // margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload),
                          Text(getText('fieldFormText'))
                        ]),
                  )
                : Container(
                    // padding: EdgeInsets.all(5),
                    width: constraints.constrainWidth(),
                    height: widget.height,
                    // decoration: BoxDecoration(
                    //   border: Border.all(),
                    // ),
                    child: Row(children: listFiles)

                    //  ListView.builder(
                    //     scrollDirection: Axis.horizontal,
                    //     shrinkWrap: true,
                    //     key: UniqueKey(),
                    //     itemCount: widget.defaultFiles!.length,
                    //     itemBuilder: (BuildContext context, int index) {})
                    );

            if (widget.alterFieldForm != null) {
              fieldForm =
                  widget.alterFieldForm!(widget.defaultFiles, fieldForm);
            }

            field.add(Semantics(
                label: 'image_picker_picked_images',
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageListActions(
                                pickerIconColor: widget.pickerIconColor,
                                listPadding: widget.listPadding,
                                fileList: widget.defaultFiles ?? [],
                                onSave: widget.onSave,
                                onUpload: widget.onUpload,
                                scrollingAfterUpload:
                                    widget.scrollingAfterUpload,
                                multipleUpload: widget.multipleUpload,
                                getText: getText,
                                remoteImage: widget.remoteImage,
                                cardinality: widget.cardinality,
                                refresh: refresh)),
                      );
                    },
                    child: fieldForm)));

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
  List<ImageAndCaptionModel>? fileList = [];
  final String Function(String) getText;
  bool remoteImage;
  bool scrollingAfterUpload;
  final void Function() notifyParent;
  EdgeInsets listPadding;
  ImageAndCaptionListWidget(
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
  LPI.ControllerLinearProgressIndicator? controllerLinearProgressIndicator;

  final GlobalKey<FormState> imageFieldFormKey =
      GlobalKey<FormState>(debugLabel: '__imageField__');
  ScrollController _scrollController = new ScrollController();
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
      log('Enter new item ');
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
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic);

          if (reset) newItemAdd = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    log('Lengthhhhh...${widget.fileList!.length}');
    if (widget.fileList!.isEmpty) {
      return Center(
          child: Text(
        widget.getText('emptyDataText'),
        textAlign: TextAlign.center,
      ));
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
      // _controllers.addAll({imageAndCaption.hashCode: TextEditingController()});
      imgs.insert(
          imgs.length,
          Column(
            children: [
              Container(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
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
                                          // log('maxscrolling: ${_scrollController}');
                                          // log('Progress bar.....');
                                          _scrollAfterUpload(reset: true);

                                          return placeholderImage;
                                        },
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )
                                    : Image(
                                        frameBuilder: ((context, child, frame,
                                            wasSynchronouslyLoaded) {
                                          if (wasSynchronouslyLoaded)
                                            return child;

                                          _scrollAfterUpload();
                                          return AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
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
              ),
              Container(
                child: TextField(
                  onChanged: (value) {
                    imageAndCaption.caption = value;
                  },
                  controller:
                      TextEditingController(text: imageAndCaption.caption),
                  key: UniqueKey(),

                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                      hintText: widget.getText('addCaptionText')),

                  // controller: _controllers[imageAndCaption.hashCode],
                  // autofocus: false,
                  keyboardType: TextInputType.text,
                ),
              )
            ],
          ));
    }

    return Form(
        key: imageFieldFormKey,
        child: Expanded(
            child: ScrollablePositionedList.builder(
                padding: widget.listPadding,
                // cacheExtent: 9999,
                scrollDirection: Axis.vertical,
                physics: ScrollPhysics(),
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
  ImageListActions(
      {super.key,
      this.title,
      this.remoteImage = true,
      this.multipleUpload = true,
      this.pickerIconColor,
      this.cardinality,
      this.listPadding = const EdgeInsets.all(0),
      required this.scrollingAfterUpload,
      this.onSave,
      required this.onUpload,
      required this.getText,
      required this.refresh,
      required this.fileList});

  Color? pickerIconColor;
  EdgeInsets listPadding;
  bool remoteImage;
  bool multipleUpload;
  int? cardinality;
  bool scrollingAfterUpload;
  List<ImageAndCaptionModel> fileList;
  final ValueChanged<List<ImageAndCaptionModel>?>? onSave;
  final void Function() refresh;
  final dynamic Function(
      dynamic dataSource,
      LPI.ControllerLinearProgressIndicator?
          controllerLinearProgressIndicator)? onUpload;
  final String Function(String) getText;
  final String? title;

  @override
  State<ImageListActions> createState() => _ImageListActionsState();
}

class _ImageListActionsState extends State<ImageListActions> {
  dynamic _pickImageError;
  bool isLoading = false;
  //Used to stop scrolling down for first page load
  bool pickedFiles = false;
  Uint8List? localFileUploaded;
  double uploadProgressPercentage = 0;
  String? _retrieveDataError;
  LPI.ControllerLinearProgressIndicator? controllerLinearProgressIndicator;
  final List<TextEditingController> _controllers = [];
  final GlobalKey<FormState> imageFieldFormKey =
      GlobalKey<FormState>(debugLabel: '__imageField__');
  @override
  void initState() {
    controllerLinearProgressIndicator = LPI.ControllerLinearProgressIndicator();
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
      widget.fileList!
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
          log('Multiple image upload: ${pickedFileList.length}');
          if (pickedFileList.isNotEmpty) {
            try {
              log('pickedFileList.111...........');

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
          setState(() {
            _pickImageError = e;
          });
        }
      } else {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
            // maxWidth: maxWidth,
            // maxHeight: maxHeight,
            // imageQuality: quality,
          );
          if (pickedFile != null) {
            try {
              setState(() {
                isLoading = true;
                // isLocalLoading = true;
              });
              dynamic fileUploaded;

              if (widget.remoteImage) {
                if (widget.onUpload != null) {
                  fileUploaded = await widget.onUpload!(
                      pickedFile, controllerLinearProgressIndicator);
                }
              } else {
                final bytes = await pickedFile!.readAsBytes();
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
                //localFileUploaded = null;

                uploadProgressPercentage = 0;
                isLoading = false;
              });
            } catch (e) {
              throw Exception(e.toString());
            } finally {}
          }
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
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
            padding: EdgeInsets.symmetric(vertical: 10),
            child: LPI.LinearProgressIndicator(
                width: double.infinity,
                controllerLinearProgressIndicator:
                    controllerLinearProgressIndicator))
        : SizedBox.shrink();
  }

  Widget headerWidget() {
    bool cardinalityExceeded = (widget.cardinality != null &&
        widget.cardinality! <= widget.fileList!.length);

    var bgColor = isLoading || cardinalityExceeded
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5);
    final IconThemeData iconTheme = IconTheme.of(context);
    Color? iconColor = widget.pickerIconColor ?? iconTheme.color;
    Color? pickerIconColor = isLoading || cardinalityExceeded
        ? iconColor!.withOpacity(0.5)
        : iconColor;

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
    final ThemeData theme = Theme.of(context);
    final AppBarTheme appBarTheme = AppBarTheme.of(context);

    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    log('helooooo ${theme.menuTheme}');
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  side: const BorderSide(width: 0, color: Colors.transparent),
                ),
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
              )
            ],
          ),
          body: Container(
            child: Column(
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
          ),
        ));
  }
}
