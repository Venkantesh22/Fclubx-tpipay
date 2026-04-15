import 'package:flutter/material.dart';
import 'package:frezka/components/view_all_label_component.dart';
import 'package:frezka/screens/experts/component/employee_list_component.dart';
import 'package:frezka/screens/experts/view/employee_list_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../experts/model/employee_detail_response.dart';
import '../../experts/view/employee_detail_screen.dart';

class TopExpertsComponent extends StatefulWidget {
  final List<EmployeeData>? topExpertList;

  TopExpertsComponent({this.topExpertList});

  @override
  _TopExpertsComponentState createState() => _TopExpertsComponentState();
}

class _TopExpertsComponentState extends State<TopExpertsComponent> {
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
    if (widget.topExpertList.validate().isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.topExperts,
          list: widget.topExpertList,
          onTap: () {
            EmployeeListScreen().launch(context);
          },
        ).paddingSymmetric(horizontal: 16),
        AnimatedWrap(
          runSpacing: 0,
          spacing: 10,
          columnCount: 2,
          itemCount: widget.topExpertList.validate().take(4).length,
          listAnimationType: ListAnimationType.Scale,
          scaleConfiguration: ScaleConfiguration(duration: 300.milliseconds, delay: 50.milliseconds),
          itemBuilder: (_, i) {
            EmployeeData data = widget.topExpertList.validate()[i];
            return EmployeeListComponent(
                expertData: data,
                hideRating: true,
                onTap: () {
                  EmployeeDetailScreen(employeeId: data.id.validate()).launch(context);
                });
          },
        ).paddingSymmetric(horizontal: 16),
        16.height,
      ],
    );
  }
}
