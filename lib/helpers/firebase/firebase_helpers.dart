// import 'package:bills/helpers/functions/functions_global.dart';
// import 'package:bills/models/user_profile.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// final FirebaseFirestore ffInstance = FirebaseFirestore.instance;

// class Firebasehelpers {
//   static final CollectionReference _collectionUsers =
//       ffInstance.collection('users');

//   static Future<UserProfile> getCurrentUser(
//       String userId, bool isLoading) async {
//     isLoading.updateProgressStatus(msg: "");
//     try {
//       UserProfile up;
//       _collectionUsers.doc(userId).get().then((snapshot) {
//         if (snapshot.exists) {
//           up = UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
//           up.id = snapshot.id;
//           up.mapMembers();
//         }
//       }).whenComplete(() {
//         return up;
//       });

//       // DocumentReference document = _collectionUsers.doc(userId);
//       // UserProfile up = UserProfile();
//       // var snapshot;
//       // document.get().then((snapshot) {
//       //   if (snapshot.exists) {
//       //     snapshot = snapshot.data();
//       //   }
//       // }).whenComplete(() {
//       //   UserProfile up = UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
//       //   up.id = data;
//       //   up.mapMembers();
//       //   isLoading.updateProgressStatus(msg: "");
//       //   return UserProfile.fromJson(json)
//       // });
//     } on FirebaseException catch (e) {
//       isLoading.updateProgressStatus(errMsg: "${e.message}.");
//     } catch (e) {
//       isLoading.updateProgressStatus(errMsg: "$e.");
//     }
//   }
// }
