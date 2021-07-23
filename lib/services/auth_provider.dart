import 'package:flutter/cupertino.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';

class AuthProvider extends InheritedWidget {
  AuthProvider({@required this.auth, @required this.child});

  final AuthBase auth;
  final Widget child;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static AuthBase of(BuildContext context) {
    final AuthProvider provider = context.dependOnInheritedWidgetOfExactType();
    return provider.auth;
  }
}