import 'package:creator/app/modules/creators/controllers/creator_controller.dart';
import 'package:creator/app/modules/creators/controllers/widgets/creator_card.dart';
import 'package:creator/app/modules/creators/controllers/widgets/responsive_layout.dart';
import 'package:creator/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatorListView extends StatelessWidget {
  const CreatorListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatorController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.addCreator),
          )
        ],
      ),
      body: Obx(() {
        final creators = controller.creators;
        if (creators.isEmpty) {
          return const Center(child: Text('No creators yet.'));
        }
        return ResponsiveLayout(
          mobile: ListView.builder(
            itemCount: creators.length,
            itemBuilder: (_, i) => CreatorCard(
              creator: creators[i],
              onTap: () =>
                  Get.toNamed(AppRoutes.detail, arguments: creators[i].id),
            ),
          ),
          tablet: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 4 / 3,
            children: creators
                .map((c) => CreatorCard(
                    creator: c,
                    onTap: () =>
                        Get.toNamed(AppRoutes.detail, arguments: c.id)))
                .toList(),
          ),
          desktop: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 4 / 3,
            children: creators
                .map((c) => CreatorCard(
                    creator: c,
                    onTap: () =>
                        Get.toNamed(AppRoutes.detail, arguments: c.id)))
                .toList(),
          ),
        );
      }),
    );
  }
}
