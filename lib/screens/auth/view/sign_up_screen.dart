import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/auth/auth_repository.dart';
import 'package:frezka/screens/branch/view/select_branch_screen.dart';
import 'package:frezka/utils/common_base.dart';
import 'package:frezka/utils/constants.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/images.dart';
import 'package:frezka/utils/model_keys.dart';
import 'package:frezka/utils/notification_service.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../configs.dart';
import '../../../utils/colors.dart';
import '../component/gender_selection_component.dart';
import '../model/user_data_model.dart';

class SignUpScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? countryCode;
  final bool isOTPLogin;
  final String? uid;

  SignUpScreen(
      {Key? key,
      this.phoneNumber,
      this.isOTPLogin = false,
      this.countryCode,
      this.uid})
      : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController referralCode = TextEditingController();

  String? genderValue = GenderConst.MALE;
  bool isTermsAccepted = false;
  Country selectedCountry = defaultCountry();
  ValueNotifier _valueNotifier = ValueNotifier(true);

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        selectedCountry = country;
        setState(() {});
      },
    );
  }

  String buildMobileNumber() {
    if (mobileCont.text.isEmpty) {
      return '';
    } else {
      return '+${selectedCountry.phoneCode} ${mobileCont.text.trim()}';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> registerWithOTP() async {
    hideKeyboard(context);
    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      if (!isTermsAccepted) {
        ShowToast.showInfo(locale.pleaseAcceptTermsAndConditions);
        return;
      }
      formKey.currentState!.save();
      appStore.setLoading(true);

      UserData userResponse = UserData()
        ..username = widget.phoneNumber.validate().trim()
        ..loginType = LoginTypeConst.LOGIN_TYPE_OTP
        ..email = emailCont.text.trim()
        ..userType = LoginTypeConst.LOGIN_TYPE_USER
        ..password = widget.phoneNumber.validate().trim()
        ..gender = genderValue.validate().toLowerCase();

      if (referralCode.text.trim().isNotEmpty) {
        userResponse.referralCode = referralCode.text.trim();
      }

      await createUser(userResponse.toJson()).then((register) async {
        if (register.status == true) {
          // Automatically log in the user after successful registration
          Map loginRequest = {
            CommonKey.email: emailCont.text.trim(),
            CommonKey.password: widget.phoneNumber.validate().trim(),
          };

          await loginUser(loginRequest).then((loginValue) {
            appStore.setLoading(false);
            ShowToast.showSuccess(register.message ?? locale.successful);
            onLoginSuccessRedirection();
          }).catchError((loginError) {
            appStore.setLoading(false);
            ShowToast.showError(loginError.toString().contains('message')
                ? loginError.toString().split('message').last.trim()
                : loginError.toString());
          });
        } else {
          ShowToast.showError(register.message ?? locale.somethingWentWrong);
          appStore.setLoading(false);
        }
      }).catchError((registerError) {
        appStore.setLoading(false);
        ShowToast.showError(registerError);
      });
      appStore.setLoading(false);
    }
  }

  /// endregion

  /// region Register User
  void registerUser() async {
    hideKeyboard(context);

    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      if (!isTermsAccepted) {
        ShowToast.showInfo(locale.pleaseAcceptTermsAndConditions);
        return;
      }
      formKey.currentState!.save();

      appStore.setLoading(true);

      /// Create a temporary request to send
      UserData tempRegisterData = UserData()
        // ..userType = LoginTypeConst.LOGIN_TYPE_USER
        ..firstName = firstNameCont.text.trim()
        ..lastName = lastNameCont.text.trim()
        ..email = emailCont.text.trim()
        ..password = passwordCont.text.trim()
        ..mobile = buildMobileNumber()
        ..gender = genderValue.validate().toLowerCase();

      if (referralCode.text.trim().isNotEmpty) {
        tempRegisterData.referralCode = referralCode.text.trim();
      }

      final email = emailCont.text.trim();
      final password = passwordCont.text.trim();

      await createUser(tempRegisterData.toJson())
          .then((registerResponse) async {
        if (registerResponse.status == true) {
          Map request = {
            CommonKey.email: email,
            CommonKey.password: password,
          };

          await loginUser(request).then((value) {
            ShowToast.showSuccess(
                registerResponse.message ?? locale.successful);
            onLoginSuccessRedirection();
          }).catchError((e) {
            appStore.setLoading(false);
            ShowToast.showError(e, context: context);
          });

          appStore.setLoading(false);
        } else {
          ShowToast.showError(
              registerResponse.message ?? locale.somethingWentWrong);
          appStore.setLoading(false);
        }
      }).catchError((registerError) {
        appStore.setLoading(false);
        ShowToast.showError(registerError);
      });
    }
  }

  void onLoginSuccessRedirection() {
    TextInput.finishAutofillContext();
    // Firebase Notification
    NotificationService().registerFCMAndTopics();

    SelectBranchScreen().launch(context,
        isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);

    appStore.setLoading(false);
  }

  /// endregion

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: context.height() * 0.3,
                    width: context.width(),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: primaryColor,
                      borderRadius: radiusOnly(bottomLeft: 20, bottomRight: 20),
                      decorationImage: DecorationImage(
                          image: AssetImage(bg_pattern), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationDefault(shape: BoxShape.circle),
                      child: Image.asset(app_logo,
                          height: 104, width: 104, fit: BoxFit.cover),
                    ).center(),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(locale.helloUser,
                      style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  8.height,
                  Text(locale.createYourAccountFor,
                      style: secondaryTextStyle(), textAlign: TextAlign.center),
                  Column(
                    children: [
                      16.height,
                      Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: firstNameCont,
                              focus: firstNameFocus,
                              nextFocus: lastNameFocus,
                              textFieldType: TextFieldType.NAME,
                              readOnly: widget.isOTPLogin.validate()
                                  ? widget.isOTPLogin
                                  : false,
                              decoration: inputDecoration(context,
                                  label: locale.firstName),
                            ),
                            16.height,
                            AppTextField(
                              controller: lastNameCont,
                              focus: lastNameFocus,
                              nextFocus: emailFocus,
                              textFieldType: TextFieldType.NAME,
                              readOnly: widget.isOTPLogin.validate()
                                  ? widget.isOTPLogin
                                  : false,
                              decoration: inputDecoration(context,
                                  label: locale.lastName),
                            ),
                            16.height,
                            AppTextField(
                              controller: emailCont,
                              focus: emailFocus,
                              nextFocus: passwordFocus,
                              textFieldType: TextFieldType.EMAIL,
                              decoration:
                                  inputDecoration(context, label: locale.email),
                            ),
                            16.height,
                            AppTextField(
                              controller: passwordCont,
                              textFieldType: TextFieldType.PASSWORD,
                              focus: passwordFocus,
                              nextFocus: mobileFocus,
                              readOnly: widget.isOTPLogin.validate()
                                  ? widget.isOTPLogin
                                  : false,
                              decoration: inputDecoration(context,
                                  label: locale.password),
                              autoFillHints: [AutofillHints.password],
                              validator: (value) {
                                if (value == null ||
                                    value.length <= 7 ||
                                    value.length >= 14) {
                                  return locale
                                      .passwordMustBeGreaterThenProvidedLength;
                                }
                                return null;
                              },
                              onFieldSubmitted: (s) {
                                if (widget.isOTPLogin) {
                                  registerWithOTP();
                                } else {
                                  if (passwordCont.text.length >= 8 &&
                                      passwordCont.text.length <= 12) {
                                    registerUser();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(locale
                                              .passwordMustBeBetween8And12Characters)),
                                    );
                                  }
                                }
                              },
                            ),
                            16.height,
                            GenderSelectionComponent(
                              onTap: (value) {
                                genderValue = value;
                                setState(() {});
                              },
                            ),
                            16.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: context.height() * 0.055,
                                  decoration: BoxDecoration(
                                    color: context.cardColor,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Center(
                                    child: ValueListenableBuilder(
                                      valueListenable: _valueNotifier,
                                      builder: (context, value, child) => Row(
                                        children: [
                                          Text(
                                            "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                                            style: primaryTextStyle(size: 14),
                                          ),
                                          Icon(Icons.arrow_drop_down)
                                        ],
                                      ).paddingOnly(left: 8),
                                    ),
                                  ),
                                ).onTap(() => changeCountry()),
                                10.width,
                                Expanded(
                                  child: AppTextField(
                                    textFieldType: TextFieldType.PHONE,
                                    controller: mobileCont,
                                    focus: mobileFocus,
                                    errorThisFieldRequired:
                                        locale.thisFieldIsRequired,
                                    decoration: inputDecoration(context,
                                        label: locale.contactNumber),
                                    maxLength: 10,
                                  ),
                                ),
                              ],
                            ),
                            16.height,
                            AppTextField(
                              controller: referralCode,
                              textFieldType: TextFieldType.OTHER,
                              decoration: inputDecoration(
                                context,
                                label: "Referral Code (Optional)",
                              ),
                              validator: null,
                            ),
                            16.height,
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              isTermsAccepted = !isTermsAccepted;
                              setState(() {});
                            },
                            child: Checkbox(
                              value: isTermsAccepted,
                              onChanged: (val) {
                                isTermsAccepted = !isTermsAccepted;
                                setState(() {});
                              },
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              side: BorderSide(
                                  color: textSecondaryColorGlobal, width: 1.2),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          8.width,
                          Text(locale.termsConditionText,
                                  style: secondaryTextStyle(
                                      weight: FontWeight.w400))
                              .expand(),
                        ],
                      ),
                      16.height,
                      AppButton(
                        child: Text(locale.signUp,
                            style: boldTextStyle(color: white)),
                        width: context.width(),
                        color: secondaryColor,
                        onTap: () async {
                          if (genderValue == null) {
                            ShowToast.showInfo(locale.genderIsRequired);
                          } else {
                            if (widget.isOTPLogin) {
                              registerWithOTP();
                            } else {
                              registerUser();
                            }
                          }
                        },
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(locale.alreadyHaveAnAccount,
                              style: secondaryTextStyle()),
                          TextButton(
                            onPressed: () {
                              hideKeyboard(context);
                              finish(context);
                            },
                            child: Text(
                              locale.signIn,
                              style: boldTextStyle(
                                  color: primaryColor,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 16),
                ],
              ).paddingOnly(top: 80),
            ],
          ),
        ),
      ),
    );
  }
}
