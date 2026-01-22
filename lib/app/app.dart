import 'package:project_gaia/services/gemini_service.dart';
import 'package:project_gaia/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:project_gaia/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:project_gaia/ui/views/home/home_view.dart';
import 'package:project_gaia/ui/views/startup/startup_view.dart';
import 'package:project_gaia/ui/views/mainlayout/main_layout.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:project_gaia/ui/views/splash/splash_view.dart';
import 'package:project_gaia/ui/views/splash/splash_viewmodel.dart';

import 'package:project_gaia/ui/views/edit_plant/edit_plant_view.dart';
import 'package:project_gaia/ui/dialogs/delete_plant/delete_plant_dialog.dart';
import 'package:project_gaia/services/firebase_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: SplashView),
    MaterialRoute(page: MainLayout, initial: true),
    MaterialRoute(page: EditPlantView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: FirebaseService),
    LazySingleton(classType: GeminiService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: DeletePlantDialog),
// @stacked-dialog
  ],
)
class App {}
