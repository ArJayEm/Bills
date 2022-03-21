import 'package:bills/pages/components/styles/style.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.hardEdge,
      elevation: 9.0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 22, 0, 19),
          ),
        ],
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 2, indent: 10, endIndent: 10, color: Colors.grey);
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color color;
  //final bool isLoading;
  final Function()? onTap;

  const CustomFloatingActionButton(
      {Key? key,
      required this.title,
      required this.color,
      this.icon,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: color,
      onPressed: onTap,
      tooltip: title,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class CustomCenterExpanded extends StatelessWidget {
  final List<Widget> children;

  const CustomCenterExpanded({Key? key, required this.children})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      //height: 120,
      child: Expanded(
        child: Row(
          children: [
            const Spacer(),
            ...children,
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final ImageProvider image;
  final String text;
  final VoidCallback onPressed;

  const CustomIconButton(
      {Key? key,
      required this.color,
      required this.textColor,
      required this.image,
      required this.text,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color,
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Image(image: image, width: 25),
              const SizedBox(width: 10),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 35)
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color checkedColor;
  final Color uncheckedColor;
  final bool isChecked;

  const CustomAppBarButton(
      {Key? key,
      required this.icon,
      required this.onTap,
      required this.uncheckedColor,
      required this.checkedColor,
      required this.isChecked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon,
            size: 26.0, color: isChecked ? checkedColor : uncheckedColor),
      ),
    );
  }
}

class CustomPinWidget extends StatelessWidget {
  final TextEditingController controllerSingle;
  final TextEditingController controllerAll;
  final FocusNode focusNode;
  final FocusNode focusNodeNext;
  final bool isFirst;
  final bool isLast;
  //final VoidCallback onTap;
  final VoidCallback onChanged;

  const CustomPinWidget(
      {Key? key,
      required this.controllerSingle,
      required this.controllerAll,
      required this.focusNode,
      required this.focusNodeNext,
      //required this.onTap,
      required this.onChanged,
      required this.isFirst,
      required this.isLast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        obscureText: true,
        controller: controllerSingle,
        focusNode: focusNode,
        autofocus: controllerAll.text.isEmpty,
        style: const TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isEmpty) {
            controllerSingle.text = "";
            controllerAll.text = "";
            if (isFirst) {
              FocusScope.of(context).unfocus();
            } else {
              FocusScope.of(context).requestFocus(focusNodeNext);
            }
          } else if (value.length == 1) {
            controllerSingle.text = value;
            controllerAll.text = '${controllerAll.text}$value';
            if (isLast) {
              FocusScope.of(context).unfocus();
              onChanged();
            } else {
              FocusScope.of(context).requestFocus(focusNodeNext);
            }
          } else {
            if (isLast) {
              value = value.substring(0, 1);
              controllerSingle.text = value;
              FocusScope.of(context).unfocus();
              onChanged();
            } else {
              FocusScope.of(context).requestFocus(focusNodeNext);
            }
            //_splitPin(value.split(""));
          }
        },
        onTap: () {
          controllerSingle.selection = TextSelection(
              baseOffset: 1, extentOffset: controllerSingle.text.length);
        },
      ),
    );
  }
}

class CustomExpandableWidget extends StatefulWidget {
  final String title;
  final Widget body;
  final bool isExpanded;

  const CustomExpandableWidget(
      {Key? key,
      required this.title,
      required this.body,
      required this.isExpanded})
      : super(key: key);

  @override
  _CustomExpandableWidgetState createState() => _CustomExpandableWidgetState();
}

class _CustomExpandableWidgetState extends State<CustomExpandableWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isExpanded = widget.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).cardColor),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _isExpanded ? 100 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(
                    top: 12, left: 15, right: 15, bottom: 12),
                child: Text(
                  widget.title,
                  style: cardTitleStyle3,
                ),
              ),
              onTap: () => setState(() {
                _isExpanded = !_isExpanded;
              }),
            ),
            ..._isExpanded
                ? <Widget>[const Divider(thickness: 1, height: 0), widget.body]
                : <Widget>[]
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatelessWidget {
  final Widget question;
  final List<dynamic> payers;

  final List<String> selectedItems = [];
  final List<String> selectedIds = [];
  static Map<String, bool> mappedItem = <String, bool>{};

  MultiSelectDialog({Key? key, required this.payers, required this.question})
      : super(key: key);

  /// Function that converts the list answer to a map.
  initMap() {
    for (var element in payers) {
      mappedItem.addEntries(element.id);
    }
    // return mappedItem = Map.fromIterable(payers,
    //     key: (k) => k.id.toString(),
    //     value: (v) {
    //       if (v != true && v != false)
    //         return false;
    //       else
    //         return v as bool;
    //     });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    //if (mappedItem.length == 0) {
    initMap();
    //}
    return SimpleDialog(
      title: question,
      children: [
        ...mappedItem.keys.map(
          (String key) {
            return StatefulBuilder(
              builder: (_, StateSetter setState) => CheckboxListTile(
                  title: Text(key), // Displays the option
                  value: mappedItem[key], // Displays checked or unchecked value
                  controlAffinity: ListTileControlAffinity.platform,
                  onChanged: (value) {
                    setState(() {
                      mappedItem[key] = value!;
                    });
                  }),
            );
          },
        ).toList(),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ElevatedButton(
            child: const Text('Submit'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () {
              selectedItems.clear();
              mappedItem.forEach((key, value) {
                if (value == true) {
                  selectedItems.add(key);
                }
              });
              Navigator.pop(context, selectedItems);
            },
          ),
        ),
      ],
    );
  }
}

class GetUserImage extends StatelessWidget {
  final double height;
  final double width;
  final Color borderColor;
  final double borderWidth;
  //final BoxShape shape;
  //final String? imagePath;
  final ImageProvider image;

  const GetUserImage(
      {Key? key,
      required this.height,
      required this.width,
      required this.borderColor,
      required this.borderWidth,
      //required this.shape,
      required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        shape: BoxShape.circle,
        image: DecorationImage(
            fit: BoxFit.fill,
            image:
                image), //: CircleAvatar(child: Icon(Icons.person)) as ImageProvider,
      ),
    );
  }
}

class CustomDropDownItem extends StatelessWidget {
  final dynamic item;
  final String itemDesignation;

  const CustomDropDownItem(
      {Key? key, required this.item, required this.itemDesignation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return item == null
        ? Container()
        : Container(
            child: (item.avatar == null)
                ? const ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: CircleAvatar(),
                    title: Text("No item selected"),
                  )
                : ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: const CircleAvatar(
                        // this does not work - throws 404 error
                        // backgroundImage: NetworkImage(item.avatar ?? ''),
                        ),
                    title: Text(item.name),
                    subtitle: Text(
                      item.createdAt.toString(),
                    ),
                  ),
          );
  }
}

// class CustomDropDownSearch extends StatelessWidget {
//   final dynamic model;
//   final List<dynamic> list;

//   const CustomDropDownSearch(
//       {Key? key,
//       required this.model,
//       required this.list})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DropdownSearch<model>(
//       showSelectedItem: true,
//       showSearchBox: true,
//       compareFn: (i, s) => i.isEqual(s),
//       label: "Person with favorite option",
//       onFind: (filter) => getData(filter),
//       onChanged: (data) {
//         print(data);
//       },
//       dropdownBuilder: _customDropDownExample,
//       popupItemBuilder: _customPopupItemBuilderExample2,
//       showFavoriteItems: true,
//       favoriteItemsAlignment: MainAxisAlignment.start,
//       favoriteItems: (items) {
//         return items.where((e) => e.name.contains("Mrs")).toList();
//       },
//       favoriteItemBuilder: (context, item) {
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.grey[100]),
//           child: Text(
//             "${item.name}",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.indigo),
//           ),
//         );
//       },
//     );
//   }
// }
