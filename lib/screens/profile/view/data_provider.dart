import 'package:flutter/cupertino.dart';
import 'package:frezka/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../configs.dart';
import '../../../main.dart';
import '../../../models/about_model.dart';
import '../../../models/configuration_response.dart';
import '../../../utils/app_common.dart';
import '../../../utils/constants.dart';
import 'about_us_screen.dart';

List<AboutModel> getAboutDataModel({required BuildContext context}) {
  List<AboutModel> aboutList = [];

  aboutList.add(AboutModel(
    title: locale.rateUs,
    icon: ic_star,
    onTap: () async {
      if (isAndroid) {
        if (getStringAsync(APP_PLAY_STORE_URL).isNotEmpty) {
          commonLaunchUrl(getStringAsync(APP_PLAY_STORE_URL), launchMode: LaunchMode.externalApplication);
        } else {
          commonLaunchUrl('${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}', launchMode: LaunchMode.externalApplication);
        }
      } else if (isIOS) {
        if (getStringAsync(APP_APPSTORE_URL).isNotEmpty) {
          commonLaunchUrl(getStringAsync(APP_APPSTORE_URL), launchMode: LaunchMode.externalApplication);
        }
      }
    },
  ));
  aboutList.add(AboutModel(
    title: locale.share,
    icon: ic_share,
    onTap: () async {
      if (isIOS) {
        SharePlus.instance.share(ShareParams(text: '${locale.share} $APP_NAME ${locale.app}\n\n$appStoreAppBaseURL'));
      } else {
        SharePlus.instance.share(ShareParams(text: '${locale.share} $APP_NAME ${locale.app}\n\n$playStoreBaseURL${await getPackageInfo().then((value) => value.packageName.validate())}'));
      }
    },
  ));
  aboutList.add(AboutModel(
    title: locale.about,
    icon: ic_about,
    onTap: () {
      AboutScreen().launch(context);
    },
  ));

  return aboutList;
}

Future<List<AboutModel>> getHelpList({required BuildContext context}) async {
  try {
    List<AboutModel> aboutList = [];

    // If configuration pages are already cached (populated in dashboard_fragment), use them
    if (appConfigurationResponseCached != null && appConfigurationResponseCached!.pages.isNotEmpty) {
      for (Pages page in appConfigurationResponseCached!.pages) {
        String iconPath;

        if (page.title == locale.privacyPolicy) {
          iconPath = ic_privacy_policy;
        } else if (page.title == locale.termsConditions) {
          iconPath = ic_terms_conditions;
        } else if (page.title == locale.FAQs) {
          iconPath = ic_faq;
        } else if (page.title == locale.helpCenter) {
          iconPath = ic_call;
        } else {
          iconPath = ic_default;
        }

        aboutList.add(AboutModel(
          title: page.title.validate(),
          icon: iconPath,
          onTap: () {
            checkIfLink(context, page.description.validate(), title: page.title.validate());
          },
        ));
      }

      return aboutList;
    }

    // Fallback: use persisted configuration strings if cache isn't available
    aboutList.add(AboutModel(
      title: locale.privacyPolicy,
      icon: ic_privacy_policy,
      onTap: () {
        checkIfLink(context, getStringAsync(ConfigurationKeyConst.PRIVACY_POLICY), title: locale.privacyPolicy);
      },
    ));
    aboutList.add(AboutModel(
      title: locale.termsConditions,
      icon: ic_terms_conditions,
      onTap: () {
        checkIfLink(context, getStringAsync(ConfigurationKeyConst.TERMS_CONDITION), title: locale.termsConditions);
      },
    ));
    aboutList.add(AboutModel(
    title: locale.faqs,
      icon: ic_faq,
      onTap: () {
      checkIfLink(context, getStringAsync(ConfigurationKeyConst.FAQ), title: locale.faqs);
      },
    ));
    aboutList.add(AboutModel(
      title: locale.helpCenter,
      icon: ic_call,
      onTap: () {
        launchCall(appStore.helplineNumber.validate());
      },
    ));

    return aboutList;
  } catch (e) {
    log("Error creating help list: $e");
    return [];
  }
}
