import 'package:flutter/material.dart';

import '../utils/color.dart';
import 'dine_in_order_view.dart';

class CustomOrderListTile extends StatelessWidget {
  final String name;
  final String address;
  final String date;
  final String imageUrl; // Add the URL or path for the image

  CustomOrderListTile({
     this.name,
     this.address,
     this.date,
     this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(16.0),
      leading: Container(
        width: 60.0, // Set the width to control the aspect ratio
        height: 60.0, // Set initial height (this can be adjusted dynamically)
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            address,
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(height: 4.0),
          Text(
            date,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
     //   mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // height: 28,
            width: 70,
            height: 20,
            /*decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              color: widget.order.activ
                  ? Theme.of(context).accentColor
                  : Colors.redAccent),*/
            decoration: BoxDecoration(

              borderRadius: BorderRadius.all(Radius.circular(30)),
              gradient: LinearGradient(
                colors: [kPrimaryColororange, kPrimaryColorLiteorange],
              ),
            ),
            child: MaterialButton(
              onPressed: () {
                // Handle View button click
                print('View button clicked');
               // Navigator.push(context, MaterialPageRoute(builder: (context)=>dine_in_order_view(order: _o,)));
              },
              child: Text('View',style: TextStyle(
                color: Colors.white
              ),),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(

            child: Text('Cancel',style: TextStyle(fontSize: 12,color: Colors.grey),),
          ),
        ],
      ),
    );
  }
}

// Example Usage
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Order List'),
      ),
      body: ListView(
        children: [
          CustomOrderListTile(
            name: 'John Doe',
            address: '123 Main St, Cityville',
            date: 'March 12, 2024',
            imageUrl: 'https://example.com/image.jpg',
          ),
          // Add more CustomOrderListTile widgets as needed
        ],
      ),
    ),
  ));
}
