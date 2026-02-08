import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'generating_viewmodel.dart';

class GeneratingView extends StackedView<GeneratingViewModel> {
  const GeneratingView({Key? key}) : super(key: key);

  static const Color _bgColor = Color(0xFF02213F);
  static const Color _accentGreen = Color(0xFF14932C);

  @override
  Widget builder(
    BuildContext context,
    GeneratingViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Subtle background circles matching splash aesthetic
          _buildBackground(size),

          // Earth at the bottom – same image as splash for visual continuity
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.asset(
              'assets/images/earf1.png',
              width: size.width,
              fit: BoxFit.fitHeight,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated plant icon
                    _PulsingIcon(hasError: viewModel.hasError),
                    const SizedBox(height: 36),

                    // Title
                    Text(
                      viewModel.hasError
                          ? 'Oops!'
                          : 'Growing your digital twin…',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status text
                    Text(
                      viewModel.generationStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Progress bar
                    if (!viewModel.hasError) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: viewModel.generationProgress / 3,
                          backgroundColor: Colors.white12,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(_accentGreen),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${viewModel.generationProgress} / 3 images',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -size.width * 0.5,
          child: Container(
            width: size.width * 2,
            height: size.width * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF022D48),
            ),
          ),
        ),
        Positioned(
          top: 280,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 1.6,
            height: size.width * 1.6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF083A5B),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(GeneratingViewModel viewModel) {
    viewModel.startGeneration();
  }

  @override
  GeneratingViewModel viewModelBuilder(BuildContext context) =>
      GeneratingViewModel();
}

/// A gently pulsing plant / error icon in a glowing circle.
class _PulsingIcon extends StatefulWidget {
  final bool hasError;
  const _PulsingIcon({required this.hasError});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (widget.hasError ? Colors.redAccent : const Color(0xFF14932C))
              .withOpacity(0.15),
        ),
        child: Icon(
          widget.hasError ? Icons.error_outline : Icons.eco_rounded,
          color: widget.hasError ? Colors.redAccent : const Color(0xFF14932C),
          size: 48,
        ),
      ),
    );
  }
}
