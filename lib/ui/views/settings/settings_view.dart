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
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
        color: const Color(0xFF143F80),
        child: 
            Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                        children: [
                            // HEADER
                            const Text(
                                "Settings",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    color: Colors.white,
                                )
                            ),
                            const SizedBox(height: 15),
                            const CircleAvatar(
                                radius: 100.0,
                                backgroundColor: Colors.grey,
                                child: Placeholder() // TODO : CHANGE TO AVATAR 
                            ),
                            const SizedBox(height: 15),
                            const Text(
                                "Pangalan sa plant",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Colors.white,
                                )
                            ),
                            const Text(
                                "Personality sa plant",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Color(0xFF7D7D7D),
                                )
                            ),
                            const SizedBox(height: 20),
                            // EDIT PLANT INFORMATION
                            ElevatedButton(
                                onPressed: () { 
                                    viewModel.navigateToEditPlantInformation();
                                }, 
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF02213F),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                ),
                                child: const Row(
                                    children: [
                                        Padding(
                                            padding: EdgeInsets.only(right: 20),
                                            child: ImageIcon(
                                                color: Color(0xFF14932C),
                                                AssetImage(
                                                    'assets/images/edit_plant_information_icon.png',
                                                ),
                                                size: 30.0,
                                            ),
                                        ),
                                        Expanded(
                                            child: Text(
                                                'Edit plant information',
                                                style: TextStyle(fontSize: 18),
                                            ),
                                        ),
                                        Icon(
                                            Icons.chevron_right,
                                            size: 46,
                                        ),
                                    ]
                                ),
                            ),
                            const SizedBox(height: 22.5),
                            // DELETE PLANT
                            ElevatedButton(
                                onPressed: () { 
                                    viewModel.navigateToDeletePlant();
                                }, 
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF02213F),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                ),
                                child: const Row(
                                    children: [
                                        Padding(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Icon(
                                                Icons.delete,
                                                size: 38,
                                                color: Colors.red,
                                            )
                                        ),
                                        Expanded(
                                            child: Text(
                                                'Delete plant',
                                                style: TextStyle(fontSize: 18),
                                            ),
                                        ),
                                        Icon(
                                            Icons.chevron_right,
                                            size: 46,
                                        ),
                                    ]
                                ),
                            ),
                        ]
                    ),
                ),
            ),
        ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SettingsViewModel();
}
