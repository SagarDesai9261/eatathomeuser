// /*
// import 'package:flutter/material.dart';
//
// import '../../utils/color.dart';
// import '../elements/CategoriesCarouselItemWidget.dart';
// import '../elements/CircularLoadingWidget.dart';
// import '../models/category.dart';
//
// // ignore: must_be_immutable
// class CategoriesCarouselWidget extends StatelessWidget {
//   List<Category> categories;
//
//   CategoriesCarouselWidget({Key key, this.categories}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     print("DS>> categories length"+categories.length.toString());
//     return this.categories.isEmpty
//         ? CircularLoadingWidget(height: 150)
//         : Container(
//             height: 150,
//             // decoration: BoxDecoration(
//             //   boxShadow: [BoxShadow(color: kPrimaryColorLiteorange)]
//             // ),
//             padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//             child: ListView.builder(
//               itemCount: this.categories.length,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 double _marginLeft = 0;
//                 (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
//                 return new CategoriesCarouselItemWidget(
//                   marginLeft: _marginLeft,
//                   category: this.categories.elementAt(index),
//                 );
//               },
//             ));
//   }
// }
// */
