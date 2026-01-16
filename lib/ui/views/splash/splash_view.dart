import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'splash_viewmodel.dart';

class SplashView extends StackedView<SplashViewModel> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, SplashViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFF02213F),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _buildVibrantBackground(context),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/earf.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildInputField(viewModel),
                const SizedBox(height: 20),
                _buildNextButton(viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibrantBackground(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: 140,
          left: -screenWidth * 0.5,
          child: Container(
            width: screenWidth * 2,
            height: screenWidth * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF022D48),
            ),
          ),
        ),
        Positioned(
          top: 320,
          left: -screenWidth * 0.3,
          child: Container(
            width: screenWidth * 1.6,
            height: screenWidth * 1.6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF083A5B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'To begin, take an image of your plant or manually enter the plant species!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 30,
          height: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInputField(SplashViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.plantSpeciesController,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Plant species here...',
                  hintStyle: TextStyle(color: Color(0xFF7D7D7D)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
                onChanged: viewModel.onPlantSpeciesChanged,
              ),
            ),
            IconButton(
              onPressed: viewModel.openCamera,
              icon: const Icon(
                Icons.camera_alt,
                color: Color(0xFF14932C),
                size: 30,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(SplashViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: viewModel.canProceed ? viewModel.navigateToNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14932C),
            disabledBackgroundColor: const Color(0xFF14932C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: viewModel.isBusy
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  SplashViewModel viewModelBuilder(BuildContext context) => SplashViewModel();
}