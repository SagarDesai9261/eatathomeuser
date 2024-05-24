import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Shimmer Effect Example'),
        ),
        body: MyShimmerEffect(),
      ),
    );
  }
}

class MyShimmerEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
              child: Container(
              //  width: 200.0,
                height: 200.0,
                color: Colors.white, // Optional: Provide a color to avoid transparency during shimmer effect
              ),
            ),
         //  SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 30,
                    color: Colors.white,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: 30,
                    color: Colors.white,
                  )
                ],
              ),
            ),
           // SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
              child: Container(
                //  width: 200.0,
                height: 70.0,
                color: Colors.white, // Optional: Provide a color to avoid transparency during shimmer effect
              ),
            ),
           // SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 30,
                    color: Colors.white,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 30,
                    color: Colors.white,
                  )
                ],
              ),
            ),
             SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width *0.3,
                    height: 50,
                    color: Colors.white,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width *0.3,
                    height: 50,
                    color: Colors.white,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width *0.3,
                    height: 50,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
              child: Container(
                //  width: 200.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),




          ],
        ),
      ),
    );
  }
}
