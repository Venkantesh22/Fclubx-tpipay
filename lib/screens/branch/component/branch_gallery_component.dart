import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/screens/zoom_image_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../branch_repository.dart';
import '../model/branch_gallery_list_response.dart';
import '../shimmer/branch_gallery_shimmer.dart';

class BranchGalleryComponent extends StatefulWidget {
  final int branchId;

  BranchGalleryComponent({required this.branchId});

  @override
  _BranchGalleryComponentState createState() => _BranchGalleryComponentState();
}

class _BranchGalleryComponentState extends State<BranchGalleryComponent> {
  Future<List<BranchGalleryData>>? future;

  List<BranchGalleryData> branchGalleryList = [];

  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getBranchGalleryList(
      branchId: widget.branchId,
      page: page,
      list: branchGalleryList,
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SnapHelperWidget<List<BranchGalleryData>>(
          future: future,
          initialData: branchGalleryListResponseCached,
          loadingWidget: BranchGalleryShimmer(),
          onSuccess: (list) {
            if (list.isEmpty) {
              return SingleChildScrollView(
                child: NoDataWidget(
                  title: locale.noGalleryFound,
                  subTitle: locale.galleryWillBeAppearedHere,
                  imageWidget: EmptyStateWidget(),
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: list.length,
              itemBuilder: (_, index) {
                BranchGalleryData galleryData = list[index];

                return GestureDetector(
                  onTap: () {
                    if (galleryData.fullUrl.validate().isNotEmpty) ZoomImageScreen(galleryImages: list.map((e) => e.fullUrl.validate()).toList(), index: index).launch(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedImageWidget(
                        url: galleryData.fullUrl.validate(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                page = 1;
                appStore.setLoading(true);

                init();
                setState(() {});
              },
            ).center();
          },
        ),
        Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
      ],
    );
  }
}
