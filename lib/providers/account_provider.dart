import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/account_service.dart';

// Provider da instância do AccountService (singleton)
final accountServiceProvider = Provider((ref) => AccountService());

// Provider para obter todas as contas (com cache)
final accountsProvider = FutureProvider<List<Account>>((ref) {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getAll();
});

// Provider para gerenciar o estado de carregamento
final accountsLoadingProvider = StateProvider<bool>((ref) => false);

// Provider para gerenciar erros
final accountErrorProvider = StateProvider<String?>((ref) => null);

// Provider para stream de logs
final logsStreamProvider = StreamProvider((ref) {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.streamInfos;
});

// Notifier para gerenciar conta selecionada
final selectedAccountProvider = StateProvider<Account?>((ref) => null);
