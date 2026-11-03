import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/ui_helpers.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SupportScaffold(
      title: 'Help & Support',
      children: [
        const DemoNotice(
          message: 'This is a portfolio build. Support, returns, and warranties are described for demonstration only; there is no live support desk.',
        ),
        const SizedBox(height: 18),
        Text(
          'Frequently Asked',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        const _Faq(
          question: 'Where is my order?',
          answer: 'Open Order history from your profile and choose an order to see its tracking timeline. Demo orders never ship.',
        ),
        const _Faq(
          question: 'How do returns work?',
          answer: 'The catalog advertises a 30-day return window. This build does not implement a returns workflow or carrier labels.',
        ),
        const _Faq(
          question: 'Is checkout secure?',
          answer: 'No card details are collected in this build. Demo checkout stores an order locally; Supabase mode records an order without capturing payment.',
        ),
        const _Faq(
          question: 'Does my data sync across devices?',
          answer: 'Only when APP_MODE=supabase is configured and you sign in. Otherwise profile, orders, wishlist, and cart remain on this device.',
        ),
        const _Faq(
          question: 'How do I change the theme?',
          answer: 'Open Profile then Settings. Theme choice is saved on this device.',
        ),
      ],
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _SupportScaffold(
      title: 'Privacy & Security',
      children: [
        Text(
          'What Is Stored',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Cart, wishlist, theme, notification preferences, and onboarding state are stored locally with SharedPreferences. Profile, addresses, and orders are stored locally in demo mode, or in Supabase when configured.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: palette.textSecondary, height: 1.65),
        ),
        const SizedBox(height: 18),
        Text('Credentials', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'The client reads only the Supabase anon key through compile-time --dart-define values. Service-role keys, database passwords, and payment secrets are never included in the app.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: palette.textSecondary, height: 1.65),
        ),
        const SizedBox(height: 18),
        Text('Payments', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'No payment processor is integrated. Checkout records a selected payment method but never collects card numbers.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: palette.textSecondary, height: 1.65),
        ),
        const SizedBox(height: 18),
        Text('Deleting Data', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Clearing app storage removes local demo data. Supabase data is governed by the project database and row-level security policies provided in supabase/migrations.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: palette.textSecondary, height: 1.65),
        ),
        const SizedBox(height: 18),
        const DemoNotice(
          message: 'This app is a portfolio project. Review the repository docs before using it with production customer data.',
        ),
      ],
    );
  }
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _SupportScaffold(
      title: 'Payment Methods',
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_off_outlined,
                  size: 30,
                  color: palette.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Saved Payment Methods',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'This build does not collect or store card details. Checkout records the method you choose so the order can be reviewed.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: palette.textSecondary, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InfoBanner(
          message: 'To take real payments, integrate a PCI-compliant provider and tokenize cards server-side. Never store raw card data in the app or database.',
          icon: Icons.shield_outlined,
          tone: InfoTone.warning,
        ),
        const SizedBox(height: 18),
        Text(
          'Supported At Checkout',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        _MethodRow(
          icon: Icons.account_balance_wallet_rounded,
          title: 'GCash',
          subtitle: 'Demo selection only — no e-wallet is charged',
        ),
        const SizedBox(height: 10),
        _MethodRow(
          icon: Icons.payments_rounded,
          title: 'Maya',
          subtitle: 'Demo selection only — no e-wallet is charged',
        ),
        const SizedBox(height: 10),
        _MethodRow(
          icon: Icons.local_shipping_outlined,
          title: 'Cash On Delivery',
          subtitle: 'Demo selection only — no rider is dispatched',
        ),
        const SizedBox(height: 10),
        _MethodRow(
          icon: Icons.account_balance_outlined,
          title: 'Bank Transfer',
          subtitle: 'Demo selection only — no bank details are collected',
        ),
        const SizedBox(height: 10),
        _MethodRow(
          icon: Icons.credit_card_rounded,
          title: 'Credit Or Debit Card',
          subtitle: 'Demo selection only — card fields are not implemented',
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: palette.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Text(question, style: Theme.of(context).textTheme.titleSmall),
        iconColor: palette.primary,
        collapsedIconColor: palette.textSecondary,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportScaffold extends StatelessWidget {
  const _SupportScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width >= 768 ? 32 : 24,
            8,
            MediaQuery.sizeOf(context).width >= 768 ? 32 : 24,
            30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(
                    title: title,
                    padding: EdgeInsets.zero,
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go('/profile'),
                  ),
                  const SizedBox(height: 22),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
