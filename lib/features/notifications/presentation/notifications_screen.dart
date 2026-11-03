import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/bottom_bar.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/ui_helpers.dart';
import '../../orders/domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider);
    final isDemo = ref.watch(appConfigProvider).isDemo;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: user == null
            ? EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Sign in for updates',
                message: 'Order updates and account messages appear here when you are signed in.',
                actionLabel: 'Sign in',
                onAction: () => context.push('/login?next=/notifications'),
              )
            : notifications.when(
                loading: () => const AppLoading(),
                error: (error, stackTrace) => AppErrorState(
                  message: 'Notifications are unavailable right now.',
                  onRetry: () => ref.invalidate(notificationsProvider),
                ),
                data: (items) {
                  final now = DateTime.now();
                  final today = items
                      .where((item) => _sameDay(item.createdAt, now))
                      .toList();
                  final earlier = items
                      .where((item) => !_sameDay(item.createdAt, now))
                      .toList();
                  final unread = items.where((item) => !item.read).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.canPop()
                                      ? context.pop()
                                      : context.go('/profile'),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 36,
                                    height: 44,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Notifications',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (unread > 0)
                                  TextButton(
                                    onPressed: () async {
                                      await ref
                                          .read(orderRepositoryProvider)
                                          .markAllNotificationsRead();
                                      ref.invalidate(notificationsProvider);
                                    },
                                    child: const Text('Mark all read'),
                                  ),
                              ],
                            ),
                            if (isDemo)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: DemoModeChip(),
                              ),
                            const SizedBox(height: 14),
                            if (items.isEmpty)
                              EmptyState(
                                icon: Icons.notifications_none_rounded,
                                title: 'All caught up',
                                message: 'Order and account updates will show up here.',
                                actionLabel: 'Continue shopping',
                                onAction: () => context.go('/home'),
                              )
                            else ...[
                              if (today.isNotEmpty) ...[
                                Text(
                                  'Today',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                for (final item in today)
                                  _NotificationTile(
                                    notification: item,
                                    group: _groupLabel(item),
                                  ),
                                const SizedBox(height: 18),
                              ],
                              if (earlier.isNotEmpty) ...[
                                Text(
                                  'Earlier',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                for (final item in earlier)
                                  _NotificationTile(
                                    notification: item,
                                    group: _groupLabel(item),
                                  ),
                              ],
                              if (isDemo) ...[
                                const SizedBox(height: 14),
                                const DemoNotice(
                                  message: 'Demo notifications are generated by local events. No push delivery service is connected.',
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: EpicyclicBottomBar(
        destinations: const [
          homeDestination,
          categoriesDestination,
          wishlistDestination,
          profileDestination,
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/categories');
            case 2:
              context.go('/wishlist');
            case 3:
              context.go('/profile');
          }
        },
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _groupLabel(AppNotification item) {
    final now = DateTime.now();
    if (_sameDay(item.createdAt, now)) return formatTime(item.createdAt);
    final yesterday = now.subtract(const Duration(days: 1));
    if (_sameDay(item.createdAt, yesterday)) return 'Yesterday';
    return formatShortDate(item.createdAt);
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification, required this.group});

  final AppNotification notification;
  final String group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final isOrder = notification.type == AppNotificationType.order;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: notification.orderId == null
            ? null
            : () => context.push('/orders/${notification.orderId}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.primarySoft.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOrder
                      ? Icons.inventory_2_outlined
                      : Icons.auto_awesome_outlined,
                  size: 23,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: notification.read
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          group,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (!notification.read) ...[
                          const SizedBox(width: 7),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: palette.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
