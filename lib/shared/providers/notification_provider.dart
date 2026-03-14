import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>>(
  NotificationNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationProvider)
      .maybeWhen(data: (list) => list.where((n) => !n.isRead).length, orElse: () => 0);
});

class NotificationNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    // Return mock data until real API is connected
    return [];
  }

  void markRead(String id) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  void markAllRead() {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.map((n) => n.copyWith(isRead: true)).toList());
  }
}
