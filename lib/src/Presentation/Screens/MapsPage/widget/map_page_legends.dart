import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../../Objects/data.dart';

class Legends extends StatelessWidget {
  const Legends({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: const [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.red,
              ),
              const Gap(5),
              const Text('PCI = 1'),
            ],
          ),
          const Gap(5),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.orange,
              ),
              const Gap(5),
              const Text('PCI = 2'),
            ],
          ),
          const Gap(5),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.yellow,
              ),
              const Gap(5),
              const Text('PCI = 3'),
            ],
          ),
          const Gap(5),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.blue,
              ),
              const Gap(5),
              const Text('PCI = 4'),
            ],
          ),
          const Gap(5),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.green,
              ),
              const Gap(5),
              const Text('PCI = 5'),
            ],
          ),
        ],
      ),
    );
  }
}
