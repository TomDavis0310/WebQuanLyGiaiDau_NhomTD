import 'dart:ui';
import 'package:flutter/material.dart';

class MagnifyingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<IconData> icons;
  final double height;
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const MagnifyingNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.icons,
    this.height = 80,
    this.backgroundColor = const Color(0xFFFCFCFC),
    this.selectedItemColor = Colors.red,
    this.unselectedItemColor = Colors.black54,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width / icons.length;
    // Lens dimensions based on CSS: width 3rem (~48px), height 5rem (~80px)
    // But we need to adapt to screen. Let's say lens width is slightly smaller than item width or fixed.
    // The CSS says width: 3rem; height: 5rem;
    const double lensWidth = 60.0;
    const double lensHeight = 60.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Lens (Anchored Pointer)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut, // Simulating the spring easing
            left: (itemWidth * selectedIndex) + (itemWidth / 2) - (lensWidth / 2),
            top: (height - lensHeight) / 2, // Center vertically or adjust as needed
            child: _buildLens(lensWidth, lensHeight),
          ),
          
          // The Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: height,
                    child: Center(
                      child: AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          icons[index],
                          color: isSelected ? selectedItemColor : unselectedItemColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLens(double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Glass effect
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          // Add the radial gradient effect from CSS if possible
          child: Container(
             decoration: BoxDecoration(
               gradient: RadialGradient(
                 center: const Alignment(0, 0.8),
                 radius: 0.8,
                 colors: [
                   Colors.transparent,
                   Colors.white.withOpacity(0.2),
                 ],
               ),
             ),
          ),
        ),
      ),
    );
  }
}
