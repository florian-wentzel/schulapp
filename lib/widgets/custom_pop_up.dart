import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

// ignore: must_be_immutable
class CustomPopUp extends StatefulWidget {
  Object heroObject;
  Widget body;
  Color color;
  Widget Function(BuildContext, Animation<double>, HeroFlightDirection,
      BuildContext, BuildContext)? flightShuttleBuilder;

  EdgeInsets padding;

  CustomPopUp({
    super.key,
    required this.heroObject,
    required this.color,
    required this.body,
    this.flightShuttleBuilder,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<CustomPopUp> createState() => _CustomPopUpState();
}

class _CustomPopUpState extends State<CustomPopUp> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = Utils.getAspectRatio(context) > Utils.getMobileRatio();

    return Center(
      child: FractionallySizedBox(
        widthFactor: isDesktop ? 0.7 : 0.8,
        heightFactor: isDesktop ? 0.8 : 0.6,
        child: Material(
          color: Colors.transparent,
          child: Hero(
            tag: widget.heroObject,
            flightShuttleBuilder: widget.flightShuttleBuilder,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
