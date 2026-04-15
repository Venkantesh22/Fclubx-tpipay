import 'package:flutter/material.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

class NewUpdateDialog extends StatelessWidget {
  final String version;
  final List<String> updates;
  final VoidCallback onUpdate;
  final VoidCallback onCancel;

  const NewUpdateDialog({
    super.key,
    required this.version,
    required this.updates,
    required this.onUpdate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient + Rocket
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      lightPrimaryColor,
                      lightPrimarySecondColor,
                      secondaryColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),

              Positioned(
                top: -10,
                child: Lottie.asset(
                  'assets/lottie/rocket_louncher.json',
                  width: 150,
                  height: 150,
                ),
              ),
            ],
          ),
          // White Card Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.updateToVer(version),
                  style: boldTextStyle(size: 20),
                ),
                const SizedBox(height: 12),
                ...updates.map(
                  (u) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text("$u", style: primaryTextStyle()),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(locale.cancel, style: primaryTextStyle()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(locale.update, style: primaryTextStyle(color: white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
