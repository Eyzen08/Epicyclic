import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/epicyclic_logo.dart';
import '../../../shared/widgets/ui_helpers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your cart and wishlist stay on this device. You will need to sign in again to see orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(profileProvider);
    ref.invalidate(addressesProvider);
    ref.invalidate(ordersProvider);
    ref.invalidate(notificationsProvider);
    if (!context.mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDemo = ref.watch(appConfigProvider).isDemo;
    final addresses = ref.watch(addressesProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    String? defaultAddress;
    if (user != null) {
      addresses.whenData((items) {
        for (final address in items) {
          if (address.isDefault) {
            defaultAddress =
                '${address.line1}, ${address.city}, ${address.state}';
          }
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const EpicyclicLogo(markSize: 32, textSize: 23),
                      const SizedBox(width: 8),
                      if (isDemo) const DemoModeChip(compact: true),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined, size: 25),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 18),
                  if (user == null)
                    _GuestCard(
                      onSignIn: () => context.push('/login?next=/profile'),
                      onCreate: () => context.go('/signup'),
                    )
                  else
                    _UserCard(
                      initials: user.initials,
                      name: user.fullName,
                      email: user.email,
                      onEdit: () => context.push('/edit-profile'),
                    ),
                  const SizedBox(height: 16),
                  if (user != null) ...[
                    _MenuGroup(
                      children: [
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Personal Information',
                          onTap: () => context.push('/edit-profile'),
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Saved Addresses',
                          subtitle:
                              defaultAddress ??
                              'Add a delivery address for faster checkout',
                          onTap: () => context.push('/addresses'),
                        ),
                        _MenuItem(
                          icon: Icons.credit_card_outlined,
                          label: 'Payment Methods',
                          onTap: () => context.push('/payment-methods'),
                        ),
                        _MenuItem(
                          icon: Icons.inventory_2_outlined,
                          label: 'Order History',
                          onTap: () => context.push('/orders'),
                        ),
                        _MenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          trailingBadge: unread > 0 ? '$unread' : null,
                          onTap: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  _MenuGroup(
                    children: [
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        onTap: () => context.go('/wishlist'),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => context.push('/settings'),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () => context.push('/help'),
                      ),
                    ],
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 12),
                    _MenuGroup(
                      children: [
                        _MenuItem(
                          icon: Icons.logout_rounded,
                          label: 'Sign Out',
                          danger: true,
                          onTap: () => _signOut(context, ref),
                        ),
                      ],
                    ),
                  ],
                  if (isDemo) ...[
                    const SizedBox(height: 18),
                    const DemoNotice(
                      message: 'Demo mode: profile, addresses, and orders are stored locally on this device. No live account exists.',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.onEdit,
  });

  final String initials;
  final String name;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onEdit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              backgroundColor: palette.primarySoft,
              foregroundColor: palette.primary,
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.onSignIn, required this.onCreate});

  final VoidCallback onSignIn;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: palette.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Epicyclic',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sign in to save your setup and track orders.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onSignIn, child: const Text('Sign In')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onCreate,
            child: const Text('Create An Account'),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              Divider(color: palette.border, height: 1, indent: 54),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingBadge,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingBadge;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = danger ? palette.danger : palette.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingBadge != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trailingBadge!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: palette.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
