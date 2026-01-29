import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../exceptions/app_exceptions.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import 'widgets/account_widget.dart';
import 'widgets/add_account_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsyncValue = ref.watch(accountsProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Sistema de Gestão de Contas'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(userProvider);
                  return Text(
                    user ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.white,
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja realmente sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        authNotifier.state = false;
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, 'login');
                      },
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => const AddAccountModal(),
          );
        },
        tooltip: 'Adicionar conta',
        child: const Icon(Icons.add),
      ),
      body: accountsAsyncValue.when(
        // Carregando
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // Erro
        error: (error, stackTrace) {
          String errorMessage = 'Erro ao carregar contas';
          
          if (error is AuthException) {
            errorMessage = 'Falha de autenticação. Verifique suas credenciais.';
          } else if (error is NetworkException) {
            errorMessage = 'Erro de conexão. Verifique sua internet.';
          } else if (error is NotFoundException) {
            errorMessage = 'Arquivo de contas não encontrado.';
          } else if (error is AppException) {
            errorMessage = error.message;
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(accountsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.error.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.invalidate(accountsProvider);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        // Sucesso
        data: (accounts) {
          if (accounts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(accountsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color:
                                  AppTheme.mediumGrey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma conta',
                              style:
                                  Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicione uma conta para começar',
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            FloatingActionButton.extended(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) =>
                                      const AddAccountModal(),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Conta'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(accountsProvider);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total de Contas',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gerencie suas contas bancárias',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${accounts.length}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return AccountWidget(account: account);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
