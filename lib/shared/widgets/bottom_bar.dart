import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

class BottomDestination {
  const BottomDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class EpicyclicBottomBar extends StatelessWidget {
  const EpicyclicBottomBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<BottomDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _Destination(
                    destination: destinations[index],
                    selected: index == selectedIndex,
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final BottomDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.primary : palette.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            destination.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

const homeDestination = BottomDestination(
  icon: Icons.home_outlined,
  selectedIcon: Icons.home_rounded,
  label: 'Home',
);
const categoriesDestination = BottomDestination(
  icon: Icons.grid_view_outlined,
  selectedIcon: Icons.grid_view_rounded,
  label: 'Categories',
);
const wishlistDestination = BottomDestination(
  icon: Icons.favorite_border_rounded,
  selectedIcon: Icons.favorite_rounded,
  label: 'Wishlist',
);
const profileDestination = BottomDestination(
  icon: Icons.person_outline_rounded,
  selectedIcon: Icons.person_rounded,
  label: 'Profile',
);
const ordersDestination = BottomDestination(
  icon: Icons.receipt_long_outlined,
  selectedIcon: Icons.receipt_long_rounded,
  label: 'Orders',
);
