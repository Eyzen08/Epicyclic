import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/epicyclic_logo.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;
}

const _pages = [
  _OnboardingPage(
    image: 'assets/images/banners/hero_onboarding.png',
    title: 'Build Your Ideal Setup',
    body: 'Discover trusted gear for work, play, and everything in between.',
  ),
  _OnboardingPage(
    image: 'assets/images/banners/onboarding_keys.png',
    title: 'Gear That Clicks',
    body: 'Mechanical keyboards, precision mice, and desk essentials picked for how you play.',
  ),
  _OnboardingPage(
    image: 'assets/images/banners/onboarding_audio.png',
    title: 'Hear Every Detail',
    body: 'Studio-ready audio and comfortable headsets for long sessions and late-night queues.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  Future<void> _finish({required bool goToLogin}) async {
    await ref.read(localStoreProvider).setOnboardingSeen(true);
    if (!mounted) return;
    context.go(goToLogin ? '/login' : '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      const EpicyclicLogo(markSize: 32, textSize: 24),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _finish(goToLogin: false),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (index) => setState(() => _index = index),
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  page.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontSize: 29),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                page.body,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: palette.textSecondary,
                                      height: 1.55,
                                      fontSize: 14.5,
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? palette.primary
                                : palette.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: () {
                      if (isLast) {
                        _finish(goToLogin: true);
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Text(isLast ? 'Get Started' : 'Continue'),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
