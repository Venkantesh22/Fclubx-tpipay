import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/screens/cart/cart_repository.dart';
import 'package:frezka/screens/cart/model/logistic_zone_response.dart';
import 'package:frezka/utils/custom_toast_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../configs.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../model/address_list_response.dart';
import '../model/country_list_response.dart';
import '../model/state_list_response.dart';

class AddAddressScreen extends StatefulWidget {
  final UserAddress? address;

  AddAddressScreen({this.address});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  List<CountryData> countryList = [];
  List<StateData> stateList = [];
  List<CityData> cityList = [];

  CountryData? selectedCountry;
  StateData? selectedState;
  CityData? selectedCity;

  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController pinCodeCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode addressLine1FocusNode = FocusNode();
  FocusNode addressLine2FocusNode = FocusNode();
  FocusNode pinCodeFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();

  bool isEdit = false;
  bool isPrimary = false;

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;

  Country selectedPhoneCountry = defaultCountry();
  ValueNotifier _valueNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      log("---------------------------${widget.address!.toJson()}");
      isEdit = true;
      firstNameCont.text = widget.address!.firstName.validate();
      lastNameCont.text = widget.address!.lastName.validate();
      String existingContact = widget.address!.contactNumber.validate();

      // Normalize and parse phone code + number from various formats, e.g. "+81 98-7513-2235", "81-9875132235", etc.
      String normalized = existingContact.trim();
      String codeDigits = '';
      String numberPart = '';

      if (normalized.startsWith('+')) {
        // Extract consecutive digits after '+' as country code
        int i = 1;
        while (i < normalized.length && RegExp(r"[0-9]").hasMatch(normalized[i])) {
          codeDigits += normalized[i];
          i++;
        }
        numberPart = normalized.substring(i).trim();
      } else if (normalized.contains('-')) {
        // Split by first '-' and take the left as potential code
        int dashIndex = normalized.indexOf('-');
        codeDigits = normalized.substring(0, dashIndex).replaceAll(RegExp(r'[^0-9]'), '');
        numberPart = normalized.substring(dashIndex + 1).trim();
      } else if (normalized.contains(' ')) {
        // Split by first space and take the left as potential code
        int spaceIndex = normalized.indexOf(' ');
        codeDigits = normalized.substring(0, spaceIndex).replaceAll(RegExp(r'[^0-9]'), '');
        numberPart = normalized.substring(spaceIndex + 1).trim();
      } else {
        // No obvious code separator; treat entire string as number
        numberPart = normalized;
      }

      // Apply parsed country code if found
      if (codeDigits.isNotEmpty) {
        try {
          Country? foundCountry = CountryService().findByPhoneCode(codeDigits);
          if (foundCountry != null) {
            selectedPhoneCountry = foundCountry;
          }
        } catch (e) {
          selectedPhoneCountry = defaultCountry();
        }
      }

      // Keep user's formatting for the phone number part as-is
      contactNumberCont.text = numberPart.isNotEmpty ? numberPart : normalized;
      addressLine1Controller.text = widget.address!.addressLine1.validate();
      addressLine2Controller.text = widget.address!.addressLine2.validate();
      pinCodeCont.text = widget.address!.postalCode.validate().toString();
      cityId = widget.address!.city.validate().toInt();
      stateId = widget.address!.state.validate().toInt();
      countryId = widget.address!.country.validate().toInt();

      isPrimary = widget.address!.isPrimary.validate().getBoolInt();
      setState(() {});
    } else {
      _checkIfFirstAddress();
    }
    init();
  }

  void init() async {
    if (countryId != 0) {
      await getCountry();
      await getStates(countryId);
      if (stateId != 0) {
        await getCity(stateId);
      }

      setState(() {});
    } else {
      await getCountry();
    }
  }

  Future<void> _checkIfFirstAddress() async {
    try {
      List<UserAddress> addressList = [];
      await getAddressList(
        page: 1,
        perPage: 1,
        addressList: addressList,
      );

      if (addressList.isEmpty) {
        isPrimary = true;
        setState(() {});
      }
    } catch (e) {
      print('Error checking existing addresses: $e');
    }
  }

  Future<void> changePhoneCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        selectedPhoneCountry = country;
        setState(() {});
      },
    );
  }

  String buildContactNumber() {
    if (contactNumberCont.text.isEmpty) {
      return '';
    } else {
      return '${selectedPhoneCountry.phoneCode}-${contactNumberCont.text.trim()}';
    }
  }

  Future<void> getCountry() async {
    appStore.setLoading(true);

    await getCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);
      setState(() {});
      value.forEach((e) {
        if (e.id == countryId) {
          selectedCountry = e;
        }
      });
    }).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
    });
  }

  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);

    await getStateList(countryId: countryId).then((value) async {
      stateList.clear();
      stateList.addAll(value);
      value.forEach((e) {
        if (e.id == stateId) {
          selectedState = e;
        }
      });
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
    });
  }

  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);

    await getCityList(stateId: stateId).then((value) async {
      cityList.clear();
      cityList.addAll(value);
      value.forEach((e) {
        if (e.id == cityId) {
          selectedCity = e;
        }
      });
    }).catchError((e) {
      appStore.setLoading(false);
      ShowToast.showError(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: isEdit ? locale.editAddress : locale.addNewAddress,
        appBarHeight: 70,
        showLeadingIcon: true,
        roundCornerShape: true,
      ),
      body: Stack(
        children: [
          Observer(
            builder: (context) => AbsorbPointer(
              absorbing: appStore.isLoading,
              child: AnimatedScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 60, top: 30),
                children: [
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: firstNameCont,
                          focus: firstNameFocus,
                          nextFocus: lastNameFocus,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(context, label: locale.firstName),
                        ),
                        16.height,
                        AppTextField(
                          controller: lastNameCont,
                          focus: lastNameFocus,
                          nextFocus: contactNumberFocus,
                          textFieldType: TextFieldType.NAME,
                          textInputAction: TextInputAction.done,
                          decoration: inputDecoration(context, label: locale.lastName),
                        ),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: context.height() * 0.063,
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
                                        "${selectedPhoneCountry.flagEmoji} +${selectedPhoneCountry.phoneCode}",
                                        style: primaryTextStyle(size: 14),
                                      ),
                                      Icon(Icons.arrow_drop_down)
                                    ],
                                  ).paddingOnly(left: 8),
                                ),
                              ),
                            ).onTap(() => changePhoneCountry()),
                            10.width,
                            Expanded(
                              child: AppTextField(
                                controller: contactNumberCont,
                                focus: contactNumberFocus,
                                textFieldType: TextFieldType.PHONE,
                                decoration: inputDecoration(context, label: locale.contactNumber),
                                isValidationRequired: true,
                                maxLength: 15,
                              ),
                            ),
                          ],
                        ),
                        16.height,
                        Row(
                          children: [
                            DropdownButtonFormField<CountryData>(
                              decoration: inputDecoration(context, label: locale.selectCountry, alignLabelWithHint: false),
                              isExpanded: true,
                              initialValue: (selectedCountry != null && selectedCountry!.id.validate() > 0) ? selectedCountry : null,
                              dropdownColor: context.cardColor,
                              items: countryList.map((CountryData e) {
                                return DropdownMenuItem<CountryData>(
                                  value: e,
                                  child: Text(e.name!, style: primaryTextStyle()),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null) return '${locale.selectCountry} ${locale.isRequired}';
                                return null;
                              },
                              onChanged: (CountryData? value) async {
                                hideKeyboard(context);
                                countryId = value!.id!;
                                selectedCountry = value;
                                selectedState = null;
                                selectedCity = null;
                                getStates(value.id!);

                                setState(() {});
                              },
                            ).expand(),
                            if (stateList.isNotEmpty) 12.width,
                            if (stateList.isNotEmpty)
                              DropdownButtonFormField<StateData>(
                                decoration: inputDecoration(context, label: locale.selectState, alignLabelWithHint: false),
                                isExpanded: true,
                                dropdownColor: context.cardColor,
                                initialValue: (selectedState != null && selectedState!.id.validate() > 0) ? selectedState : null,
                                items: stateList.map((StateData e) {
                                  return DropdownMenuItem<StateData>(
                                    value: e,
                                    child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) return '${locale.selectState} ${locale.isRequired}';
                                  return null;
                                },
                                onChanged: (StateData? value) async {
                                  hideKeyboard(context);
                                  selectedCity = null;
                                  selectedState = value;
                                  stateId = value!.id!;
                                  await getCity(value.id!);
                                  setState(() {});
                                },
                              ).expand(),
                          ],
                        ),
                        16.height,
                        Row(
                          children: [
                            if (cityList.isNotEmpty)
                              DropdownButtonFormField<CityData>(
                                decoration: inputDecoration(context, label: locale.selectCity, alignLabelWithHint: false),
                                isExpanded: true,
                                initialValue: (selectedCity != null && selectedCity!.id.validate() > 0) ? selectedCity : null,
                                dropdownColor: context.cardColor,
                                items: cityList.map((CityData e) {
                                  return DropdownMenuItem<CityData>(
                                    value: e,
                                    child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (CityData? value) async {
                                  hideKeyboard(context);
                                  selectedCity = value;
                                  cityId = value!.id!;
                                  setState(() {});
                                },
                              ).expand(),
                            if (cityList.isNotEmpty) 12.width,
                            AppTextField(
                              textFieldType: TextFieldType.NUMBER,
                              controller: pinCodeCont,
                              focus: pinCodeFocus,
                              nextFocus: addressLine1FocusNode,
                              isValidationRequired: true,
                              decoration: inputDecoration(context, label: locale.pincode),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '${locale.pincode} ${locale.isRequired}';
                                }
                                return null;
                              },
                              onTap: () {
                                scrollController.animToBottom();
                              },
                              onChanged: (p0) {
                                scrollController.animToBottom();
                              },
                            ).expand(),
                          ],
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.OTHER,
                          controller: addressLine1Controller,
                          nextFocus: addressLine2FocusNode,
                          focus: addressLine1FocusNode,
                          decoration: inputDecoration(context, label: '${locale.addressLine} 1', hint: '${locale.writeAddressHere}...'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${locale.addressLine} 1 ${locale.isRequired}';
                            }
                            return null;
                          },
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.OTHER,
                          controller: addressLine2Controller,
                          focus: addressLine2FocusNode,
                          isValidationRequired: false,
                          decoration: inputDecoration(context, label: '${locale.addressLine} 2', hint: '${locale.writeLandmarkHere}...'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${locale.addressLine} 2 ${locale.isRequired}';
                            }
                            return null;
                          },
                        ),
                        8.height,
                        setAsPrimaryWidget(),
                        16.height,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AppButton(
              child: Text(isEdit ? locale.saveChanges : locale.save, style: boldTextStyle(color: white)),
              width: context.width(),
              color: secondaryColor,
              onTap: () async {
                if (!appStore.isLoading) {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();

                    appStore.setLoading(true);
                    hideKeyboard(context);
                    Map req = {
                      "first_name": firstNameCont.text.trim(),
                      "last_name": lastNameCont.text.trim(),
                      "address_line_1": addressLine1Controller.text.trim(),
                      "address_line_2": addressLine2Controller.text.trim(),
                      "postal_code": pinCodeCont.text.trim(),
                      "city": cityId,
                      "state": stateId,
                      "country": countryId,
                      "is_primary": isPrimary.getIntBool(),
                      if (contactNumberCont.text.trim().isNotEmpty) "contact_number": buildContactNumber(),
                    };
                    if (isEdit) {
                      req.putIfAbsent("id", () => widget.address!.id.validate());
                    }

                    addEditAddress(request: req, isEdit: isEdit).then((value) {
                      finish(context, true);
                      appStore.setLoading(false);
                    }).catchError(onError);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget setAsPrimaryWidget() {
    return CheckboxListTile(
      value: isPrimary,
      title: Text(locale.setAsPrimary, style: boldTextStyle(color: appStore.isDarkMode ? textPrimaryColorGlobal : secondaryColor, size: 14)),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      checkboxShape: RoundedRectangleBorder(borderRadius: radius(5)),
      side: BorderSide(color: textSecondaryColorGlobal),
      dense: true,
      activeColor: appStore.isDarkMode ? primaryColor : secondaryColor,
      onChanged: (value) {
        isPrimary = !isPrimary;
        setState(() {});
      },
    );
  }
}
