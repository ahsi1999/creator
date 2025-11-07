import 'package:creator/app/modules/creators/controllers/views/add_creator_view.dart';
import 'package:creator/app/modules/creators/controllers/views/creator_detail_view.dart';
import 'package:creator/app/modules/creators/controllers/views/creator_list_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const creators = '/';
  static const addCreator = '/add';
  static const detail = '/detail';
}

class AppPages {
  static const initial = AppRoutes.creators;

  static final routes = [
    GetPage(name: AppRoutes.creators, page: () => const CreatorListView()),
    GetPage(name: AppRoutes.addCreator, page: () => const AddCreatorView()),
    GetPage(name: AppRoutes.detail, page: () => const CreatorDetailView()),
  ];
}
