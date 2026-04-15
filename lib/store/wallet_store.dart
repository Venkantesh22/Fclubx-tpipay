
import 'package:frezka/main.dart';
import 'package:frezka/network/rest_apis.dart';
import 'package:mobx/mobx.dart';
part 'wallet_store.g.dart';

class WalletStore = _WalletStore with _$WalletStore;

abstract class _WalletStore with Store {


  @observable
  num userWalletAmount = 0.0;

  @action
  Future<void> setUserWalletAmount() async {
    if (appStore.isLoggedIn) {
      userWalletAmount = await getUserWalletBalance();
    } else {
      userWalletAmount = 0.0;
    }
  }

}
