
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constants.dart';

part 'roles_and_permission_store.g.dart';

class RolesAndPermissionStore = _RolesAndPermissionStore with _$RolesAndPermissionStore;

abstract class _RolesAndPermissionStore with Store {

  @observable
  bool bank = getBoolAsync(BANK);

  @observable
  bool bankAdd = getBoolAsync(BANK_LIST);

  @observable
  bool bankEdit = getBoolAsync(BANK_EDIT);

  @observable
  bool bankDelete = getBoolAsync(BANK_DELETE);

  @observable
  bool bankList = getBoolAsync(BANK_LIST);


  @observable
  bool wallet = getBoolAsync(WALLET);

  @observable
  bool walletAdd = getBoolAsync(WALLET_ADD);

  @observable
  bool walletEdit = getBoolAsync(WALLET_EDIT);

  @observable
  bool walletDelete = getBoolAsync(WALLET_DELETE);

  @observable
  bool walletList = getBoolAsync(WALLET_LIST);


  @action
  Future<void> setBank(bool val) async {
    bank = val;
    await setValue(BANK, val);
  }

  @action
  Future<void> setBankAdd(bool  val) async {
    bankAdd = val;
    await setValue(BANK_ADD, val);
  }

  @action
  Future<void> setBankEdit(bool val) async {
    bankEdit = val;
    await setValue(BANK_EDIT, val);
  }

  @action
  Future<void> setBankDelete(bool val) async {
    bankDelete = val;
    await setValue(BANK_DELETE, val);
  }

  @action
  Future<void> setBankList(bool val) async {
    bankList = val;
    await setValue(BANK_LIST, val);
  }



  @action
  Future<void> setWallet(bool val) async {
    wallet = val;
    await setValue(WALLET, val);
  }

  @action
  Future<void> setWalletAdd(bool val) async {
    walletAdd = val;
    await setValue(WALLET_ADD, val);
  }

  @action
  Future<void> setWalletEdit(bool val) async {
    walletEdit = val;
    await setValue(WALLET_EDIT, val);
  }

  @action
  Future<void> setWalletDelete(bool val) async {
    walletDelete = val;
    await setValue(WALLET_DELETE, val);
  }

  @action
  Future<void> setWalletList(bool val) async {
    walletList = val;
    await setValue(WALLET_LIST, val);
  }


}
