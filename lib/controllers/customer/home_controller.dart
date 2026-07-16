import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService;

  HomeController(this._firestoreService);

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<RestaurantModel> filtered = <RestaurantModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    isLoading.value = true;
    _firestoreService.restaurantsStream().listen((list) {
      restaurants.value = list;
      _applyFilter();
      isLoading.value = false;
    });
    _firestoreService.categoriesStream().listen((list) {
      categories.value = list;
    });
  }

  void onSearch(String q) {
    searchQuery.value = q;
    _applyFilter();
  }

  void selectCategory(String id) {
    selectedCategory.value = selectedCategory.value == id ? '' : id;
    _applyFilter();
  }

  void _applyFilter() {
    var list = restaurants.toList();
    if (selectedCategory.value.isNotEmpty) {
      list = list
          .where((r) =>
              r.categoryId == selectedCategory.value ||
              r.categoryName == selectedCategory.value)
          .toList();
    }
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              (r.categoryName?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    filtered.value = list;
  }
}
