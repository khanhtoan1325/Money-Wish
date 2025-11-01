import 'package:expanse_management/domain/models/budget_model.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:expanse_management/services/notification_service.dart';
import 'package:expanse_management/data/utilty.dart';

class BudgetNotificationHelper {
  final NotificationService _notificationService = NotificationService();

  /// Kiểm tra và gửi thông báo budget warning
  Future<void> checkAndSendBudgetWarnings(
    List<BudgetWithId> budgets,
    List<TransactionWithId> transactions,
  ) async {
    final enabled = await _notificationService.isNotificationEnabled();
    if (!enabled) return;

    for (var budgetWithId in budgets) {
      final budget = budgetWithId.budget;
      final budgetAmount = int.tryParse(budget.amount) ?? 0;
      
      // Chỉ check budgets đang active
      if (budget.endDate.isBefore(DateTime.now())) {
        continue;
      }

      final spent = _calculateSpent(budget, transactions);
      final progress = budgetAmount > 0 ? (spent / budgetAmount) : 0.0;

      // Tạo unique ID cho mỗi budget
      final baseId = budgetWithId.id.hashCode.abs();

      // Kiểm tra từng mốc warning
      if (progress >= 1.0 && progress < 1.01) {
        // 100% - Chỉ gửi 1 lần
        await _notificationService.showNotification(
          id: NotificationService.budgetWarning100Id + baseId,
          title: '⚠️ Vượt quá ngân sách!',
          body: 'Bạn đã sử dụng hết ngân sách ${budget.category.title} (${formatCurrency(spent)}/${formatCurrency(budgetAmount)})',
          payload: 'budget_warning_100_${budgetWithId.id}',
        );
      } else if (progress >= 0.9 && progress < 1.0) {
        // 90%
        await _notificationService.showNotification(
          id: NotificationService.budgetWarning90Id + baseId,
          title: '⚠️ Cảnh báo ngân sách!',
          body: 'Ngân sách ${budget.category.title} còn ${((1 - progress) * 100).toStringAsFixed(0)}% (${formatCurrency(budgetAmount - spent)} còn lại)',
          payload: 'budget_warning_90_${budgetWithId.id}',
        );
      } else if (progress >= 0.8 && progress < 0.9) {
        // 80%
        await _notificationService.showNotification(
          id: NotificationService.budgetWarning80Id + baseId,
          title: '📊 Chú ý chi tiêu',
          body: 'Bạn đã dùng ${(progress * 100).toStringAsFixed(0)}% ngân sách ${budget.category.title} (Còn lại: ${formatCurrency(budgetAmount - spent)})',
          payload: 'budget_warning_80_${budgetWithId.id}',
        );
      }

      // Kiểm tra budget hết hạn sắp tới (3 ngày)
      final daysUntilEnd = budget.endDate.difference(DateTime.now()).inDays;
      if (daysUntilEnd == 3 && daysUntilEnd > 0) {
        await _notificationService.showNotification(
          id: NotificationService.budgetExpiredId + baseId,
          title: '⏰ Ngân sách sắp hết hạn',
          body: 'Ngân sách ${budget.category.title} sẽ hết hạn trong $daysUntilEnd ngày. Còn lại ${formatCurrency(budgetAmount - spent)}',
          payload: 'budget_expiring_${budgetWithId.id}',
        );
      }

      // Kiểm tra budget hết hạn
      if (daysUntilEnd == 0) {
        await _notificationService.showNotification(
          id: NotificationService.budgetExpiredId + baseId + 1,
          title: '📅 Ngân sách đã hết hạn',
          body: 'Ngân sách ${budget.category.title} đã hết hạn. Tổng chi tiêu: ${formatCurrency(spent)}',
          payload: 'budget_expired_${budgetWithId.id}',
        );
      }

      // Thông báo đạt mục tiêu tiết kiệm (spent < 90% budget)
      if (progress < 0.9 && progress > 0.5) {
        final savedAmount = budgetAmount - spent;
        if (savedAmount > 0 && savedAmount >= budgetAmount * 0.1) {
          await _notificationService.showNotification(
            id: NotificationService.budgetWarning100Id + baseId + 1000,
            title: '🎉 Tuyệt vời!',
            body: 'Bạn đã tiết kiệm được ${formatCurrency(savedAmount)} trong ngân sách ${budget.category.title}',
            payload: 'budget_achievement_${budgetWithId.id}',
          );
        }
      }
    }
  }

  /// Tính tổng chi tiêu cho một budget
  int _calculateSpent(Budget budget, List<TransactionWithId> transactions) {
    int total = 0;
    for (var txWithId in transactions) {
      final tx = txWithId.transaction;
      if (tx.type == 'Expense' &&
          tx.category.title == budget.category.title &&
          tx.createAt.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
          tx.createAt.isBefore(budget.endDate.add(const Duration(days: 1)))) {
        total += int.tryParse(tx.amount) ?? 0;
      }
    }
    return total;
  }

  /// Lên lịch daily reminder
  Future<void> scheduleDailyReminder() async {
    final enabled = await _notificationService.isNotificationEnabled();
    if (!enabled) return;

    // Lên lịch vào 21:00 hàng ngày
    await _notificationService.scheduleDailyNotification(
      id: NotificationService.dailyReminderId,
      title: '📝 Nhớ ghi chép chi tiêu hôm nay',
      body: 'Đừng quên thêm các khoản chi tiêu vào app để theo dõi chính xác!',
      time: Time(21, 0), // 21:00
    );
  }

  /// Lên lịch weekly summary
  Future<void> scheduleWeeklySummary() async {
    final enabled = await _notificationService.isNotificationEnabled();
    if (!enabled) return;

    // Lên lịch vào Chủ nhật 20:00
    await _notificationService.scheduleWeeklyNotification(
      id: NotificationService.weeklySummaryId,
      title: '📊 Tổng kết tuần',
      body: 'Xem lại chi tiêu của tuần vừa qua trong ứng dụng!',
      day: Day.sunday,
      time: Time(20, 0), // 20:00 Chủ nhật
    );
  }

  /// Kiểm tra và gửi thông báo chi tiêu bất thường
  Future<void> checkUnusualSpending(
    List<TransactionWithId> transactions,
    Budget? budget,
  ) async {
    final enabled = await _notificationService.isNotificationEnabled();
    if (!enabled) return;

    // Tính chi tiêu 7 ngày gần nhất
    final last7Days = transactions.where((tx) {
      return tx.transaction.type == 'Expense' &&
          tx.transaction.createAt.isAfter(
            DateTime.now().subtract(const Duration(days: 7)),
          );
    }).toList();

    if (last7Days.isEmpty) return;

    // Tính trung bình chi tiêu trong 7 ngày
    final total7Days = last7Days.fold<int>(
      0,
      (sum, tx) => sum + (int.tryParse(tx.transaction.amount) ?? 0),
    );
    final average = total7Days / 7;

    // Tính chi tiêu hôm nay
    final today = DateTime.now();
    final todaySpending = transactions.where((tx) {
      final txDate = tx.transaction.createAt;
      return tx.transaction.type == 'Expense' &&
          txDate.day == today.day &&
          txDate.month == today.month &&
          txDate.year == today.year;
    }).toList();

    final todayTotal = todaySpending.fold<int>(
      0,
      (sum, tx) => sum + (int.tryParse(tx.transaction.amount) ?? 0),
    );

    // Cảnh báo nếu hôm nay chi tiêu cao hơn 150% trung bình
    if (average > 0 && todayTotal > average * 1.5 && todayTotal > 0) {
      final percentage = ((todayTotal / average) * 100).toStringAsFixed(0);
      await _notificationService.showNotification(
        id: 5000, // Unique ID cho unusual spending
        title: '🔥 Chi tiêu bất thường',
        body: 'Hôm nay bạn chi ${formatCurrency(todayTotal)}, cao hơn $percentage% so với trung bình!',
        payload: 'unusual_spending',
      );
    }
  }

  /// Khởi tạo tất cả scheduled notifications
  Future<void> initializeAllScheduledNotifications() async {
    await scheduleDailyReminder();
    await scheduleWeeklySummary();
  }
}


