import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'edit_plant_viewmodel.dart';

class EditPlantView extends StackedView<EditPlantViewModel> {
  const EditPlantView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(EditPlantViewModel viewModel) {
    viewModel.initialize();
  }

  @override
  Widget builder(
    BuildContext context,
    EditPlantViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF02213F),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildVibrantBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            "Edit Plant Information",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Name Input Field
                      const Text(
                        "Plant Name",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: viewModel.nameController,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Enter plant name...',
                            hintStyle: TextStyle(color: Color(0xFF7D7D7D)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Personality Dropdown
                      const Text(
                        "Personality",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: viewModel.selectedPersonality,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF14932C)),
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            dropdownColor: Colors.white,
                            items: viewModel.personalities.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: viewModel.onPersonalityChanged,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: viewModel.saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14932C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: viewModel.isBusy
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  EditPlantViewModel viewModelBuilder(BuildContext context) => EditPlantViewModel();

  // --- Background Widgets (Same as provided) ---

  Widget _buildVibrantBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final baseWidth = size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        _buildSphere(baseWidth * 2.8, const Color(0xFF02213F), top: -baseWidth * 0.2),
        _buildSphere(baseWidth * 2.2, const Color(0xFF022D48), top: baseWidth * 0.1),
        _buildSphere(baseWidth * 1.6, const Color(0xFF083A5B), top: baseWidth * 0.4),
        _buildSphere(baseWidth * 1.4, const Color(0xFF143F80), top: baseWidth * 0.7),
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
}
