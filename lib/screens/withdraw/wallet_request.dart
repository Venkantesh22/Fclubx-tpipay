// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_toast_widget.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../components/price_widget.dart';
import '../../components/success_dialog.dart';
import '../../main.dart';
import '../../models/bank_list_response.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../bankDetails/view/add_bank.dart';

class WithdrawRequest extends StatefulWidget {
  num availableBalance = 0;

  WithdrawRequest({super.key, required this.availableBalance});

  @override
  State<WithdrawRequest> createState() => _WithdrawRequestState();
}

class _WithdrawRequestState extends State<WithdrawRequest> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();

  FocusNode amountFocus = FocusNode();
  Future<List<BankHistory>>? future;

  List<BankHistory> bankHistoryList = [];
  BankHistory? selectedBank;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    // Check if we have cached bank data first
    if (cachedBankList != null && cachedBankList!.isNotEmpty) {
      bankHistoryList = List<BankHistory>.from(cachedBankList!);
      final availableBanks = bankHistoryList.where((e) => e.status != 1).toList();
      if (availableBanks.isNotEmpty) {
        selectedBank = availableBanks.firstWhere(
          (b) => b.isDefault == 1,
          orElse: () => availableBanks.first,
        );
      }
      setState(() {});
    }

    // Always refresh data in background
    init("");
  }

  init(String bankName) async {
    // Only show loading if we don't have any data yet
    if (bankHistoryList.isEmpty) {
      appStore.setLoading(true);
      setState(() {}); // Update UI to show loading state
    }

    try {
      final value = await getBankListDetail(
        page: page,
        list: bankHistoryList,
        lastPageCallback: (b) => isLastPage = b,
        userId: userStore.userId,
      );

      // Remove duplicates by ID
      final uniqueBanks = {
        for (var e in value) e.id: e,
      }.values.toList();

      bankHistoryList = uniqueBanks;

      // Auto-select bank logic
      final availableBanks = bankHistoryList.where((e) => e.status != 1).toList();

      if (availableBanks.isNotEmpty) {
        if (bankName.isNotEmpty) {
          // Try to select based on name
          selectedBank = availableBanks.firstWhere(
            (b) => b.bankName == bankName,
            orElse: () => availableBanks.first,
          );
        } else if (availableBanks.length == 1) {
          // Only one bank available - auto-select it
          selectedBank = availableBanks.first;
        } else {
          // Multiple banks - try to select default or first available
          selectedBank = availableBanks.firstWhere(
            (b) => b.isDefault == 1,
            orElse: () => availableBanks.first,
          );
        }
      }

      setState(() {});
    } catch (e) {
      // Handle error if needed
      print('Error loading bank details: $e');
    } finally {
      appStore.setLoading(false);
      setState(() {}); // Ensure UI updates after loading completes
    }
  }

  withdrawMoney() {
    appStore.setLoading(true);
    Map request = {
      "_token": appStore.token.validate(),
      "payment_method": "bank",
      "payment_gateway": locale.wallet,
      "user_id": userStore.userId,
      "bank_id": selectedBank?.id,
      "amount": amount.text.toDouble(),
    };
    providerWithdrawMoney(request: request).then((value) {
      showDialog(
        context: context,
        builder: (_) => SuccessDialog(
          title: locale.successful,
          description: locale.yourWithdrawalRequestHasBeenSuccessfullySubmitted,
          buttonText: locale.done,
        ),
      );
    }).catchError((e) {
      ShowToast.showError(e.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _buildBankSelectionWidget() {
    // Show loading state only if we have no data and are still loading

    // If we have data, show it immediately regardless of loading state

    final availableBanks = bankHistoryList.where((e) => e.status != 1).toList();

    if (availableBanks.length == 1) {
      // Only one bank available - show as read-only
      final singleBank = availableBanks.first;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.dividerColor),
          color: context.cardColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    singleBank.bankName.validate(),
                    style: primaryTextStyle(),
                  ),
                ],
              ),
            ),
            if (singleBank.isDefault == 1)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  locale.lbldefault,
                  style: boldTextStyle(size: 10, color: context.primaryColor),
                ),
              ),
          ],
        ),
      );
    } else {
      // Multiple banks available - show dropdown
      return DropdownButtonFormField<BankHistory>(
        decoration: inputDecoration(context),
        isExpanded: true,
        menuMaxHeight: 300,
        initialValue: availableBanks.contains(selectedBank) ? selectedBank : null,
        hint: Text(locale.egCentralNationalBank, style: secondaryTextStyle(size: 12)),
        icon: Icon(Icons.keyboard_arrow_down_sharp),
        dropdownColor: context.cardColor,
        items: availableBanks
            .map((e) => DropdownMenuItem<BankHistory>(
                  value: e,
                  child: Text(
                    e.bankName.validate(),
                    style: primaryTextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (BankHistory? value) {
          selectedBank = value;
          setState(() {});
        },
        validator: (value) {
          if (value == null) return errorThisFieldRequired;
          return null;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        appBarWidget: commonAppBarWidget(
          context,
          title: locale.withdrawRequest,
          appBarHeight: 70,
          roundCornerShape: true,
          showLeadingIcon: true,
        ),
        body: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: AnimatedScrollView(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(25),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(locale.availableBalance, style: secondaryTextStyle(size: 12)).expand(),
                        PriceWidget(price: widget.availableBalance.validate(), color: context.primaryColor, isBoldText: true),
                      ],
                    ),
                  ).paddingSymmetric(horizontal: 30),
                  24.height,
                  Text(locale.lblEnterAmount, style: primaryTextStyle(size: 12, weight: FontWeight.w600)),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NUMBER,
                    controller: amount,
                    focus: amountFocus,
                    decoration: inputDecoration(context, hint: locale.eg3000),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value.isEmptyOrNull) return errorThisFieldRequired;
                      if (num.parse(value!) > widget.availableBalance) return locale.insufficientWalletBalance;
                      return null;
                    },
                  ),
                  16.height,
                  Row(
                    children: [
                      Text(locale.chooseBank, style: primaryTextStyle(size: 12, weight: FontWeight.w600)),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          AddBankScreen(title: locale.addBank).launch(context).then((value) {
                            if (value.isNotEmpty && value[0]) {
                              init(value[1]);
                            }
                          });
                        },
                        child: Text(locale.addBank, style: boldTextStyle(size: 12, color: primaryColor)),
                      ),
                    ],
                  ),
                  8.height,
                  // Show dropdown only if there are multiple banks, otherwise show selected bank info
                  Observer(
                    builder: (_) => _buildBankSelectionWidget(),
                  ),

                  40.height,
                  AppButton(
                    text: locale.withdraw,
                    height: 40,
                    color: primaryColor,
                    textStyle: boldTextStyle(color: white),
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        withdrawMoney();
                      }
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 16),
            ),
            Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}