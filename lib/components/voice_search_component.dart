import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VoiceSearchComponent extends StatefulWidget {
  @override
  VoiceSearchComponentState createState() => VoiceSearchComponentState();
}

class VoiceSearchComponentState extends State<VoiceSearchComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/volume.json', fit: BoxFit.cover, height: 120, width: 200),
        ],
      ),
    );
  }
}
