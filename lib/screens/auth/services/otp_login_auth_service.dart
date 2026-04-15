import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/auth/view/otp_verification_screen.dart';
import 'package:frezka/screens/auth/view/sign_up_screen.dart';
import 'package:frezka/screens/dashboard/view/dashboard_screen.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class OtpLoginAuthService {
  Future loginWithOTP(BuildContext context, {String phoneNumber = "", String? countryCode}) async {
    log("PHONE NUMBER VERIFIED $countryCode$phoneNumber");
    return await auth.verifyPhoneNumber(
      phoneNumber: "$countryCode$phoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) {
        ShowToast.showSuccess(locale.verified);
      },
      verificationFailed: (FirebaseAuthException e) {
        appStore.setLoading(false);
        if (e.code == 'invalid-phone-number') {
          ShowToast.showError(locale.otpInvalidMessage);
        } else {
          ShowToast.showError(e.toString());
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        ShowToast.showInfo(locale.otpInvalidMessage);

        appStore.setLoading(false);

        /// Opens a dialog when the code is sent to the user successfully.
        await OtpVerificationScreen(
          onTap: (otpCode) async {
            if (otpCode != null) {
              AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);

              await auth.signInWithCredential(credential).then((credentials) async {
                Map<String, dynamic> request = {
                  'username': phoneNumber,
                  'password': phoneNumber,
                  'login_type': LoginTypeConst.LOGIN_TYPE_OTP,
                };
                await loginUser(request, isSocialLogin: true).then((loginResponse) async {
                  if (loginResponse.isUserExist == null) {
                    ShowToast.showSuccess(locale.loginSuccessfully);

                    /// Register

                    if (loginResponse.userData != null) await saveUserData(loginResponse.userData!);

                    if (loginResponse.userData!.status == 0) {
                      ShowToast.showInfo(locale.pleaseContactWithAdmin);
                    } else {
                      DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                    }
                  } else {
                    ///Not Register
                    ShowToast.showInfo(locale.confirmOtp);
                    appStore.setLoading(false);
                    finish(context);

                    SignUpScreen(isOTPLogin: true, phoneNumber: phoneNumber, countryCode: countryCode, uid: credentials.user!.uid.validate()).launch(context);
                  }
                }).catchError((e) {
                  appStore.setLoading(false);
                  ShowToast.showError(e.toString());
                });
              }).catchError((e) {
                if (e.code.toString() == 'invalid-verification-code') {
                  ShowToast.showError(locale.otpInvalidMessage);
                } else {
                  ShowToast.showError(e.message.toString());
                }
                appStore.setLoading(false);
              });
            }
          },
        ).launch(context);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
      },
    );
  }
}
