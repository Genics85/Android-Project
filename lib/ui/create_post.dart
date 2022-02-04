import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/modules/post/create_post_provider.dart';
import 'package:go_find_me/services/placesService.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/locationTextField.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:provider/provider.dart';

class CreatePostView extends StatefulWidget {
  CreatePostView({Key? key, this.pageController}) : super(key: key);
  PageController? pageController;

  @override
  _CreatePostViewState createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  // CreatePostBloc createPostBloc = CreatePostBloc();
  PlacesService placesService = sl<PlacesService>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatePostProvider(),
      child: Scaffold(
        backgroundColor: ThemeColors.white,
        body:
            Consumer<CreatePostProvider>(builder: (context, createPostProv, _) {
          return SafeArea(
            child: StreamBuilder<CreatePostEvent>(
                initialData: CreatePostEvent(state: CreatePostEventState.idle),
                stream: createPostProv.stream,
                builder: (context, snapshot) {
                  return snapshot.data!.state == CreatePostEventState.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: ThemeColors.primary,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(15),
                            child: Form(
                              key: createPostProv.formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (String? value) => createPostProv
                                        .isEmptyValidator(value!, "Title"),
                                    controller: createPostProv.title,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        hintText: "Title"),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 150,
                                    child: createPostProv.memImages.length == 0
                                        ? Center(
                                            child: InkWell(
                                              onTap: () {
                                                createPostProv.onImageUpload();
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    ThemePadding.padBase),
                                                decoration: BoxDecoration(
                                                    color: ThemeColors.primary,
                                                    borderRadius:
                                                        ThemeBorderRadius
                                                            .smallRadiusAll),
                                                child: Icon(Icons.add,
                                                    color: ThemeColors.white),
                                              ),
                                            ),
                                          )
                                        : ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: List.generate(
                                                createPostProv
                                                            .memImages.length ==
                                                        8
                                                    ? createPostProv
                                                        .memImages.length
                                                    : createPostProv
                                                            .memImages.length +
                                                        1, (index) {
                                              if (createPostProv
                                                          .memImages.length <
                                                      8 &&
                                                  index ==
                                                      createPostProv
                                                          .memImages.length) {
                                                return Center(
                                                  child: InkWell(
                                                    onTap: () {
                                                      createPostProv
                                                          .onMoreImageUpload();
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          ThemePadding.padBase),
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      decoration: BoxDecoration(
                                                          color: ThemeColors
                                                              .primary,
                                                          borderRadius:
                                                              ThemeBorderRadius
                                                                  .smallRadiusAll),
                                                      child: Icon(Icons.add,
                                                          color: ThemeColors
                                                              .white),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Stack(
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            ThemeBorderRadius
                                                                .smallRadiusAll,
                                                        border: Border.all(
                                                            color: ThemeColors
                                                                .grey,
                                                            width: 1),
                                                        image: DecorationImage(
                                                            image: MemoryImage(
                                                                createPostProv
                                                                        .memImages[
                                                                    index]),
                                                            fit: BoxFit.cover)),
                                                    width: 100,
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        createPostProv
                                                            .removeImage(index);
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                ThemeBorderRadius
                                                                    .bigRadiusAll,
                                                            color: ThemeColors
                                                                .accent),
                                                        child: Icon(
                                                          Icons.close,
                                                          color:
                                                              ThemeColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Last Seen:",
                                    style: ThemeTexTStyle.regular(),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    // height: 50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          createPostProv.lastSeenDate != null
                                              ? DateFormat("MMM dd, yyy")
                                                  .format(createPostProv
                                                      .lastSeenDate!)
                                              : "Select Date",
                                          style: ThemeTexTStyle
                                              .titleTextStyleBlack,
                                        ),
                                        ThemeButton.ButtonSec(
                                            text: "Select",
                                            onpressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    // return Container(
                                                    // child: SfDateRangePicker());

                                                    return AlertDialog(
                                                        content: Container(
                                                      height: 350,
                                                      width: 350,
                                                      margin: EdgeInsets.all(5),
                                                      child: SfDateRangePicker(
                                                        maxDate: DateTime.now(),
                                                        initialDisplayDate:
                                                            DateTime.now(),
                                                        showActionButtons: true,
                                                        onSubmit: (x) {
                                                          if (x is DateTime) {
                                                            createPostProv
                                                                .setLastSeenDate(
                                                                    x);
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        onCancel: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        selectionMode:
                                                            DateRangePickerSelectionMode
                                                                .single,
                                                        onSelectionChanged:
                                                            (DateRangePickerSelectionChangedArgs
                                                                x) {
                                                          createPostProv
                                                              .setLastSeenDate(
                                                                  x.value);
                                                        },
                                                      ),
                                                    ));
                                                  });
                                            }),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  LocationTextField(
                                    validator: (String? value) =>
                                        createPostProv.isEmptyValidator(
                                            value!, "Last Seen Location"),
                                    hintText: "Last Seen Location",
                                    controller: createPostProv.lastSeenLocation,
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    validator: (value) =>
                                        createPostProv.isEmptyValidator(
                                            value!, "Description"),
                                    controller: createPostProv.postDescription,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      hintText: "Post Description",
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ThemeButton.longButtonPrim(
                                      text: "Create Post",
                                      onpressed: () {
                                        createPostProv.onCreatePost(context);
                                      }),
                                ],
                              ),
                            ),
                          ),
                        );
                }),
          );
        }),
      ),
    );
  }
}
