// import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleSignIn extends ChangeNotifier {
//   GoogleSignInAccount? _currentUser;
//   String _contactText = '';

//   Future<void> _handleGetContact(GoogleSignInAccount user) async {
//     setState(() {
//       _contactText = "Loading contact info...";
//     });
//     final http.Response response = await http.get(
//       Uri.parse('https://people.googleapis.com/v1/people/me/connections'
//           '?requestMask.includeField=person.names'),
//       headers: await user.authHeaders,
//     );
//     if (response.statusCode != 200) {
//       setState(() {
//         _contactText = "People API gave a ${response.statusCode} "
//             "response. Check logs for details.";
//       });
//       print('People API ${response.statusCode} response: ${response.body}');
//       return;
//     }
//     final Map<String, dynamic> data = json.decode(response.body);
//     final String? namedContact = _pickFirstNamedContact(data);
//     setState(() {
//       if (namedContact != null) {
//         _contactText = "I see you know $namedContact!";
//       } else {
//         _contactText = "No contacts to display.";
//       }
//     });
//   }

//   String? _pickFirstNamedContact(Map<String, dynamic> data) {
//     final List<dynamic>? connections = data['connections'];
//     final Map<String, dynamic>? contact = connections?.firstWhere(
//       (dynamic contact) => contact['names'] != null,
//       orElse: () => null,
//     );
//     if (contact != null) {
//       final Map<String, dynamic>? name = contact['names'].firstWhere(
//         (dynamic name) => name['displayName'] != null,
//         orElse: () => null,
//       );
//       if (name != null) {
//         return name['displayName'];
//       }
//     }
//     return null;
//   }

//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }

//   Future<void> _handleSignOut() => _googleSignIn.disconnect();
// }
