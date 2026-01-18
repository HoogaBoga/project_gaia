import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';
import 'package:project_gaia/ui/widgets/notification/notification_overlay.dart';
 
class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return _HomeContent(viewModel: viewModel);
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

class _HomeContent extends StatefulWidget {
  final HomeViewModel viewModel;
  const _HomeContent({required this.viewModel});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  
  // Adjusted duration to 2.5s to allow text to fade in AFTER earth lands
  static const Duration _totalDuration = Duration(milliseconds: 2500);

  static const Color _bgColor = Color(0xFF0A2342);
  static const Color _layerColor = Color(0xFF0F3057);
  static const Color _hpRed = Color(0xFFEF5350);
  static const Color _textWhite = Colors.white;

  late AnimationController _controller;
  late Animation<double> _layer1Anim;
  late Animation<double> _layer2Anim;
  late Animation<double> _layer3Anim;
  late Animation<double> _plantAnim;
  late Animation<double> _textOpacityAnim; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    const Curve smoothCurve = Cubic(0.17, 0.66, 0.34, .97);

    _layer1Anim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: smoothCurve),
    );

    _layer2Anim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.55, curve: smoothCurve),
    );

    _layer3Anim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.6, curve: smoothCurve),
    );

    _plantAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOutCubic),
    );

    _textOpacityAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _bgColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // --- Background Layers ---
              _buildBackgroundLayer(
                screenWidth: screenWidth,
                currentTop: _lerpY(screenHeight, widget.viewModel.layer1TargetY,
                    _layer1Anim.value),
                opacity: 0.4,
              ),
              _buildBackgroundLayer(
                screenWidth: screenWidth,
                currentTop: _lerpY(screenHeight, widget.viewModel.layer2TargetY,
                    _layer2Anim.value),
                opacity: 0.6,
              ),
              _buildBackgroundLayer(
                screenWidth: screenWidth,
                currentTop: _lerpY(screenHeight, widget.viewModel.layer3TargetY,
                    _layer3Anim.value),
                opacity: 0.8,
              ),

              // --- Main Content ---
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    

                    // --- Wrapped Text & HP Bar in FadeTransition ---
                    FadeTransition(
                      opacity: _textOpacityAnim,
                      child: Column(
                        children: [
                          Text(
                            widget.viewModel.plantName,
                            style: const TextStyle(
                              color: _textWhite,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.viewModel.plantSpecies,
                            style: const TextStyle(
                              color: _textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child:
                                _buildHpBar(widget.viewModel.currentHpPercent),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Transform.translate(
                        offset: Offset(0, 200 * (1 - _plantAnim.value)),
                        child: Opacity(
                          opacity: _plantAnim.value.clamp(0.0, 1.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/earf 1.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- NOTIFICATION WIDGETS ---

              // 1. Bell Button
              Positioned(
                top: 50,
                right: 24,
                child: GestureDetector(
                  // Assume viewModel has this method
                  onTap: widget.viewModel.toggleNotifications, 
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFa2e364),
                      size: 28,
                    ),
                  ),
                ),
              ),

              // 2. Overlay Container
              if (widget.viewModel.showNotificationsOverlay)
                Positioned(
                  top: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    // Now we pass the list of models from the ViewModel
                    child: NotificationsOverlayContainer(
                      notifications: widget.viewModel.notifications, 
                      onClearTapped: widget.viewModel.clearNotifications,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _lerpY(double start, double end, double t) {
    return start + (end - start) * t;
  }

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

  Widget _buildBackgroundLayer({
    required double screenWidth,
    required double currentTop,
    required double opacity,
  }) {
    final double circleDiameter = screenWidth * 2.5;

    return Positioned(
      top: currentTop,
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
}
