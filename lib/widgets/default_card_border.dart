import 'package:flutter/material.dart';

/// Default Card border
RoundedRectangleBorder defaultCardBorder() {
  return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(28.0),
    topRight: Radius.circular(28.0),
    topLeft: Radius.circular(28.0),
    bottomRight: Radius.circular(28.0),
  ));
}
