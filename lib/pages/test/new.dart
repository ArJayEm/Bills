// import 'package:bills/pages/components/custom_expandable_widget.dart';
// import 'package:bills/pages/components/custom_icon_button.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class SelectPayers extends StatefulWidget {
//   const SelectPayers({Key? key}) : super(key: key);

//   @override
//   _SelectPayersState createState() => _SelectPayersState();
// }

// class _SelectPayersState extends State<SelectPayers> {
//   Map<String, bool> _selectedPayers = Map<String, bool>();
//   late final Stream<QuerySnapshot<Map<String, dynamic>>> _users;
//   static Map<String, bool> mappedItem = Map<String, bool>();

//   List<dynamic> selectedList = [];
//   List<dynamic> _selectList = [];

//   bool _sampleCheckState = false;
//   String _errorMsg = '';
//   bool _selectedAll = false;

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _getPayers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Text('Select Payers'),
//         iconTheme: IconThemeData(color: Colors.grey.shade300),
//         textTheme:
//             TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
//         titleSpacing: 0,
//         centerTitle: false,
//         backgroundColor: Colors.grey.shade800,
//         actions: <Widget>[
//           CustomAppBarButton(
//             onTap: () => setState(() {
//               selectedList.clear();
//               if (!_selectedAll) {
//                 for (int b = 0; b < _selectList.length; b++) {
//                   selectedList.add(_selectList[b][0]);
//                 }
//               }
//               setState(() {
//                 _selectedAll = !_selectedAll;
//               });
//             }),
//             icon: Icons.select_all,
//             checkedColor: Colors.teal,
//             uncheckedColor: Colors.white,
//             isChecked: _selectedAll,
//           ),
//           CustomAppBarButton(
//             icon: Icons.done,
//             onTap: () => Fluttertoast.showToast(msg: "Done"),
//             checkedColor: Colors.white,
//             uncheckedColor: Colors.white,
//             isChecked: _selectedAll,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: ListView(
//           scrollDirection: Axis.vertical,
//           shrinkWrap: true,
//           children: [
//             TextFormField(),
//             CustomExpandableWidget(
//                 title: 'Select Payers',
//                 body: createMenuWidget(),
//                 isExpanded: false),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget createMenuWidget() {
//     List<Widget> mList = <Widget>[];
//     for (int b = 0; b < _selectList.length; b++) {
//       String id = _selectList[b][0];
//       String displayname = _selectList[b][1];
//       mList.add(CheckboxListTile(
//         selected: selectedList.contains(id),
//         onChanged: (bool? value) {
//           setState(() {
//             if (value == true) {
//               selectedList.add(id);
//             } else {
//               selectedList.remove(id);
//             }
//             _selectedAll = _selectList.length == selectedList.length;
//           });
//           print(selectedList);
//         },
//         value: selectedList.contains(id),
//         title: new Text(displayname),
//         subtitle: new Text(id),
//         controlAffinity: ListTileControlAffinity.leading,
//       ));
//     }
//     return ListView(shrinkWrap: true, children: mList);
//   }

//   Widget _getList1() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection("users").snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Center(child: Text('Something went wrong'));
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         return !snapshot.hasData
//             ? Center(child: Text('No Data'))
//             : ListView.builder(
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var data = snapshot.data!.docs;
//                   return CheckboxListTile(
//                     //dense: true,
//                     contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                     value: _sampleCheckState,
//                     onChanged: (bool? val) {
//                       setState(() => _sampleCheckState = val ?? false);
//                     },
//                     title: Text(data[index].get('display_name').toString()),
//                     subtitle: Text('id: ${data[index].id.toString()}'),
//                     controlAffinity: ListTileControlAffinity.leading,
//                     activeColor: Colors.green,
//                   );
//                 },
//               );
//       },
//     );
//   }

//   Future<void> _getPayers() async {
//     setState(() {
//       _errorMsg = "";
//     });

//     try {
//       List<dynamic> users = [];
//       CollectionReference _collection =
//           FirebaseFirestore.instance.collection("users");
//       _collection.get().then((querySnapshot) {
//         querySnapshot.docs.forEach((doc) {
//           users.add([doc.id, doc.get('display_name')]);
//         });
//       }).whenComplete(() {
//         setState(() {
//           _selectList.addAll(users);
//         });
//       });
//       // var snapshots = FirebaseFirestore.instance
//       //     .collection("users")
//       //     .orderBy('display_name')
//       //     .snapshots();
//       // snapshots.forEach((snapshot) {
//       //   var data = snapshot.docs.first;
//       //   setState(() {
//       //     _selectList.add([data.id, data.get('display_name')]);
//       //   });
//       // });
//     } on FirebaseAuthException catch (e) {
//       _errorMsg = '${e.message}';
//     } catch (error) {
//       _errorMsg = error.toString();
//     }

//     if (_errorMsg.length > 0) {
//       Fluttertoast.showToast(msg: _errorMsg);
//     }
//   }
// }
