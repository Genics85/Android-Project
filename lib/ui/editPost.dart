import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/post/edit_post_Provider.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/locationTextField.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditPost extends StatefulWidget {
  EditPost({Key? key, this.post}) : super(key: key);

  Post? post;

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> with InputDec {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditPostProvider>(
        create: (context) => EditPostProvider(post: widget.post),
        child: Consumer2<EditPostProvider, AuthenticationProvider>(
            builder: (context, editPostProv, authProv, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Edit Post"),
            ),
            body: editPostProv.lastEvent!.state == EditPostEventState.loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: ThemeColors.primary,
                    ),
                  )
                : Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(15),
                    child: Form(
                      key: editPostProv.formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (String? value) => editPostProv
                                  .isEmptyValidator(value!, "Title"),
                              controller: editPostProv.title,
                              decoration: inputDec(hint: "Title"),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 150,
                              child: (editPostProv.oldImages!.length +
                                          editPostProv.memImages.length) ==
                                      0
                                  ? Center(
                                      child: InkWell(
                                        onTap: () {
                                          editPostProv.onImageUpload();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              ThemePadding.padBase),
                                          decoration: BoxDecoration(
                                              color: ThemeColors.primary,
                                              borderRadius: ThemeBorderRadius
                                                  .smallRadiusAll),
                                          child: Icon(Icons.add,
                                              color: ThemeColors.white),
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: List.generate(
                                          // Check if length of old image plus new images is 8 (ie posts cannot contain more than 8 images)
                                          editPostProv.displayImages.length == 8
                                              ? editPostProv
                                                  .displayImages.length
                                              : (editPostProv
                                                      .displayImages.length) +
                                                  1, (index) {
                                        if (editPostProv.displayImages.length <
                                                8 &&
                                            index ==
                                                editPostProv
                                                    .displayImages.length) {
                                          return Center(
                                            child: InkWell(
                                              onTap: () {
                                                editPostProv.onImageUpload();
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
                                          );
                                        }
                                        return Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              decoration: BoxDecoration(
                                                borderRadius: ThemeBorderRadius
                                                    .smallRadiusAll,
                                                border: Border.all(
                                                    color: ThemeColors.grey,
                                                    width: 1),
                                                image: (editPostProv
                                                            .displayImages[
                                                        index] is String)
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                            "https://go-find-me.herokuapp.com/${editPostProv.displayImages[index]}"),
                                                        fit: BoxFit.cover)
                                                    : DecorationImage(
                                                        image: MemoryImage(
                                                            editPostProv
                                                                    .displayImages[
                                                                index])),
                                              ),
                                              width: 100,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: InkWell(
                                                onTap: () {
                                                  editPostProv
                                                      .removeImage(index);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          ThemeBorderRadius
                                                              .bigRadiusAll,
                                                      color:
                                                          ThemeColors.accent),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: ThemeColors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      })),
                            ),

                            //
                            SizedBox(height: 10),
                            Text(
                              "Last Seen:",
                              style: ThemeTexTStyle.regular(),
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    editPostProv.lastSeenDate != null
                                        ? DateFormat("MMM dd, yyy")
                                            .format(editPostProv.lastSeenDate!)
                                        : "Select Date",
                                    style: ThemeTexTStyle.titleTextStyleBlack,
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
                                                      editPostProv
                                                          .setLastSeenDate(x);
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  onCancel: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  selectionMode:
                                                      DateRangePickerSelectionMode
                                                          .single,
                                                  onSelectionChanged:
                                                      (DateRangePickerSelectionChangedArgs
                                                          x) {
                                                    editPostProv
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
                                  editPostProv.isEmptyValidator(
                                      value!, "Last Seen Location"),
                              hintText: "Last Seen Location",
                              controller: editPostProv.lastSeenLocation,
                              // resultSink:
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              validator: (String? value) => editPostProv
                                  .isEmptyValidator(value!, "Description"),
                              controller: editPostProv.postDescription,
                              maxLines: 5,
                              decoration: inputDec(hint: "Post Description"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            DropdownButton(
                                isExpanded: true,
                                onChanged: editPostProv.onStatusChange,
                                value: editPostProv.status,
                                items: [
                                  DropdownMenuItem(
                                    value: "Not Found",
                                    child: Text("Not Found"),
                                  ),
                                  DropdownMenuItem(
                                      value: "Found", child: Text("Found"))
                                ]),

                            SizedBox(height: 10),
                            ThemeButton.longButtonPrim(
                                text: "Done",
                                onpressed: () {
                                  editPostProv.onSubmitPost(
                                      context,
                                      widget.post!.id!,
                                      authProv.currentUser!.id!);
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        }));
  }
}
