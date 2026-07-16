import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dartz/dartz.dart';
import '../app/constants/app_constants.dart';
import '../app/routes/app_routes.dart';
import '../app/utils/helpers.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Central authentication + session controller shared by every role.
class AuthController extends GetxController {
  final AuthService _authService;
  final FirestoreService firestoreService;
  final _box = GetStorage(AppConstants.boxAuth);

  AuthController(this._authService, this.firestoreService);

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  // Restore last session from local storage for a fast cold start.
  void _restoreSession() {
    try {
      final data = _box.read(AppConstants.keyUserId);
      if (data != null) {
        // We will re-fetch fresh data after Firebase init resolves.
      }
    } catch (_) {}
  }

  Future<void> boot() async {
    // Called from the splash screen.
    await Future.delayed(const Duration(milliseconds: 1200));
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    final user = await _authService.getUserModel(fbUser.uid);
    if (user == null) {
      await _authService.logout();
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    currentUser.value = user;
    _persist(user);
    _goToRoleHome();
  }

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    final result = await _authService.login(email: email, password: password);
    isLoading.value = false;
    result.fold(
      (err) => Helpers.showError(err),
      (user) {
        currentUser.value = user;
        _persist(user);
        _goToRoleHome();
      },
    );
  }

  Future<void> registerCustomer({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    isLoading.value = true;
    final result = await _authService.registerCustomer(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );
    isLoading.value = false;
    result.fold(
      (err) => Helpers.showError(err),
      (user) {
        currentUser.value = user;
        _persist(user);
        _goToRoleHome();
      },
    );
  }

  Future<void> logout() async {
    final ok = await Helpers.confirm(
      title: 'Sign out',
      message: 'Are you sure you want to sign out?',
    );
    if (!ok) return;
    await _authService.logout();
    _box.erase();
    Get.offAllNamed(AppRoutes.login);
  }

  void _goToRoleHome() {
    final role = currentUser.value?.role;
    switch (role) {
      case AppConstants.roleMerchant:
        Get.offAllNamed(AppRoutes.merchantHome);
        break;
      case AppConstants.roleRider:
        Get.offAllNamed(AppRoutes.riderHome);
        break;
      case AppConstants.roleCustomer:
      default:
        Get.offAllNamed(AppRoutes.customerHome);
        break;
    }
  }

  void _persist(UserModel user) {
    _box.write(AppConstants.keyIsLoggedIn, true);
    _box.write(AppConstants.keyUserId, user.uid);
    _box.write(AppConstants.keyUserRole, user.role);
  }

  void togglePassword() => obscurePassword.toggle();

  UserModel? get user => currentUser.value;

  /// Persist profile / availability changes and refresh the in-memory user.
  Future<Either<String, void>> updateCurrentUser(UserModel updated) async {
    final res = await _authService.updateUser(updated);
    res.fold(
      (e) => Helpers.showError(e),
      (_) {
        currentUser.value = updated;
        _persist(updated);
      },
    );
    return res;
  }
}
