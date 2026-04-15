import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum ToastType { info, success, error }

class ShowToast {
  static void toast({
    BuildContext? context,
    required String message,
    String? iconPathSvg,
    Alignment? alignment,
    ToastType? toastType,
  }) {
    // Use provided context or get from global navigator key
    final ctx = context ?? navigatorKey.currentContext!;
    
    ShadToaster.of(ctx).show(
      ShadToast(
        alignment: alignment ?? Alignment.topCenter,
        actionPadding: EdgeInsets.zero,
        padding: EdgeInsets.only(left: 18, top: 10, bottom: 10, right: 4),
        backgroundColor: _getToastBackgroundColor(toastType, ctx),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use Icon widget instead of CachedImageWidget for toast icons
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(toastType, ctx),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(toastType),
                size: getToastImageSize(toastType: toastType),
                color: _getIconColor(toastType, ctx),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: primaryTextStyle(weight: FontWeight.w500, color: black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _getIconData(ToastType? toastType) {
    switch (toastType) {
      case ToastType.info:
        return Icons.info;
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  static Color _getIconColor(ToastType? toastType, BuildContext ctx) {
    switch (toastType) {
      case ToastType.info:
        return Colors.orange;
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  static Color _getIconBackgroundColor(ToastType? toastType, BuildContext ctx) {
    switch (toastType) {
      case ToastType.info:
        return Colors.orange.withValues(alpha: 0.1);
      case ToastType.success:
        return Colors.green.withValues(alpha: 0.1);
      case ToastType.error:
        return Colors.red.withValues(alpha: 0.1);
      default:
        return Colors.orange.withValues(alpha: 0.1);
    }
  }

  static Color _getToastBackgroundColor(ToastType? toastType, BuildContext ctx) {
    // Get theme-aware background colors    
    switch (toastType) {
      case ToastType.info:
        return Colors.orange.shade50;
      case ToastType.success:
        return Colors.green.shade50;
      case ToastType.error:
        return Colors.red.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  static double getToastImageSize({ToastType? toastType}) {
    switch (toastType) {
      case ToastType.info:
        return 20;
      case ToastType.success:
        return 20;
      case ToastType.error:
        return 20;
      default:
        return 20;
    }
  }

  /// Show error toast from exception
  /// Automatically extracts user-friendly message from Exception
  static void showError(
    dynamic error, {
    BuildContext? context,
  }) {
    String errorMessage = _extractErrorMessage(error);
    toast(
      context: context,
      message: errorMessage,
      toastType: ToastType.error,
    );
  }

  /// Show success toast with message
  static void showSuccess(
    String message, {
    BuildContext? context,
  }) {
    toast(
      context: context,
      message: message,
      toastType: ToastType.success,
    );
  }

  /// Show info toast with message
  static void showInfo(
    String message, {
    BuildContext? context,
  }) {
    toast(
      context: context,
      message: message,
      toastType: ToastType.info,
    );
  }

  /// Extract user-friendly error message from exception
  static String _extractErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred';
    }

    String errorString = error.toString();

    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      errorString = errorString.replaceFirst('Exception: ', '');
    }

    // Remove class name prefixes like "SocketException: " or "FormatException: "
    final prefixPattern = RegExp(r'^[A-Za-z]+Exception:\s*');
    errorString = errorString.replaceFirst(prefixPattern, '');

    // Return the cleaned message
    return errorString.isEmpty ? 'An unexpected error occurred' : errorString;
  }
}
