import 'package:flutter/material.dart';
import 'package:project_gaia/ui/common/app_colors.dart';
import 'package:project_gaia/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'delete_plant_dialog_model.dart';

class DeletePlantDialog extends StackedView<DeletePlantDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const DeletePlantDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeletePlantDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xFF02213F),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        request.title ?? 'Delete Plant',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      verticalSpaceTiny,
                      Text(
                        request.description ?? 'Are you sure?',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,
            Row(
              children: [
                Expanded(child:
                  GestureDetector(
                    onTap: () => completer(DialogResponse(confirmed: true)),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        request.mainButtonTitle ?? 'Delete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(child:
                  GestureDetector(
                    onTap: () => completer(DialogResponse(confirmed: false)),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        request.secondaryButtonTitle ?? 'Cancel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }

  @override
  DeletePlantDialogModel viewModelBuilder(BuildContext context) =>
      DeletePlantDialogModel();
}
