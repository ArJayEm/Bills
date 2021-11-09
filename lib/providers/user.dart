// import 'package:flutter/cupertino.dart';
// import 'package:flutter_login_facebook/flutter_login_facebook.dart';

// class User extends ChangeNotifier {
//   final plugin = FacebookLogin(debug: true);

//   FacebookUserProfile? _profile;

//   FacebookUserProfile? get profile => _profile;

//   set profile(FacebookUserProfile? profile) {
//     _profile = profile;
//     notifyListeners();
//   }

//   String? _email;

//   String? get email => _email;

//   set email(String? email) {
//     _email = email;
//     notifyListeners();
//   }

//   String? _imageUrl;

//   String? get imageUrl => _imageUrl;

//   set imageUrl(String? imageUrl) {
//     _imageUrl = imageUrl;
//     notifyListeners();
//   }

//   Future validateLogin() async {
//     final token = await plugin.accessToken;
//     if (token != null && !isLoggedin) {
//       profile = await plugin.getUserProfile();
//       if (token.permissions.contains(FacebookPermission.email.name)) {
//         email = await plugin.getUserEmail();
//       }
//       imageUrl = await plugin.getProfileImageUrl(width: 100);
//     } else {
//       profile = null;
//       email = null;
//       imageUrl = null;
//     }
//   }

//   bool get isLoggedin => profile != null;

//   Future login() async {
//     await plugin.logIn(permissions: [
//       FacebookPermission.publicProfile,
//       FacebookPermission.email,
//     ]);
//     await validateLogin();
//   }

//   Future logout() async {
//     await plugin.logOut();
//     await validateLogin();
//   }
// }
