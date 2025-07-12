import 'package:flutter/material.dart';
import 'package:tonometr/themes/app_colors.dart';

enum TopSnackBarType { success, warning, error }

void showTopSnackBar({
  required BuildContext context,
  required String message,
  TopSnackBarType type = TopSnackBarType.success,
}) {
  final overlay = Overlay.of(context);
  late final AnimationController controller;
  late final OverlayEntry overlayEntry;

  controller = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 400),
  );

  overlayEntry = OverlayEntry(
    builder: (context) {
      Color bgColor;
      Color textColor;
      Color iconColor;
      IconData icon;
      switch (type) {
        case TopSnackBarType.success:
          bgColor = AppColors.bgSuccessSubduedSolid;
          textColor = AppColors.textSuccess;
          iconColor = AppColors.iconSucess;
          icon = Icons.check_circle;
          break;
        case TopSnackBarType.warning:
          bgColor = AppColors.bgWarningSubduedSolid;
          textColor = AppColors.textCaution;
          iconColor = AppColors.iconCaution;
          icon = Icons.info;
          break;
        case TopSnackBarType.error:
          bgColor = AppColors.bgCriticalSubduedSolid;
          textColor = AppColors.textCritical;
          iconColor = AppColors.iconCritical;
          icon = Icons.error;
          break;
      }
      return Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(message, style: TextStyle(color: textColor)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
  controller.forward();

  Future.delayed(const Duration(seconds: 3), () async {
    await controller.reverse();
    overlayEntry.remove();
    controller.dispose();
  });
}
