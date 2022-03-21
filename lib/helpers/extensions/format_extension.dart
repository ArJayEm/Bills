import 'package:bills/helpers/values/strings.dart';
import 'package:bills/models/icon_data.dart';
import 'package:bills/models/members.dart';
import 'package:flutter/cupertino.dart';
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

  num roundTenths({int decimals = 2}) {
    num number = num.parse(toStringAsFixed(decimals));
    //num number = num.tryParse(format()) ?? 0.00;
    return number;
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
            "${fullMonth ? "MMMM" : "MMM"} ${hideDay ? "" : "dd, "}yyyy${dateOnly ? "" : " hh:mm aaa"}")
        .format(this);
  }

  DateTime formatDateOnly() {
    DateTime d = this;
    return DateTime(d.year, d.month, d.day);
  }

  String lastModified(DateTime? modified, {bool dateOnly = false}) {
    bool isModified = modified != null;
    String prefix = isModified ? "M: " : "C: ";
    DateTime d = modified ?? this;
    return "$prefix${d.formatDate(dateOnly: dateOnly)}";
  }
}

extension DateFormatHelper on DateTime {
  String format({bool dateOnly = false}) {
    return DateFormat(dateOnly ? dateOnlyFormat : "MMM dd, yyyy hh:mm aaa")
        .format(this);
  }

  String formatNoSpace({bool dateOnly = false}) {
    return DateFormat(dateOnly ? "yyyyMMdd" : "yyyyMMdd_hhmmss_aaa")
        .format(this);
  }

  DateTime getLastDay() {
    DateTime date = DateTime(year, month + 1, 1);
    return date.add(const Duration(days: -1));
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
    if (format() == DateTime.now().format()) {
      return "Just Now";
    } else if (diff.inMinutes >= 1 && diff.inDays == 0) {
      return "Today at ${formatToHour()}";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else if (diff.inDays > 1 &&
        formatToMonth() == DateTime.now().formatToMonth() &&
        formatToYear() == DateTime.now().formatToYear()) {
      return formatToDayHour();
    } else if (formatToMonth() != DateTime.now().formatToMonth() &&
        formatToYear() == DateTime.now().formatToYear()) {
      return formatToMonthDayHour();
    } else {
      return format();
    }
  }
}

extension StringFormatHelper on String? {
  bool isNullOrEmpty() {
    return this?.isEmpty ?? true;
  }
}

extension ListFormatHelper on List<Map<String, dynamic>> {
  List<Members> mapMembers() {
    return List<Members>.from(map((e) {
      return Members.fromJson(e);
    }));
  }
}

extension IconFormatHelper on CustomIconData {
  Icon getIcon() {
    return Icon(IconData(codepoint!, fontFamily: fontfamily),
        color: Color(color ?? 0));
  }
}

/// Sample documentation
extension ArrayHelper on Iterable<dynamic> {
  dynamic firstOrDefault() => length == 0 ? null : first;
}

class DateRangeFormatter {
  static String format(DateTime start, DateTime end) {
    if (start == end) {
      return start.formatLocalize();
    } else if (start.format(dateOnly: true) == end.format(dateOnly: true) &&
        start.format(dateOnly: true) == DateTime.now().format(dateOnly: true)) {
      return "Today, ${start.formatToHour()} - ${end.formatToHour()}";
    } else if (start.format(dateOnly: true) == end.format(dateOnly: true) &&
        start.formatToYear() == DateTime.now().formatToYear()) {
      return "${start.formatToMonthDay()}, ${start.formatToHour()} - ${end.formatToHour()}";
    } else if (start.format(dateOnly: true) == end.format(dateOnly: true) &&
        start.formatToYear() != DateTime.now().formatToYear()) {
      return "${start.formatToMonth()} ${start.formatToDayHourYear()} - ${end.formatToDayHourYear()} ";
    } else if (start.format(dateOnly: true) != end.format(dateOnly: true) &&
        start.formatToYear() == DateTime.now().formatToYear()) {
      return "${start.formatToMonthDayHour()} - ${end.formatToMonthDayHour()}";
    } else {
      return "${start.format()} - ${end.format()}";
    }
  }
}
