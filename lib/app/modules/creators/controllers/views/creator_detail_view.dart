import 'package:creator/app/modules/creators/controllers/creator_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatorDetailView extends StatelessWidget {
  const CreatorDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String;
    final controller = Get.find<CreatorController>();
    final creator = controller.getById(id);

    if (creator == null) {
      return const Scaffold(body: Center(child: Text('Creator not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(creator.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (creator.media.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  creator.media.first,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(creator.designation,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(creator.about),
            const SizedBox(height: 16),
            Text('₹${creator.price.toStringAsFixed(0)} / project',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
