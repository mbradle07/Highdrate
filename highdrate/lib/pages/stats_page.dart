import 'dart:ffi';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_value/flutter_reactive_value.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'home_page.dart';
import '../widgets/characteristic_tile.dart';

final ReactiveValueNotifier<List<double>> ounceAmountsList = ReactiveValueNotifier<List<double>>([]);

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super (key: key);

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
double measurement = 0;

  @override
  void initState() {
    super.initState();
    if(characteristic.value != null) {
      characteristic.value.lastValueStream.listen((newValue) {
        String data = utf8.decode(newValue);
        try {
          double newMeasurement = double.parse(data);
          if(newMeasurement >= .5 && newMeasurement <= 22.606) {
            measurementList.value.add(newMeasurement);
            if(measurementList.value.length == 1) {
              ounceAmountsList.value.add((measurementList.value.last / 22.606 * 20).roundToDouble());
            }
            if(measurementList.value.length >= 2) {
              if(measurementList.value[measurementList.value.length - 2] + .5 < measurementList.value.last) {
                ounceAmountsList.value.add(((measurementList.value[measurementList.value.length - 2] - measurementList.value.last).abs() / 22.606 * 20).roundToDouble());
              }
            }
          }
          if(measurementList.value.length > 3) {
            measurementList.value.removeRange(0, measurementList.value.length - 3);
          }
          setState(() {
            measurement = newMeasurement;
          });
        } catch (e) {
          print(e);
        }
      });
    }
  }

  // @override
  // void dispose() {
  //   characteristic.value.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    double currMeasurement = 0.0;
    double prevMeasurement = 0.0;
    double percentRecDailyIntake = 0.0; // recommended daily water intake is between 91 to 125 ounces
    double percentAway = 100.00;
    double currOunceAmount = 0.0;
    List<double> measurements = measurementList.reactiveValue(context);
    List<double> ounceAmounts = ounceAmountsList.reactiveValue(context);
    
    // the water bottle is 22.606 cm and holds 20 ounces of water
    if(measurements.isNotEmpty) {
      print("measurement list: $measurements");
      currMeasurement = measurements.last;
      print("last measurement in list: $currMeasurement");
      // if(measurements.length == 1) {
      //   ounceAmounts.add((measurements.last / 22.606 * 20).roundToDouble());
      //   currOunceAmount = (measurements.last / 22.606 * 20).roundToDouble();
      // }
      if(measurements.length >= 2) {
        prevMeasurement = measurements[measurements.length - 2];
        print("measurement before last measurement in list: $prevMeasurement");
        // if(measurements[measurements.length - 2] + .5 < measurements.last) {
        //   ounceAmounts.add((((measurements.last - measurements[measurements.length - 2]).abs()) / 22.606 * 20).roundToDouble());
        //   double prevOunceAmount = ounceAmounts.last;
        //   currOunceAmount = prevOunceAmount + ounceAmounts.last;
        //   currOunceAmount = measurements[measurements.length - 2] + measurements.last;
        // }
      }
      print("ounce amounts: $ounceAmounts");
      currOunceAmount = ounceAmounts.reduce((value, element) => value + element);
      print("total amount of ounces drank: $currOunceAmount");
      percentRecDailyIntake = currOunceAmount / 110; 
      percentAway = (1 - percentRecDailyIntake) * 100;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: const Text('Stats Page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 80.0),
              alignment: Alignment.center,
              child: CircularPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineWidth: 25.0, 
                percent: percentRecDailyIntake, 
                radius: 125,
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.blue.shade100,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text("${(percentRecDailyIntake * 100).roundToDouble()}%")),
            ),
            Container(
              child: Text(
                "You have drunk $currOunceAmount ounces today and are ${percentAway.roundToDouble()}% away from drinking the daily recomended water intake.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      ),
    );
  }
}
