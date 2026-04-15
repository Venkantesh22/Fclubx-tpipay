import 'package:flutter/material.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CommonBottomSheet extends StatefulWidget {
  final String? title;
  final Widget child;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxHeight;
  final Color? backgroundColor;
  final ScrollController? scrollController;

  const CommonBottomSheet({
    Key? key,
    this.title,
    required this.child,
    this.showCloseButton = true,
    this.onClose,
    this.contentPadding = const EdgeInsets.all(16),
    this.maxHeight,
    this.backgroundColor,
    this.scrollController,
  }) : super(key: key);

  @override
  State<CommonBottomSheet> createState() => _CommonBottomSheetState();

  /// Show a common bottom sheet with predefined styling and behavior
  static Future<T?> show<T extends Object?>(
    BuildContext context, {
    String? title,
    required Widget child,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsetsGeometry? contentPadding = const EdgeInsets.all(16),
    double? maxHeight,
    Color? backgroundColor,
    bool isDismissible = true,
    bool enableDrag = true,
    ScrollController? scrollController,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      builder: (context) => CommonBottomSheet(
        title: title,
        showCloseButton: showCloseButton,
        onClose: onClose,
        contentPadding: contentPadding,
        maxHeight: maxHeight,
        backgroundColor: backgroundColor,
        scrollController: scrollController,
        child: child,
      ),
    );
  }
}

class _CommonBottomSheetState extends State<CommonBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              if (widget.title != null || widget.showCloseButton)
                Container(
                  padding: EdgeInsets.only(
                    left: widget.contentPadding?.horizontal != null 
                        ? widget.contentPadding!.horizontal / 2 
                        : 20,
                    right: widget.contentPadding?.horizontal != null 
                        ? widget.contentPadding!.horizontal / 2 
                        : 20,
                    top: 10,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.title != null)
                        Expanded(
                          child: Text(
                            widget.title!,
                            style: boldTextStyle(
                              size: 16,
                              height: 1.625,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Spacer(),
                      
                      if (widget.showCloseButton)
                        GestureDetector(
                          onTap: () {
                            widget.onClose?.call();
                            Navigator.of(context).pop();
                          },
                          child: CachedImageWidget(
                            url: ic_close,
                            height: 22,
                            width: 22,
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Divider after heading
              if (widget.title != null || widget.showCloseButton)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.dividerColor,
                ).paddingSymmetric(horizontal: 16),
              
              // Scrollable content
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: widget.contentPadding ?? EdgeInsets.all(16),
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extended common bottom sheet for more complex layouts
class CommonBottomSheetLayout extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Widget? customHeader;
  final Widget? bottomWidget;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxHeight;
  final Color? backgroundColor;
  final ScrollController? scrollController;

  const CommonBottomSheetLayout({
    Key? key,
    this.title,
    required this.child,
    this.showCloseButton = true,
    this.onClose,
    this.customHeader,
    this.bottomWidget,
    this.contentPadding = const EdgeInsets.all(16),
    this.maxHeight,
    this.backgroundColor,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom header or default header
              if (customHeader != null)
                customHeader!
              else if (title != null || showCloseButton)
                Padding(
                  padding: EdgeInsets.only(
                    left: contentPadding?.horizontal != null 
                        ? contentPadding!.horizontal / 2 
                        : 16,
                    right: contentPadding?.horizontal != null 
                        ? contentPadding!.horizontal / 2 
                        : 16,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: boldTextStyle(size: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Spacer(),
                      
                      if (showCloseButton)
                        InkWell(
                          onTap: () {
                            onClose?.call();
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CachedImageWidget(
                              url: ic_close,
                              height: 20,
                              width: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: contentPadding ?? EdgeInsets.all(16),
                  child: child,
                ),
              ),
              
              // Bottom widget (if provided)
              if (bottomWidget != null) bottomWidget!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Utility methods for common bottom sheet patterns
class BottomSheetUtils {
  /// Show a simple bottom sheet with just content
  static Future<T?> showSimple<T extends Object?>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) {
    return CommonBottomSheet.show<T>(
      context,
      title: title,
      child: child,
      showCloseButton: showCloseButton,
      onClose: onClose,
    );
  }

  /// Show a bottom sheet with custom layout
  static Future<T?> showCustomLayout<T extends Object?>(
    BuildContext context, {
    required Widget child,
    String? title,
    Widget? customHeader,
    Widget? bottomWidget,
    bool showCloseButton = true,
    VoidCallback? onClose,
    double? maxHeight,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => CommonBottomSheetLayout(
        title: title,
        customHeader: customHeader,
        bottomWidget: bottomWidget,
        showCloseButton: showCloseButton,
        onClose: onClose,
        maxHeight: maxHeight,
        contentPadding: contentPadding,
        child: child,
      ),
    );
  }

  /// Show a bottom sheet with scrollable list
  static Future<T?> showList<T extends Object?>(
    BuildContext context, {
    required List<Widget> children,
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
    ScrollController? scrollController,
  }) {
    return CommonBottomSheet.show<T>(
      context,
      title: title,
      showCloseButton: showCloseButton,
      onClose: onClose,
      scrollController: scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}