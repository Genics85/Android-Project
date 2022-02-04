import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/services/placesService.dart';
import 'package:uuid/uuid.dart';

class LocationTextField extends StatefulWidget {
  const LocationTextField(
      {Key? key,
      @required this.hintText = '',
      @required this.controller,
      @required this.validator})
      : super(key: key);

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  _LocationTextFieldState createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> with InputDec {
  final FocusNode _focusNode = FocusNode();

  PlacesService _placesService = sl<PlacesService>();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  List<Suggestion> displayData = [];

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context)!.insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
      }
    });
  }

  StreamController<List<Suggestion>> _locationDisplay =
      StreamController<List<Suggestion>>.broadcast();

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  elevation: 4.0,
                  child: StreamBuilder<List>(
                      stream: _locationDisplay.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index].description),
                                onTap: () {
                                  widget.controller!.text =
                                      snapshot.data![index].description;
                                  this._overlayEntry.remove();
                                },
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text("No Location"),
                          );
                        }
                      }),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        focusNode: this._focusNode,
        onTap: () {
          _placesService.setSessiontToken(Uuid().v4());
        },
        onChanged: (String value) async {
          placeApiCall(value);
        },
        decoration: inputDec(hint: widget.hintText),
        // decoration: InputDecoration(
        //   border: OutlineInputBorder(
        //     borderSide: BorderSide(
        //       color: Colors.grey,
        //       width: 1,
        //       style: BorderStyle.solid,
        //     ),
        //   ),
        //   hintText: widget.hintText,
        // ),
      ),
    );
  }

  placeApiCall(String value) async {
    // var response = await
    _placesService.fetchSuggestions(value, 'en').then((response) {
      if (response is List) {
        // print(response[0].description);
        _locationDisplay.sink.add(response);
        // setState(() {
        //   displayData = response;
        // });
      }
    });
  }
}
