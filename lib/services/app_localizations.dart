import 'package:flutter/foundation.dart';
import 'locale_service.dart';

/// Class quản lý tất cả các text dịch thuật trong ứng dụng
class AppLocalizations {
  static final AppLocalizations _instance = AppLocalizations._internal();
  factory AppLocalizations() => _instance;
  AppLocalizations._internal();

  String _currentLanguage = 'vi';
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('vi');

  /// Khởi tạo với ngôn ngữ hiện tại
  Future<void> initialize() async {
    final localeService = LocaleService();
    // LocaleService đã được initialize trong main.dart
    _currentLanguage = localeService.getCurrentLanguage();
    languageNotifier.value = _currentLanguage;
    
    // Listen to language changes từ LocaleService
    localeService.languageNotifier.addListener(() {
      _currentLanguage = localeService.getCurrentLanguage();
      languageNotifier.value = _currentLanguage;
    });
  }

  /// Lấy text theo key
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  /// Getter để truy cập dễ dàng
  String get(String key) => translate(key);

  /// Translations map
  static const Map<String, Map<String, String>> _translations = {
    'vi': {
      // Common
      'app_name': 'MoneyWise',
      'error': 'Lỗi',
      'retry': 'Thử lại',
      'cancel': 'Hủy',
      'delete': 'Xóa',
      'confirm': 'Xác nhận',
      'save': 'Lưu',
      'add': 'Thêm',
      'edit': 'Chỉnh sửa',
      'close': 'Đóng',
      'ok': 'OK',
      'default': 'Mặc định',
      
      // Home Screen
      'home': 'Trang chủ',
      'total_balance': 'Tổng số dư',
      'income': 'Thu nhập',
      'expenses': 'Chi tiêu',
      'day': 'Ngày',
      'month': 'Tháng',
      'year': 'Năm',
      'week': 'Tuần',
      'no_transactions': 'Chưa có giao dịch nào',
      'add_first_transaction': 'Nhấn nút + để thêm giao dịch đầu tiên',
      'confirm_delete_transaction': 'Bạn có chắc chắn muốn xóa giao dịch này không?',
      'transaction_deleted': 'Đã xóa giao dịch!',
      'transaction_history': 'Lịch sử giao dịch',
      'see_all': 'Xem tất cả',
      
      // Statistics Screen
      'statistics': 'Thống kê',
      'column': 'Cột',
      'circular': 'Tròn',
      'total': 'Tổng cộng',
      'top_spending': 'Chi tiêu nhiều nhất',
      'no_data': 'Chưa có dữ liệu để hiển thị',
      'add_transactions_to_see': 'Thêm giao dịch để xem thống kê',
      
      // Add Transaction Screen
      'add_transaction': 'Thêm giao dịch',
      'amount': 'Số tiền',
      'amount_required': 'Số tiền phải lớn hơn 0',
      'select_type': 'Chọn loại',
      'notes': 'Ghi chú',
      'select_category': 'Chọn danh mục',
      'fill_all_info': 'Vui lòng điền đầy đủ thông tin.',
      'transaction_added': 'Đã thêm giao dịch thành công!',
      'cant_save_transaction': 'Không thể lưu giao dịch',
      'spending_limit_exceeded': 'Vượt giới hạn chi tiêu',
      'spending_limit_warning': 'Khoản chi: {amount}\nGiới hạn mỗi giao dịch: {limit}\nVượt: {percent}% so với giới hạn.\n\nBạn có muốn tiếp tục thêm giao dịch?',
      'later': 'Để sau',
      'continue_add': 'Tiếp tục thêm',
      
      // Category Screen
      'categories': 'Danh mục',
      'add_category': 'Thêm danh mục mới',
      'edit_category': 'Chỉnh sửa danh mục',
      'category_name': 'Tên danh mục (có thể thêm ký hiệu)',
      'category_name_hint': 'Ví dụ: 🍔 Đồ ăn, 📱 Điện thoại',
      'confirm_delete_category': 'Bạn có chắc chắn muốn xóa danh mục này?',
      'category_deleted': 'Đã xóa danh mục',
      'category_added': 'Đã thêm danh mục',
      'category_updated': 'Đã cập nhật danh mục',
      'enter_category_name': 'Vui lòng nhập tên danh mục',
      'add_new_category': 'Thêm danh mục mới',
      
      // Budget Screen
      'budgets': 'Ngân sách',
      'active': 'Đang áp dụng',
      'ended': 'Đã kết thúc',
      'add_new_budget': 'Thêm ngân sách mới',
      'select_category_for_budget': 'Vui lòng chọn danh mục',
      'budget_amount': 'Số tiền ngân sách',
      'start_date': 'Ngày bắt đầu',
      'end_date': 'Ngày kết thúc',
      'spent_today': 'Đã chi tiêu',
      'total_budget': 'Tổng ngân sách',
      'remaining': 'Còn lại',
      'overspent': 'Vượt quá',
      'no_budgets_yet': 'Bạn chưa có ngân sách nào',
      'no_ended_budgets': 'Không có ngân sách đã kết thúc',
      'tap_plus_to_create': 'Nhấn nút + để tạo ngân sách mới',
      
      // Settings Screen
      'settings': 'Cài đặt',
      'profile': 'Hồ sơ',
      'view_account_info': 'Xem thông tin tài khoản của bạn',
      'dark_mode': 'Chế độ tối',
      'dark_mode_enabled': 'Đang bật giao diện tối',
      'dark_mode_disabled': 'Đang bật giao diện sáng',
      'notifications': 'Thông báo',
      'notifications_subtitle': 'Nhận thông báo về ngân sách và chi tiêu',
      'notifications_disabled': 'Đã tắt tất cả thông báo',
      'language': 'Ngôn ngữ',
      'currency': 'Tiền tệ',
      'security': 'Bảo mật',
      'security_subtitle': 'Quản lý mật khẩu và quyền riêng tư',
      'app_info': 'Giới thiệu ứng dụng',
      'app_info_subtitle': 'Xem thông tin về ứng dụng này',
      'wallet_management': 'Quản lý ví',
      'wallet_management_subtitle': 'Thêm, sửa hoặc xóa ví của bạn',
      'category_management': 'Quản lý danh mục',
      'category_management_subtitle': 'Tùy chỉnh các loại giao dịch',
      'logout': 'Đăng xuất',
      'logout_confirm': 'Bạn có chắc chắn muốn đăng xuất?',
      'logging_out': 'Đang đăng xuất...',
      'language_changed': 'Đã đổi sang {language}',
      'currency_changed': 'Đã đổi sang {currency}',
      
      // Search Screen
      'search': 'Tìm kiếm',
      'search_by_notes': 'Tìm kiếm theo ghi chú',
      'search_enter_keywords': 'Nhập từ khóa để tìm kiếm',
      'search_no_results': 'Không tìm thấy kết quả cho "{query}"',
      'search_try_different': 'Thử tìm kiếm với từ khóa khác',
      'search_found_results': 'Tìm thấy {count} kết quả',
      
      // Transaction Detail Screen
      'transaction_details': 'Chi tiết giao dịch',
      'category': 'Danh mục',
      'type': 'Loại',
      'date': 'Ngày',
      'note': 'Ghi chú',
      
      // Profile Screen
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'display_name': 'Tên hiển thị',
      'gender': 'Giới tính',
      'date_of_birth': 'Ngày sinh',
      'email': 'Email',
      'email_verified': 'Email đã xác thực',
      'male': 'Nam',
      'female': 'Nữ',
      'other': 'Khác',
      'profile_updated': 'Đã cập nhật thông tin',
      'date_of_birth_updated': 'Đã cập nhật ngày sinh',
      'user': 'Người dùng',
      'no_email': 'Chưa có email',
      'not_updated': 'Chưa cập nhật',
      'verified': 'Đã xác thực',
      'not_verified': 'Chưa xác thực',
      'account_info': 'Thông tin tài khoản',
      'uid': 'UID',
      'account_created': 'Ngày tạo tài khoản',
      'last_login': 'Lần đăng nhập cuối',
      'gender_updated': 'Đã cập nhật giới tính',
      'display_name_updated': 'Đã cập nhật tên hiển thị',
      
      // Login/Register Screen
      'login': 'Đăng nhập',
      'register': 'Đăng ký',
      'email_label': 'Email',
      'password': 'Mật khẩu',
      'confirm_password': 'Xác nhận mật khẩu',
      'forgot_password': 'Quên mật khẩu?',
      'login_with_google': 'Đăng nhập bằng Google',
      'dont_have_account': 'Chưa có tài khoản?',
      'already_have_account': 'Đã có tài khoản?',
      'register_success': 'Tạo tài khoản thành công. Vui lòng đăng nhập.',
      'forgot_password_email_sent': 'Đã gửi hướng dẫn khôi phục mật khẩu đến: {email}',
      'password_reset_sent': 'Đã gửi yêu cầu',
      'enter_email': 'Nhập email',
      'invalid_email': 'Email không hợp lệ',
      'enter_password': 'Nhập mật khẩu',
      'password_too_short': 'Mật khẩu quá ngắn',
      'login_error': 'Lỗi đăng nhập',
      'user_not_found': 'Email chưa được đăng ký. Vui lòng tạo tài khoản mới.',
      'wrong_password': 'Mật khẩu không đúng. Vui lòng thử lại.',
      'invalid_credential': 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.',
      'user_disabled': 'Tài khoản đã bị vô hiệu hóa.',
      'too_many_requests': 'Quá nhiều lần thử. Vui lòng thử lại sau.',
      'login_failed': 'Đăng nhập thất bại',
      'register_error': 'Lỗi đăng ký',
      'email_already_in_use': 'Email này đã được đăng ký trước đó.',
      'weak_password': 'Mật khẩu quá yếu.',
      'register_failed': 'Đăng ký thất bại.',
      'something_went_wrong': 'Có lỗi xảy ra. Vui lòng thử lại.',
      'enter_password_again': 'Nhập lại mật khẩu',
      'passwords_not_match': 'Mật khẩu không khớp',
      'register_subtitle': 'Bắt đầu hành trình quản lý tài chính',
      'back_to_login': 'Quay lại đăng nhập',
      
      // Security Screen
      'security_privacy': 'Bảo mật & Quyền riêng tư',
      'biometric_lock': 'Khóa vân tay / Face ID',
      'biometric_subtitle': 'Bảo vệ ứng dụng bằng sinh trắc học',
      'change_password': 'Đổi mật khẩu',
      'privacy_policy': 'Chính sách quyền riêng tư',
      'privacy_policy_subtitle': 'Xem chi tiết chính sách bảo mật dữ liệu',
      
      // Change Password Screen
      'change_password_title': 'Đổi mật khẩu',
      'update_password': 'Cập nhật mật khẩu của bạn',
      'old_password': 'Mật khẩu cũ',
      'new_password': 'Mật khẩu mới',
      'confirm_new_password': 'Xác nhận mật khẩu mới',
      'password_changed': 'Đổi mật khẩu thành công!',
      
      // Forgot Password Screen
      'forgot_password_title': 'Quên mật khẩu?',
      'forgot_password_subtitle': 'Nhập email đã đăng ký để nhận hướng dẫn khôi phục mật khẩu.',
      'send_request': 'GỬI YÊU CẦU',
      
      // App Info Screen
      'app_info_title': 'Giới thiệu ứng dụng',
      'app_subtitle': 'Quản lý chi tiêu thông minh',
      'detail_info': 'Thông tin chi tiết',
      'version': 'Phiên bản',
      'developer': 'Nhà phát triển',
      'support_email': 'Email hỗ trợ',
      'contact_copyright': 'Liên hệ & Bản quyền',
      'copyright': '© 2025 MoneyWise',
    },
    'en': {
      // Common
      'app_name': 'MoneyWise',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'save': 'Save',
      'add': 'Add',
      'edit': 'Edit',
      'close': 'Close',
      'ok': 'OK',
      'default': 'Default',
      
      // Home Screen
      'home': 'Home',
      'total_balance': 'Total Balance',
      'income': 'Income',
      'expenses': 'Expenses',
      'day': 'Day',
      'month': 'Month',
      'year': 'Year',
      'week': 'Week',
      'no_transactions': 'No transactions yet',
      'add_first_transaction': 'Tap + button to add your first transaction',
      'confirm_delete_transaction': 'Are you sure you want to delete this transaction?',
      'transaction_deleted': 'Transaction deleted!',
      'transaction_history': 'Transactions History',
      'see_all': 'See all',
      
      // Statistics Screen
      'statistics': 'Statistics',
      'column': 'Column',
      'circular': 'Circular',
      'total': 'Total',
      'top_spending': 'Top Spending',
      'no_data': 'No data to display',
      'add_transactions_to_see': 'Add transactions to see statistics',
      
      // Add Transaction Screen
      'add_transaction': 'Add Transaction',
      'amount': 'Amount',
      'amount_required': 'Amount must be greater than 0',
      'select_type': 'Select Type',
      'notes': 'Notes',
      'select_category': 'Select category',
      'fill_all_info': 'Please fill in all information.',
      'transaction_added': 'Transaction added successfully!',
      'cant_save_transaction': 'Cannot save transaction',
      'spending_limit_exceeded': 'Spending Limit Exceeded',
      'spending_limit_warning': 'Expense: {amount}\nPer-transaction limit: {limit}\nExceeded: {percent}% of the limit.\n\nDo you want to continue adding the transaction?',
      'later': 'Later',
      'continue_add': 'Continue Add',
      
      // Category Screen
      'categories': 'Categories',
      'add_category': 'Add New Category',
      'edit_category': 'Edit Category',
      'category_name': 'Category Name (can add emoji)',
      'category_name_hint': 'Example: 🍔 Food, 📱 Phone',
      'confirm_delete_category': 'Are you sure you want to delete this category?',
      'category_deleted': 'Category deleted',
      'category_added': 'Category added',
      'category_updated': 'Category updated',
      'enter_category_name': 'Please enter category name',
      'add_new_category': 'Add New Category',
      
      // Budget Screen
      'budgets': 'Budgets',
      'active': 'Active',
      'ended': 'Ended',
      'add_new_budget': 'Add New Budget',
      'select_category_for_budget': 'Please select a category',
      'budget_amount': 'Budget Amount',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'spent_today': 'Spent',
      'total_budget': 'Total Budget',
      'remaining': 'Remaining',
      'overspent': 'Overspent',
      'no_budgets_yet': 'You don\'t have any budgets yet',
      'no_ended_budgets': 'No ended budgets',
      'tap_plus_to_create': 'Tap + button to create a new budget',
      
      // Settings Screen
      'settings': 'Settings',
      'profile': 'Profile',
      'view_account_info': 'View your account information',
      'dark_mode': 'Dark Mode',
      'dark_mode_enabled': 'Dark mode enabled',
      'dark_mode_disabled': 'Light mode enabled',
      'notifications': 'Notifications',
      'notifications_subtitle': 'Receive notifications about budgets and expenses',
      'notifications_disabled': 'All notifications disabled',
      'language': 'Language',
      'currency': 'Currency',
      'security': 'Security',
      'security_subtitle': 'Manage password and privacy',
      'app_info': 'App Info',
      'app_info_subtitle': 'View information about this app',
      'wallet_management': 'Wallet Management',
      'wallet_management_subtitle': 'Add, edit or delete your wallets',
      'category_management': 'Category Management',
      'category_management_subtitle': 'Customize transaction types',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'logging_out': 'Logging out...',
      'language_changed': 'Changed to {language}',
      'currency_changed': 'Changed to {currency}',
      
      // Search Screen
      'search': 'Search',
      'search_by_notes': 'Search by notes',
      'search_enter_keywords': 'Enter keywords to search',
      'search_no_results': 'No results found for "{query}"',
      'search_try_different': 'Try searching with different keywords',
      'search_found_results': 'Found {count} result(s)',
      
      // Transaction Detail Screen
      'transaction_details': 'Transaction Details',
      'category': 'Category',
      'type': 'Type',
      'date': 'Date',
      'note': 'Note',
      
      // Profile Screen
      'edit_profile': 'Edit Profile',
      'display_name': 'Display Name',
      'gender': 'Gender',
      'date_of_birth': 'Date of Birth',
      'email': 'Email',
      'email_verified': 'Email Verified',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'profile_updated': 'Profile updated',
      'date_of_birth_updated': 'Date of birth updated',
      'user': 'User',
      'no_email': 'No email',
      'not_updated': 'Not updated',
      'verified': 'Verified',
      'not_verified': 'Not verified',
      'account_info': 'Account Information',
      'uid': 'UID',
      'account_created': 'Account Created',
      'last_login': 'Last Login',
      'gender_updated': 'Gender updated',
      'display_name_updated': 'Display name updated',
      
      // Login/Register Screen
      'login': 'Login',
      'register': 'Register',
      'email_label': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'login_with_google': 'Login with Google',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'register_success': 'Account created successfully. Please login.',
      'forgot_password_email_sent': 'Password reset instructions sent to: {email}',
      'password_reset_sent': 'Request sent',
      
      // Security Screen
      'security_privacy': 'Security & Privacy',
      'biometric_lock': 'Biometric Lock',
      'biometric_subtitle': 'Protect app with biometric authentication',
      'change_password': 'Change Password',
      'privacy_policy': 'Privacy Policy',
      'privacy_policy_subtitle': 'View detailed data security policy',
      
      // Change Password Screen
      'change_password_title': 'Change Password',
      'update_password': 'Update your password',
      'old_password': 'Old Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'password_changed': 'Password changed successfully!',
      
      // Forgot Password Screen
      'forgot_password_title': 'Forgot Password?',
      'forgot_password_subtitle': 'Enter your registered email to receive password recovery instructions.',
      'send_request': 'SEND REQUEST',
      'back_to_login': 'Back to Login',
      
      // App Info Screen
      'app_info_title': 'App Info',
      'app_subtitle': 'Smart Expense Management',
      'detail_info': 'Detail Information',
      'version': 'Version',
      'developer': 'Developer',
      'support_email': 'Support Email',
      'contact_copyright': 'Contact & Copyright',
      'copyright': '© 2025 MoneyWise',
    },
  };
  
  /// Helper method để format string với parameters
  String translateWithParams(String key, Map<String, String> params) {
    String text = translate(key);
    params.forEach((param, value) {
      text = text.replaceAll('{$param}', value);
    });
    return text;
  }
}

