import 'package:flutter/material.dart';
import 'package:pnhs_go/widgets/location_field_widget.dart';

Widget endpointsCard(TextEditingController sourceController,
    TextEditingController destinationController) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        Column(
          children: [
            const Icon(Icons.run_circle_rounded),
            Container(
              color: Colors.purple,
              width: 2,
              height: 40,
            ),
            const Icon(Icons.stop_circle_rounded),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              LocationFieldWidget(
                  isDestination: false,
                  textEditingController: sourceController),
              const Divider(),
              LocationFieldWidget(
                  isDestination: true,
                  textEditingController: destinationController),
            ],
          ),
        ),
      ],
    ),
  );
}
