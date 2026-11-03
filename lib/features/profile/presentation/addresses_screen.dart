import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/address.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final user = ref.watch(currentUserProvider);
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(
                    title: 'Saved Addresses',
                    padding: EdgeInsets.zero,
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go('/profile'),
                  ),
                  const SizedBox(height: 18),
                  if (user == null)
                    EmptyState(
                      icon: Icons.location_on_outlined,
                      title: 'Sign In First',
                      message: 'Addresses are linked to your account and available after sign-in.',
                      actionLabel: 'Sign In',
                      onAction: () => context.push('/login?next=/addresses'),
                    )
                  else
                    addresses.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: AppLoading(),
                      ),
                      error: (error, stackTrace) => AppErrorState(
                        message: 'We could not load your addresses.',
                        onRetry: () => ref.invalidate(addressesProvider),
                      ),
                      data: (items) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (items.isEmpty)
                              EmptyState(
                                icon: Icons.add_location_alt_outlined,
                                title: 'No Addresses Yet',
                                message: 'Add a delivery address to speed up checkout.',
                                actionLabel: 'Add Address',
                                onAction: () => context.push('/addresses/edit'),
                              )
                            else ...[
                              for (final address in items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _AddressCard(
                                    address: address,
                                    onEdit: () => context.push(
                                      '/addresses/edit?id=${address.id}',
                                    ),
                                    onDelete: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Address?'),
                                          content: Text(
                                            'Remove the address for ${address.fullName}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: palette.danger,
                                                minimumSize: const Size(0, 44),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed != true) return;
                                      await ref
                                          .read(profileRepositoryProvider)
                                          .deleteAddress(address.id);
                                      ref.invalidate(addressesProvider);
                                    },
                                    onSetDefault: () async {
                                      await ref
                                          .read(profileRepositoryProvider)
                                          .setDefaultAddress(address.id);
                                      ref.invalidate(addressesProvider);
                                    },
                                  ),
                                ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    context.push('/addresses/edit'),
                                icon: const Icon(
                                  Icons.add_location_alt_outlined,
                                  size: 19,
                                ),
                                label: const Text('Add Another Address'),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: address.isDefault ? palette.primary : palette.border,
          width: address.isDefault ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: palette.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.fullName,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: palette.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.multiLine.split('\n').skip(1).join('\n'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 3),
          Text(address.phone, style: Theme.of(context).textTheme.bodySmall),
          Divider(color: palette.border, height: 24),
          Row(
            children: [
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Edit'),
              ),
              const SizedBox(width: 18),
              if (!address.isDefault)
                TextButton(
                  onPressed: onSetDefault,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Set As Default'),
                ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: palette.textSecondary,
                ),
                tooltip: 'Delete address',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
