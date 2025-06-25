import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Давление')),
      body: Column(
        children: [
          SizedBox(
            width: 200,
            height: 100,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Давление'),
            ),
          ),
        ],
      ),
    );
  }
}
