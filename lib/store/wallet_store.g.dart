// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WalletStore on _WalletStore, Store {
  late final _$userWalletAmountAtom =
      Atom(name: '_WalletStore.userWalletAmount', context: context);

  @override
  num get userWalletAmount {
    _$userWalletAmountAtom.reportRead();
    return super.userWalletAmount;
  }

  @override
  set userWalletAmount(num value) {
    _$userWalletAmountAtom.reportWrite(value, super.userWalletAmount, () {
      super.userWalletAmount = value;
    });
  }

  late final _$setUserWalletAmountAsyncAction =
      AsyncAction('_WalletStore.setUserWalletAmount', context: context);

  @override
  Future<void> setUserWalletAmount() {
    return _$setUserWalletAmountAsyncAction
        .run(() => super.setUserWalletAmount());
  }

  @override
  String toString() {
    return '''
userWalletAmount: ${userWalletAmount}
    ''';
  }
}
