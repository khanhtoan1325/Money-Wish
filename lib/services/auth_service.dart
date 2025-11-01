import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // ✅ Stream để listen trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Đăng xuất
  Future<void> signOut() async {
    try {
      // Sign out từ Google (nếu đã login bằng Google)
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        print('Google sign out error: $e');
      }

      // Sign out từ Firebase
      await _auth.signOut();

      // ✅ XÓA LOCAL CACHE (Categories vẫn giữ, chỉ xóa transactions nếu có)
      // Nếu bạn có box transactions trong Hive, xóa nó
      try {
        if (Hive.isBoxOpen('transactions')) {
          final box = Hive.box('transactions');
          await box.clear();
          await box.close();
        }
      } catch (e) {
        print('Clear Hive error: $e');
      }

      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  // ✅ Kiểm tra user đã login chưa
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // ✅ Lấy email user hiện tại
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  // ✅ Lấy userId hiện tại
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}