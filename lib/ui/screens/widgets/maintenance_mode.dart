
import 'package:an3am/ui/theme/theme.dart';
import 'package:an3am/utils/app_icon.dart';
import 'package:an3am/utils/constant.dart';
import 'package:an3am/utils/custom_text.dart';
import 'package:an3am/utils/extensions/extensions.dart';
import 'package:an3am/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MaintenanceMode extends StatelessWidget {
  const MaintenanceMode({super.key});
  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return const MaintenanceMode();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie.asset(
          //   "assets/lottie/${Constant.maintenanceModeLottieFile}",
          // ),
          // Image.asset(
          //   'assets/lottie/maintenance.svg',
          //   fit: BoxFit.cover,
          // ),
          UiUtils.getSvg("assets/svg/maintenance.svg"),
          SizedBox(height: 30,),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50 , ),
              child: CustomText("maintenanceModeMessage".translate(context),
                  color: Color(0xff03033e),
                  textAlign: TextAlign.center , fontSize: 18 , fontWeight: FontWeight.w800,))
        ],
      ),
    );
  }
}
