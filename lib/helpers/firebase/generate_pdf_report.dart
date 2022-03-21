// import 'dart:html';

// import 'package:bills/helpers/extensions/format_extension.dart';
// import 'package:bills/models/bill.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// class GeneratePDF {
//   late List<Bill?> billsCurrrent;

//   Future<void> _generateBilling() async {
//     const PdfColor baseColor = PdfColors.grey; // PdfColors.teal;
//     //const PdfColor accentColor = PdfColors.white; // blueGrey900;

//     const _darkColor = PdfColors.grey; // blueGrey800;
//     const _lightColor = PdfColors.teal; //white;

//     //PdfColor _baseTextColor = baseColor.isLight ? _lightColor : _darkColor;

//     PdfColor _accentTextColor = baseColor.isLight ? _lightColor : _darkColor;

//     final String title =
//         "Bills-${DateFormat("MMMM-yyyy").format(_billingCurrent.date!)}";
//     final document = pw.Document();
//     //final output = await getTemporaryDirectory();
//     final appDocDir = await getApplicationDocumentsDirectory();
//     final file = File('${appDocDir.path}/$title');

//     //final image = await imageFromAssetBundle('assets/icons/playstore.png');

//     const tableHeaders = [
//       'Description',
//       'Billing Date',
//       'Amount',
//       'Rate',
//       'Computation',
//       'Total'
//     ];

//     const tableHeadersReading = [
//       'Description',
//       'Billing Date',
//       'Previous',
//       'Current',
//       'Consumption'
//     ];

//     //#region Readings
//     List<List<dynamic>> readings = [];
//     for (var reading in _readings) {
//       readings.add([
//         reading?.billType?.description,
//         reading?.date?.formatDate(dateOnly: true),
//         reading?.readingprevious,
//         reading?.readingCurrent,
//         reading?.reading
//       ]);
//     }
//     ////#endregion

//     //#region Current Billing
//     List<List<dynamic>> currentBillings = [];
//     for (var bill in billsCurrrent) {
//       bool isDebit = bill?.billType?.isdebit ?? false;
//       num total = (isDebit ? bill?.amountToPay : bill?.amount) ?? 0.00;
//       num rate = (bill?.amount ?? 0) / (bill?.quantification ?? 0);
//       String rateComputation = "";

//       if (bill?.billType?.isdebit ?? false) {
//         if (bill?.billTypeId == 6) {
//           rateComputation =
//               "Amount / ${(bill?.quantification as num)} kwH = ${rate.formatForDisplay(currency: "P")}";
//           bill?.computation = "Rate x ${bill.currentReading}";
//           //rateComputation = "$rate = $rateComputation";
//         } else if (bill?.billTypeId == 5) {
//           rateComputation =
//               "Amount / ${_loggedInUserprofile.membersArr.firstWhere((element) => _billsTo.isBefore(element.effectivityEnd ?? DateTime.now())).count} members = ${rate.formatForDisplay(currency: "P")}";
//           bill?.computation =
//               "Rate x ${_selectedUserProfile.membersArr.firstWhere((element) => _billsTo.isBefore(element.effectivityEnd ?? DateTime.now())).count} members";
//           //rateComputation = "$rate = $rateComputation";
//         }
//       }

//       if (bill?.billType?.includeInBilling ?? false) {
//         currentBillings.add([
//           bill?.billType?.description,
//           bill?.billDate?.formatDate(dateOnly: true),
//           bill?.amount.formatForDisplay(currency: "P"),
//           rateComputation,
//           bill?.computation,
//           "${isDebit ? "+" : "-"}${total.formatForDisplay(currency: "P")}"
//         ]);
//       }
//     }
//     currentBillings.add([
//       "Subtotal:",
//       "",
//       "",
//       "",
//       "",
//       _billingCurrent.subtotal.formatForDisplay(currency: "P")
//     ]);
//     if (_billingPrevious.totalPayment.roundTenths() > 0.00) {
//       currentBillings.add([
//         "Previous Unpaid:",
//         _billingPrevious.date?.formatDate(dateOnly: true),
//         _billingPrevious.subtotal.formatForDisplay(currency: "P"),
//         "",
//         "Amount - ${_billingPrevious.coins.formatForDisplay(currency: "P")} coins",
//         _billingPrevious.totalPayment
//             .roundTenths()
//             .formatForDisplay(currency: "P")
//       ]);
//     }
//     if (_useCoins) {
//       currentBillings.add([
//         "Coins:",
//         "",
//         "",
//         "",
//         "",
//         "-${_coins.amount.formatForDisplay(currency: "P")}"
//       ]);
//     }
//     currentBillings.add([
//       "Amount to Pay:",
//       "",
//       "",
//       "",
//       "",
//       _billingCurrent.totalPayment.formatForDisplay(currency: "P")
//     ]);
//     //#endregion

//     document.addPage(
//       pw.MultiPage(
//           pageFormat: PdfPageFormat.letter,
//           margin: const pw.EdgeInsets.all(20),
//           build: (pw.Context context) => [
//                 if (_readings.isNotEmpty)
//                   pw.Table.fromTextArray(
//                     cellAlignment: pw.Alignment.center,
//                     headers: tableHeadersReading,
//                     headerStyle: pw.TextStyle(
//                       color: _accentTextColor,
//                       fontSize: 10,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                     headerHeight: 25,
//                     //cellHeight: 40,
//                     cellAlignments: {
//                       0: pw.Alignment.centerLeft,
//                       1: pw.Alignment.center,
//                       2: pw.Alignment.center,
//                       3: pw.Alignment.center,
//                       4: pw.Alignment.centerRight,
//                     },
//                     cellStyle: const pw.TextStyle(
//                       fontSize: 8,
//                     ),
//                     data: readings,
//                   ),
//                 if (_readings.isNotEmpty) pw.SizedBox(height: 10),
//                 pw.Table.fromTextArray(
//                   cellAlignment: pw.Alignment.center,
//                   headers: tableHeaders,
//                   headerStyle: pw.TextStyle(
//                     color: _accentTextColor,
//                     fontSize: 10,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                   headerHeight: 25,
//                   //cellHeight: 40,
//                   cellAlignments: {
//                     0: pw.Alignment.centerLeft,
//                     1: pw.Alignment.center,
//                     2: pw.Alignment.centerRight,
//                     3: pw.Alignment.center,
//                     4: pw.Alignment.centerRight,
//                   },
//                   cellStyle: const pw.TextStyle(
//                     fontSize: 8,
//                   ),
//                   data: currentBillings,
//                 ),
//               ]),
//     );

//     try {
//       await file.writeAsBytes(await document.save());
//       Print.green("file location: ${file.toString()}");
//       Fluttertoast.showToast(msg: "Billing created.");

//       await _fsInstance
//           .ref()
//           .child("billing history")
//           .child(_selectedUserId)
//           .child(title)
//           .putFile(file);
//       Fluttertoast.showToast(msg: "Opening billing...");
//     } on firebase_storage.FirebaseException catch (e) {
//       String msg = getFirebaseStorageErrorMessage(e);
//       Fluttertoast.showToast(msg: msg);
//     }

//     await Printing.layoutPdf(onLayout: (format) => document.save());
//   }
// }
