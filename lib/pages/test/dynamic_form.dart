import 'package:bills/models/bill.dart';
import 'package:flutter/material.dart';

class DynamicForm extends StatefulWidget {
  const DynamicForm({Key? key}) : super(key: key);

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final List<Map<String, dynamic>> _values = [];
  //int _count = 0;
  String _result = '';
  late Bill _billClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Dynamic Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              setState(() {
                // _count++;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                //_count = 0;
                _result = '';
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _billClass.toJson().length,
                itemBuilder: (context, index) {
                  return _numberField("text$index", null);
                },
              ),
            ),
            Text(_result),
          ],
        ),
      ),
    );
  }

  _onUpdate(String object, String val) async {
    bool isExistObj = false;
    for (var map in _values) {
      if (map[object] == object) {
        isExistObj = true;
        break;
      }
    }
    if (isExistObj) {
      _values.removeWhere((map) {
        return map[object] == object;
      });
    }
    Map<String, dynamic> json = {
      object: val,
    };
    _values.add(json);
    setState(() {
      _result = _values.toString();
    });
  }

  Widget _numberField(String label, VoidCallback? onTap) {
    return TextFormField(
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(5),
          icon: const Icon(Icons.attach_money_outlined),
          labelText: label,
          hintText: label),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        _onUpdate(label, value);
      },
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty || value == "0") {
          return 'Must be geater than 0.';
        }
        return null;
      },
    );
  }
}
