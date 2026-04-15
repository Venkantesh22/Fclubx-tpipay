import 'package:flutter/material.dart';
import 'package:frezka/components/custom_stepper.dart';
import 'package:frezka/screens/booking/component/booking_step1_component.dart';
import 'package:frezka/screens/booking/component/booking_step3_component.dart';
import 'package:frezka/screens/package/model/package_list_model.dart';
import 'package:frezka/store/booking_request_store.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../services/models/service_response.dart';

class CustomStep {
  final String? title;
  final Widget? page;

  CustomStep({this.title, this.page});
}

class BookingScreen extends StatefulWidget {
  final List<ServiceListData> services;
  final List<PackageListData>? packages;
  final bool isReschedule;
  final bool isPackagePurchase;
  final bool isPackageReclaim;

  final bool isBranchService;
  final int? branchId;

  const BookingScreen({super.key, required this.services, this.isPackageReclaim = false, this.packages, this.isPackagePurchase = false, this.isReschedule = false, this.isBranchService = false, this.branchId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<CustomStep>? stepsList;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    bookingRequestStore = BookingRequestStore();

    bookingRequestStore.setSelectedServiceListInRequest(widget.services, isRescheduleInRequest: widget.isReschedule);
    if (widget.isPackagePurchase) {
      bookingRequestStore.setSelectedPackageListInRequest(widget.packages.validate());
      bookingRequestStore.setPackagePurchase(true);
    }
    if (widget.isPackageReclaim) {
      bookingRequestStore.setPackageReclaim(true);
    }
    if (branchConfigurationCached != null) {
      bookingRequestStore.setTaxPercentageInRequest(branchConfigurationCached!.tax.validate());
    }

    // Initialize steps list
    stepsList = [
      CustomStep(title: '${locale.dateTime} & ${locale.staff}', page: BookingStep1Component(isReschedule: widget.isReschedule, branchId: widget.isBranchService ? widget.branchId : null)),
      CustomStep(title: locale.payment, page: BookingStep3Component(isReschedule: widget.isReschedule, branchId: widget.isBranchService ? widget.branchId : null)),
    ];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          bookingRequestStore.time = '';
          customStepperController.previousPage(duration: 300.milliseconds, curve: Curves.linear);
          LiveStream().emit(LiveStreamKeyConst.LIVESTREAM_CHANGE_STEP, currentStep);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: CustomStepper(
          stepsList: stepsList.validate(),
          onChange: (p0) {
            currentStep = p0;
          },
        ),
      ),
    );
  }
}
