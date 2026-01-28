import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para autenticação (simplificado para demo)
final authProvider = StateProvider<bool>((ref) => false);

// Provider para usuário logado
final userProvider = StateProvider<String?>((ref) => null);

// Provider para status de autenticação
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider);
});
