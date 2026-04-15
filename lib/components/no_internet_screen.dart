import 'package:flutter/material.dart';
import 'package:frezka/services/network_service.dart';
import 'package:frezka/main.dart';
import 'package:nb_utils/nb_utils.dart';

class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NoInternetScreen({
    Key? key,
    this.onRetry,
    this.message,
  }) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    _networkService.isConnected.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _networkService.isConnected.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_networkService.isConnected.value) {
      // Internet is back, retry the operation
      widget.onRetry?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.width(),
        height: context.height(),
        color: context.scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Internet icon
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: context.primaryColor,
            ),
            24.height,
            Text(
              locale.yourInternetIsNotWorking,
              style: boldTextStyle(size: 20),
              textAlign: TextAlign.center,
            ),
            8.height,
            Text(
              widget.message ?? locale.pleaseTryAgain,
              style: secondaryTextStyle(size: 14),
              textAlign: TextAlign.center,
            ),
            32.height,
            AppButton(
              text: locale.reload,
              textStyle: boldTextStyle(color: Colors.white),
              color: context.primaryColor,
              width: context.width() * 0.6,
              onTap: () {
                widget.onRetry?.call();
              },
            ),
            16.height,
            Text(
              locale.checkInternetAndTryAgain,
              style: secondaryTextStyle(size: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ).paddingAll(24),
      ),
    );
  }
}
