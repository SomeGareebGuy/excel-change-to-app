import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://localhost:3000/data'); // Replace with your server's URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body) as List<dynamic>;
      });
    } else {
      print('Failed to fetch data from the server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Product List'),
        ),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Number of columns
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final row = data[index];
            final productName = row['productname'];
            final priceNew = row['newprice'];
            final unitChange = row['unitchange'];
            final unitNew = row['newunit'];
            final priceChange = row['pricechange'];
            final time = row['time'];
            final type = row['type'];

            final isPositiveUnit = unitChange > 0;
            final isPositivePrice = priceChange > 0;

            // Define variables for card customization
            Color cardColor;
            IconData iconData;

            // Customize card based on type
            if (isPositivePrice || isPositiveUnit ) {
              cardColor = Colors.green;
              iconData = Icons.arrow_circle_right;
            } else if (type == 'NEW') {
              cardColor = Colors.blue;
              iconData = Icons.loupe;
            } else {
              cardColor = Colors.red;
              iconData = Icons.arrow_circle_left;
            }

            return PeerGroupMeetupCard(
              cardColor: cardColor,
              newUnit: unitNew,
              newPrice: priceNew,
              changeUnit: unitChange,
              changePrice: priceChange,
              time: time,
              productName: productName,
              iconData: iconData,
            );
          },
        ),
      ),
    );
  }
}


class PeerGroupMeetupCard extends StatelessWidget {
  final Color cardColor;
  final int newUnit;
  final int newPrice;
  final int changeUnit;
  final int changePrice;
  final String time;
  final String productName;
  final IconData iconData;

  const PeerGroupMeetupCard({super.key,
    required this.cardColor,
    required this.newUnit,
    required this.newPrice,
    required this.changePrice,
    required this.changeUnit,
    required this.time,
    required this.productName,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          width: 325,
          height: 157,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 325,
                  height: 157,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: SizedBox(
                          width: 325,
                          height: 157,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 325,
                                  height: 157,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 2,
                                        strokeAlign: BorderSide.strokeAlignOutside,
                                        color: cardColor,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 216,
                        top: 33,
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(6.67),
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Icon(iconData, color:cardColor, size: 66,)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 13,
                child: SizedBox(
                  width: 195,
                  height: 127,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: 'Alegreya',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 195,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Unit: $newUnit ',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Alegreya Sans',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text: '($changeUnit)',
                                style: TextStyle(
                                  color: changeUnit < 0 ? Colors.red : Colors.green,
                                  fontSize: 16,
                                  fontFamily: 'Alegreya Sans',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '\nPrice: $newPrice ',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Alegreya Sans',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text: '($changePrice)',
                                style: TextStyle(
                                  color: changePrice < 0 ? Colors.red : Colors.green,
                                  fontSize: 16,
                                  fontFamily: 'Alegreya Sans',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 195,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Timing: $time',
                                style: TextStyle(
                                  color: cardColor,
                                  fontSize: 18,
                                  fontFamily: 'Alegreya Sans',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
