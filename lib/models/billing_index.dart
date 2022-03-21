// import 'package:bills/models/bill.dart';
// import 'package:bills/models/bill_type.dart';
// import 'package:bills/models/billing.dart';
// import 'package:bills/models/coins.dart';
// import 'package:bills/models/meter_readings.dart';
// import 'package:bills/models/model_base.dart';
// import 'package:bills/models/user_profile.dart';

// class BillingIndex extends ModelBase {
//   String _loggedInId = "";
//   String _selectedUserId = "";
//   DateTime _billsFrom = DateTime.now();
//   DateTime _billsTo = DateTime.now();
//   DateTime _prevBillsFrom = DateTime.now();
//   DateTime _prevBillsTo = DateTime.now();
//   String? _hasBillingExistingText = "";
//   String? _hasBillingExistingTextOld = "";
//   bool _isEdit = false;
//   bool _isLoading = false;
//   bool _isLoadingBills = false;
//   bool _isLoadingCoins = false;
//   bool _hasBillingExists = false;
//   bool _hasCoins = false;
//   bool _useCoins = false;

//   UserProfile _loggedInUserprofile = UserProfile();
//   UserProfile _selectedUserProfile = UserProfile();
//   List<UserProfile?> _userProfiles = [];
//   Billing _billingCurrent = Billing();
//   Billing _billingPayment = Billing();
//   Billing _billingPrevious = Billing();
//   Billing _billingExisting = Billing();
//   Coins _coins = Coins();

//   List<Bill?> _billsCurrrent = [];
//   List<BillType?> _billTypes = [];
//   List<int> _billTypeIds = [];
//   List<int> _currrentBillTypeIds = [];
//   List<int> _paymentBillTypeIds = [];
//   List<Reading?> _readings = [];

//   BillingIndex();
// }
