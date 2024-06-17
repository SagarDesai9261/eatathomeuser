import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../../utils/color.dart';
import '../controllers/filter_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/filter.dart';

class FilterWidget extends StatefulWidget {
  final ValueChanged<Filter> onFilter;

  FilterWidget({Key key, this.onFilter}) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends StateMVC<FilterWidget> {
  FilterController _con;
  double _currentValue = 3.0;

  _FilterWidgetState() : super(FilterController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).filter),
                  MaterialButton(
                    onPressed: () {
                      _con.clearFilter();
                    },
                    child: Text(
                      S.of(context).clear,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                shrinkWrap: true,
                children: <Widget>[
                  ExpansionTile(
                    title: Text(
                      S.of(context).delivery_or_pickup,
                    ),
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter?.delivery ?? false,
                        onChanged: (value) {
                          setState(() {
                            _con.filter?.delivery = true;
                          });
                        },
                        title: Text(
                          S.of(context).delivery,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter?.delivery ?? false ? false : true,
                        onChanged: (value) {
                          setState(() {
                            _con.filter?.delivery = false;
                          });
                        },
                        title: Text(
                          S.of(context).pickup,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                  ExpansionTile(
                    title: Text(S.of(context).opened_restaurants),
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter?.open ?? false,
                        onChanged: (value) {
                          setState(() {
                            _con.filter?.open = value;
                          });
                        },
                        title: Text(
                          S.of(context).open,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                  _con.cuisines.isEmpty
                      ? CircularLoadingWidget(height: 100)
                      : ExpansionTile(
                          title: Text(S.of(context).cuisines),
                          children:
                              List.generate(_con.cuisines.length, (index) {
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: _con.cuisines.elementAt(index).selected,
                              onChanged: (value) {
                                _con.onChangeCuisinesFilter(index);
                              },
                              title: Text(
                                _con.cuisines.elementAt(index).name,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                maxLines: 1,
                              ),
                            );
                          }),
                          initiallyExpanded: true,
                        ),
                  ExpansionTile(
                    title: Text("Rating"),
                    children: [
                      CustomPaint(
                        painter: CirclePainter(rating: _currentValue),
                        child: Slider(
                          value: _currentValue,
                          activeColor: kPrimaryColororange,
                          thumbColor: kPrimaryColororange,
                          inactiveColor: kPrimaryColorLiteorange,
                          onChanged: (value) {
                            setState(() {
                              _currentValue = value;
                            });
                          },
                          min: 1.0,
                          max: 5.0,
                          divisions: 5,
                          label: _currentValue.toString(),
                        ),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            MaterialButton(
              elevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              onPressed: () {
                _con.saveFilter().whenComplete(() {
                  widget.onFilter(_con.filter);
                });
              },
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              color: Theme.of(context).accentColor,
              shape: StadiumBorder(),
              child: Text(
                S.of(context).apply_filters,
                textAlign: TextAlign.start,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double rating;

  CirclePainter({@required this.rating});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = kPrimaryColororange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    double circleRadius = 4.0;
    double spacing =
        size.width / 5; // Adjust this value based on the number of circles

    for (int i = 1; i <= 5; i++) {
      double centerX = spacing * i - (spacing / 2);
      double centerY = size.height / 2;

      if (i <= rating) {
        paint.color = kPrimaryColororange;
      } else {
        paint.color = kPrimaryColororange;
      }

      canvas.drawCircle(Offset(centerX, centerY), circleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
