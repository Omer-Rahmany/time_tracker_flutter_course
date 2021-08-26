import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  CustomElevatedButton(
      {this.child,
      this.color,
      this.borderRadius: 2.0,
      this.height: 50.0,
      this.onPressed})
      : assert(borderRadius != null);

  final Widget child;
  final Color color;
  final double borderRadius;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) return color;
              return color;
            }),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) return color;
              return color;
            }),
            elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return 2.0;
              return 2.0;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
            )),
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}
