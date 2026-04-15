import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frezka/configs.dart';
import 'package:frezka/main.dart';
import 'package:frezka/utils/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/user_data_model.dart';

class GoogleSignInAuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<UserData> signInWithGoogle(BuildContext context) async {
    await googleSignIn.initialize(serverClientId: FIREBASE_SERVER_CLIENT_ID);

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.authenticate();

    if (googleSignInAccount != null) {
      final authentication = googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );

      final UserCredential authResult = await auth.signInWithCredential(credential);
      final User user = authResult.user!;
      final User currentUser = auth.currentUser!;
      assert(user.uid == currentUser.uid);

      log(currentUser);

      await googleSignIn.signOut();

      String firstName = '';
      String lastName = '';
      List<String> nameParts = currentUser.displayName?.split(' ') ?? [];
      firstName = nameParts[0];
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Unknown';

      /// Create a temporary request to send
      UserData tempUserData = UserData()
        ..mobile = currentUser.phoneNumber.validate()
        ..email = currentUser.email.validate()
        ..firstName = firstName.validate()
        ..lastName = lastName.validate()
        ..socialImage = currentUser.photoURL.validate()
        ..profileImage = currentUser.photoURL.validate()
        ..userType = LoginTypeConst.LOGIN_TYPE_USER
        ..loginType = LoginTypeConst.LOGIN_TYPE_GOOGLE
        ..uid = user.uid
        ..username = (currentUser.email.validate().splitBefore('@').replaceAll('.', '')).toLowerCase();

      return tempUserData;
    } else {
      appStore.setLoading(false);
      throw USER_NOT_CREATED;
    }
  }

  static Future<void> deleteCurrentFirebaseUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete().catchError((e) {
        log("Failed to delete Firebase user: $e");
      });
    }
  }
}
