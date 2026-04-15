import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:frezka/utils/extensions/string_extensions.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../models/bank_list_response.dart';
import '../../../models/base_response_model.dart';
import '../../../models/static_data_model.dart';
import '../../../network/network_utils.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/images.dart';
import '../../../utils/model_keys.dart';

class AddBankScreen extends StatefulWidget {
  final BankHistory? data;
  final String title;

  const AddBankScreen({super.key, this.data, required this.title});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String bankStatus = 'ACTIVE';
  bool isFirstBank = false;

  TextEditingController bankNameCont = TextEditingController();
  TextEditingController branchNameCont = TextEditingController();
  TextEditingController accNumberCont = TextEditingController();
  TextEditingController ifscCodeCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController aadharCardNumberCont = TextEditingController();
  TextEditingController panNumberCont = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode branchNameFocus = FocusNode();
  FocusNode accNumberFocus = FocusNode();
  FocusNode ifscCodeFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode aadharCardNumberFocus = FocusNode();
  FocusNode panNumberFocus = FocusNode();

  Future<void> update() async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('save-bank');
    multiPartRequest.fields[BankServiceKey.bankId] = isUpdate ? widget.data!.id.toString() : "";
    // multiPartRequest.fields[UserKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields[BankServiceKey.bankName] = bankNameCont.text;
    multiPartRequest.fields[BankServiceKey.branchName] = branchNameCont.text;
    multiPartRequest.fields[BankServiceKey.accountNo] = accNumberCont.text;
    multiPartRequest.fields[BankServiceKey.ifscNo] = ifscCodeCont.text;
    multiPartRequest.fields[BankServiceKey.mobileNo] = contactNumberCont.text;
    multiPartRequest.fields[BankServiceKey.aadharNo] = aadharCardNumberCont.text;
    multiPartRequest.fields[BankServiceKey.panNo] = panNumberCont.text;
    multiPartRequest.fields[BankServiceKey.bankAttachment] = '';
    multiPartRequest.fields[UserKeys.status] = bankStatus == "Inactive" ? "1" : "0";
    multiPartRequest.fields[UserKeys.isDefault] = isFirstBank ? "1" : (widget.data?.isDefault.toString() ?? "0");

    multiPartRequest.headers.addAll(buildHeaderTokens());

    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          print(data);
          if ((data as String).isJson()) {
            BaseResponseModel res = BaseResponseModel.fromJson(jsonDecode(data));
            finish(context, [true, bankNameCont.text]);
            ShowToast.showSuccess(res.message!);
          }
        }
      },
      onError: (error) {
        ShowToast.showError(error.toString());
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
    });
  }

  int getStatusValue() {
    if (bankStatus == 'ACTIVE') {
      return 1;
    } else {
      return 0;
    }
  }

  bool isUpdate = true;

  List<StaticDataModel> statusListStaticData = [
    StaticDataModel(key: ACTIVE, value: locale.active),
    StaticDataModel(key: INACTIVE, value: locale.inactive),
  ];
  StaticDataModel? blogStatusModel;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    isUpdate = widget.data != null;

    if (isUpdate) {
      bankNameCont.text = widget.data!.bankName.validate();
      branchNameCont.text = widget.data!.branchName.validate();
      accNumberCont.text = widget.data!.accountNo.validate();
      ifscCodeCont.text = widget.data!.ifscNo.validate();
      contactNumberCont.text = widget.data!.mobileNo.validate();
      aadharCardNumberCont.text = widget.data!.aadharNo.validate();
      panNumberCont.text = widget.data!.panNo.validate();
      bankStatus = widget.data!.status.toString() == "1" ? "Inactive" : "Active";
      blogStatusModel = statusListStaticData.firstWhere((element) {
        return element.key == bankStatus;
      }, orElse: () {
        return statusListStaticData.first;
      });
    } else {
      blogStatusModel = statusListStaticData.first;
      bankStatus = blogStatusModel!.key.validate();
      _checkIfFirstBank();
    }
    setState(() {});
  }

  Future<void> _checkIfFirstBank() async {
    try {
      List<BankHistory> bankList = [];
      await getBankListDetail(
        page: 1,
        perPage: 1,
        list: bankList,
        userId: userStore.userId,
      );

      if (bankList.isEmpty) {
        isFirstBank = true;
        setState(() {});
      }
    } catch (e) {
      print('Error checking existing banks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        appBarWidget: commonAppBarWidget(
          context,
          title: widget.title,
          appBarHeight: 70,
          roundCornerShape: true,
          showLeadingIcon: true,
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                return await update();
              },
              child: Form(
                key: formKey,
                child: AnimatedScrollView(
                  padding: EdgeInsets.all(16),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Name
                    Text(locale.bankName, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      textStyle: primaryTextStyle(),
                      controller: bankNameCont,
                      focus: bankNameFocus,
                      nextFocus: branchNameFocus,
                      decoration: inputDecoration(context, hint: locale.egCentralNationalBank),
                      suffix: ic_piggy_bank.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    // Branch Name
                    Text(locale.branchName, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.NAME,
                      controller: branchNameCont,
                      focus: branchNameFocus,
                      nextFocus: accNumberFocus,
                      decoration: inputDecoration(context, hint: locale.egDowntownSpringfieldBranch),
                      suffix: ic_piggy_bank.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    // Account Number
                    Text(locale.accountNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.NAME,
                      controller: accNumberCont,
                      keyboardType: TextInputType.phone,
                      focus: accNumberFocus,
                      nextFocus: ifscCodeFocus,
                      decoration: inputDecoration(context, hint: locale.accountNumber),
                      suffix: ic_password.iconImage(size: 10, fit: BoxFit.contain).paddingAll(14),
                    ),
                    16.height,
                    // IFSC Code
                    Text(locale.iFSCCode, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.NAME,
                      controller: ifscCodeCont,
                      focus: ifscCodeFocus,
                      nextFocus: contactNumberFocus,
                      decoration: inputDecoration(
                        context,
                        hint: locale.eg3000,
                      ),
                      suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                      isValidationRequired: false,
                    ),
                    16.height,
                    // Status
                    Text(locale.status, style: primaryTextStyle()),
                    8.height,
                    Observer(builder: (context) {
                      return DropdownButtonFormField<StaticDataModel>(
                        isExpanded: true,
                        dropdownColor: context.cardColor,
                        initialValue: blogStatusModel,
                        icon: Icon(Icons.keyboard_arrow_down_outlined),
                        items: statusListStaticData.map((StaticDataModel data) {
                          return DropdownMenuItem<StaticDataModel>(
                            value: data,
                            child: Text(data.value.validate(), style: primaryTextStyle()),
                          );
                        }).toList(),
                        decoration: inputDecoration(context, hint: locale.status),
                        onChanged: (StaticDataModel? value) async {
                          setState(() {
                            blogStatusModel = value;
                            bankStatus = value!.key.validate();
                          });
                        },
                        validator: (value) {
                          if (value == null) return errorThisFieldRequired;
                          return null;
                        },
                      );
                    }),
                    100.height,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AppButton(
                text: locale.save,
                color: primaryColor,
                textStyle: boldTextStyle(color: white),
                width: context.width(),
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    update();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}