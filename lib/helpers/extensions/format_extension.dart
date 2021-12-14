import 'package:intl/intl.dart';

extension NumberFormatHelper on num {
  String format() {
    return NumberFormat.currency(locale: "en_US", symbol: "").format(this);
  }

  String formatForDisplay({bool withCurrency = true, String currency = "₱ "}) {
    return NumberFormat.currency(
            locale: "en_US", symbol: withCurrency ? currency : "")
        .format(this);
  }
}

extension MsEpochToDateTimeFormat on int {
  DateTime formatToDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(this);
  }

  String formatToDateTimeString() {
    return DateTime.fromMillisecondsSinceEpoch(this).format(dateOnly: true);
  }

  String toVerboseDateTime(int? modifiedon) {
    bool isModified = modifiedon != null;
    String prefix = isModified ? 'M: ' : 'C: ';
    return '$prefix ${(isModified ? modifiedon : this).formatToDateTime().formatLocalize()}';
  }
}

extension DateTimeFormatHelper on DateTime {
  String formatDate(
      {bool dateOnly = false, bool fullMonth = false, bool hideDay = false}) {
    return DateFormat(
            "${fullMonth ? "MMMM " : "MMM "} ${hideDay ? "" : "dd, "}yyyy${dateOnly ? "" : " hh:mm aaa"}")
        .format(this);
  }
}

extension DateFormatHelper on DateTime {
  String format({bool dateOnly = false}) {
    return DateFormat(dateOnly ? "MMM dd, yyyy" : "MMM dd, yyyy hh:mm aaa")
        .format(this);
  }

  String formatNoSpace({bool dateOnly = false}) {
    return DateFormat(dateOnly ? "yyyyMMdd" : "yyyyMMdd_hhmmss_aaa")
        .format(this);
  }

  DateTime getLastDay() {
    DateTime date = DateTime(this.year, this.month + 1, 1);
    return date.add(Duration(days: -1));
  }

  String formatToMonth() {
    return DateFormat("MMM").format(this);
  }

  String formatToMonthYear() {
    return DateFormat("MMM yyyy").format(this);
  }

  String formatToMonthDay() {
    return DateFormat("MMM dd").format(this);
  }

  String formatToYear() {
    return DateFormat("yyyy").format(this);
  }

  String formatToHour({bool dateOnly = false}) {
    return DateFormat("hh:mm aaa").format(this);
  }

  String formatToDayHour() {
    return DateFormat("EEEE, hh:mm aaa").format(this);
  }

  String formatToMonthDayHour() {
    return DateFormat("MMM dd, hh:mm aaa").format(this);
  }

  String formatToDayHourYear() {
    return DateFormat("EEEE, hh:mm aaa yyyy").format(this);
  }

  String formatLocalize() {
    var diff = DateTime.now().difference(this);
    //print(diff.inDays);
    if (this.format() == DateTime.now().format())
      return "Just Now";
    else if (diff.inMinutes >= 1 && diff.inDays == 0)
      return "Today at ${this.formatToHour()}";
    else if (diff.inDays == 1)
      return "Yesterday";
    else if (diff.inDays > 1 &&
        this.formatToMonth() == DateTime.now().formatToMonth() &&
        this.formatToYear() == DateTime.now().formatToYear())
      return this.formatToDayHour();
    else if (this.formatToMonth() != DateTime.now().formatToMonth() &&
        this.formatToYear() == DateTime.now().formatToYear())
      return this.formatToMonthDayHour();
    else
      return this.format();
  }
}

extension StringFormatHelper on String? {
  bool isNullOrEmpty() {
    return this?.isEmpty ?? true;
  }
}

/// Sample documentation
///
/// safddsf
extension ArrayHelper on Iterable<dynamic> {
  dynamic firstOrDefault() => this.length == 0 ? null : this.first;
}

class DateRangeFormatter {
  static String format(DateTime start, DateTime end) {
    if (start == end)
      return start.formatLocalize();
    else if (start.format(dateOnly: true) == end.format(dateOnly: true) &&
        start.format(dateOnly: true) == DateTime.now().format(dateOnly: true))
      return "Today, ${start.formatToHour()} - ${end.formatToHour()}";
    else if (start.format(dateOnly: true) == end.format(dateOnly: true) &&
        start.formatToYear() == DateTime.now().formatToYear())
      return "${start.formatToMonthDay()}, ${start.formatToHour()} - ${end.formatToHour()}";
    else if (start.format(dateOnly: true) == end.format(dateOnly: true) &&
        start.formatToYear() != DateTime.now().formatToYear())
      return "${start.formatToMonth()} ${start.formatToDayHourYear()} - ${end.formatToDayHourYear()} ";
    else if (start.format(dateOnly: true) != end.format(dateOnly: true) &&
        start.formatToYear() == DateTime.now().formatToYear())
      return "${start.formatToMonthDayHour()} - ${end.formatToMonthDayHour()}";
    else
      return "${start.format()} - ${end.format()}";
  }
}
