import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constants.dart';
import '../services/network_service.dart';
import 'no_internet_screen.dart';
import '../main.dart';
import 'body_widget.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;
  final bool showAppBar;
  final PreferredSizeWidget? appBarWidget;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? scaffoldBackgroundColor;
  final VoidCallback? onRetry;

  AppScaffold({
    this.appBarTitle,
    required this.body,
    this.actions,
    this.scaffoldBackgroundColor,
    this.showAppBar = true,
    this.floatingActionButton,
    this.appBarWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NetworkService().isConnected,
      builder: (context, isConnected, child) {
        if (!isConnected) {
          return NoInternetScreen(
            onRetry: onRetry,
            message: locale.yourInternetIsNotWorking,
          );
        }
        
        return Scaffold(
          appBar: showAppBar
              ? appBarWidget ??
                  AppBar(
                    centerTitle: true,
                    title: Text(
                      appBarTitle.validate(),
                      style: boldTextStyle(color: Colors.white, size: APPBAR_TEXT_SIZE),
                    ),
                    elevation: 0.0,
                    backgroundColor: context.primaryColor,
                    actions: actions,
                  )
              : null,
          backgroundColor: scaffoldBackgroundColor,
          floatingActionButton: floatingActionButton,
          body: Body(child: body),
        );
      },
    );
  }
}
