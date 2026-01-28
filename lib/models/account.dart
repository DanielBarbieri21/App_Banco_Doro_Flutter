import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required String lastName,
    required double balance,
    String? accountType,
  }) = _Account;

  factory Account.fromJson(Map<String, Object?> json) =>
      _$AccountFromJson(json);
}

/// Extensão para adicionar getters ao modelo Account
extension AccountExtension on Account {
  /// Formata o nome completo
  String get fullName => '$name $lastName';

  /// Formata o saldo em moeda
  String get formattedBalance => 'R\$ ${balance.toStringAsFixed(2)}';
}
