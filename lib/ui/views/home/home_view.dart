import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  // Color Palette extracted from the reference image
  static const Color _bgColor = Color(0xFF0A2342);
  static const Color _layerColor = Color(0xFF0F3057);
  static const Color _hpRed = Color(0xFFEF5350);
  static const Color _textWhite = Colors.white;

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ================= Background Animatable Layers =================
          // We use huge circles positioned far off-screen to create the curved
          // arc horizons. Their 'top' property is bound to the ViewModel for animation.
          _buildBackgroundLayer(
              screenWidth: screenWidth,
              topOffset: viewModel.layer1Offset,
              opacity: 0.4),
          _buildBackgroundLayer(
              screenWidth: screenWidth,
              topOffset: viewModel.layer2Offset,
              opacity: 0.6),
          _buildBackgroundLayer(
              screenWidth: screenWidth,
              topOffset: viewModel.layer3Offset,
              opacity: 0.8),

          // ================= Main Foreground Content =================
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // --- Plant Name ---
                Text(
                  viewModel.plantName,
                  style: const TextStyle(
                    color: _textWhite,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // --- Plant Species ---
                Text(
                  viewModel.plantSpecies,
                  style: const TextStyle(
                    color: _textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 25),
                // --- HP Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: _buildHpBar(viewModel.currentHpPercent),
                ),

                // --- Main Focal Image (Plant & Earth) ---
                // Using Expanded to push it towards the bottom relative to header
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    // REPLACE this with your actual image asset path
                    child: Image.asset(
                      'assets/images/plant_earth_placeholder.png',
                      fit: BoxFit.contain,
                      // Ensure image doesn't touch the very bottom edge
                      // based on the reference.
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                 // Slight padding at bottom to match reference before nav bar area
                 const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the custom rounded HP bar
  Widget _buildHpBar(double percentage) {
    const double barHeight = 16.0;
    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _textWhite,
        borderRadius: BorderRadius.circular(barHeight / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: _hpRed,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the background "circle gradient" layers
  Widget _buildBackgroundLayer({
    required double screenWidth,
    required double topOffset,
    required double opacity,
  }) {
    // To get the gentle arc look, the circle needs to be much larger than the screen
    final double circleDiameter = screenWidth * 2.5;

    return Positioned(
      top: topOffset,
      // Center horizontally by offsetting left by half difference between width and diameter
      left: (screenWidth - circleDiameter) / 2,
      child: Container(
        width: circleDiameter,
        height: circleDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _layerColor.withOpacity(opacity),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.initialise();
}
