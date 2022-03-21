import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

Future<DateTime?> showHoloDatepicker(
    context, onTap, label, controller, initialDate) async {
  return await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return HoloDatePicker(
          onTap: onTap,
          label: label,
          controller: controller,
          initialDate: initialDate);
    },
  );
}

class HoloDatePicker extends StatefulWidget {
  const HoloDatePicker(
      {Key? key,
      this.onTap,
      required this.label,
      required this.controller,
      required this.initialDate})
      : super(key: key);

  final DateTime? initialDate;
  final Function()? onTap;
  final String? label;
  final TextEditingController controller;

  @override
  State<StatefulWidget> createState() {
    return _HoloDatePickerState();
  }
}

class _HoloDatePickerState extends State<HoloDatePicker> {
  final DateTime firstdate = DateTime(DateTime.now().year - 2);
  final DateTime lastdate = DateTime.now();

  //DateTime? _initialDate;
  //String? _dateFormat;
  //Function()? _onTap;
  String? _label;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _label = widget.label ?? "Select Date";
      _controller = widget.controller;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          contentPadding: const EdgeInsets.all(5),
          labelText: _label,
          hintText: _label),
      controller: _controller,
      readOnly: true,
      onTap: () async {
        // DateTime newDate = await DatePicker.showSimpleDatePicker(
        //       context,
        //       initialDate: _initialDate,
        //       firstDate: firstdate,
        //       lastDate: lastdate,
        //       dateFormat: _dateFormat,
        //       locale: DateTimePickerLocale.en_us,
        //       looping: true,
        //     ) ??
        //     _initialDate ?? DateTime.now();
      },
    );
  }
}
