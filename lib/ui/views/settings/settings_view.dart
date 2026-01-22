import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          _buildVibrantBackground(context),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(25.0),
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    const Text(
                      "Settings",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const CircleAvatar(
                      radius: 100.0,
                      backgroundColor: Colors.grey,
                      child: Placeholder(),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      viewModel.plantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      viewModel.species,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Color(0xFF7D7D7D),
                      ),
                    ),
                    Text(
                      "Personality: ${viewModel.personality}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Color(0xFF7D7D7D),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      label: 'Edit plant information',
                      icon: const ImageIcon(
                        AssetImage(
                            'assets/images/edit_plant_information_icon.png'),
                        color: Color(0xFF14932C),
                        size: 30.0,
                      ),
                      onPressed: viewModel.navigateToEditPlantInformation,
                    ),
                    const SizedBox(height: 22.5),
                    _buildMenuButton(
                      label: 'Delete plant',
                      icon:
                          const Icon(Icons.delete, size: 38, color: Colors.red),
                      onPressed: viewModel.openDeletePlantDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF02213F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: icon,
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Icon(Icons.chevron_right, size: 46),
        ],
      ),
    );
  }

  Widget _buildVibrantBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final baseWidth = size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        _buildSphere(baseWidth * 2.8, const Color(0xFF02213F),
            top: -baseWidth * 0.2),
        _buildSphere(baseWidth * 2.2, const Color(0xFF022D48),
            top: baseWidth * 0.1),
        _buildSphere(baseWidth * 1.6, const Color(0xFF083A5B),
            top: baseWidth * 0.4),
        _buildSphere(baseWidth * 1.4, const Color(0xFF143F80),
            top: baseWidth * 0.7),
      ],
    );
  }

  Widget _buildSphere(double diameter, Color color, {double? top}) {
    return Positioned(
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();
}
