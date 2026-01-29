import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_validator/string_validator.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../exceptions/app_exceptions.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';

class AddAccountModal extends ConsumerStatefulWidget {
  const AddAccountModal({super.key});

  @override
  ConsumerState<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends ConsumerState<AddAccountModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _balanceController = TextEditingController();

  String _accountType = 'Corrente';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (!isAlpha(value)) {
      return 'Nome deve conter apenas letras';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Sobrenome é obrigatório';
    }
    if (!isAlpha(value)) {
      return 'Sobrenome deve conter apenas letras';
    }
    return null;
  }

  String? _validateBalance(String? value) {
    if (value == null || value.isEmpty) {
      _balanceController.text = '0.00';
      return null;
    }
    if (!isFloat(value)) {
      return 'Saldo deve ser um número válido';
    }
    return null;
  }

  Future<void> _handleAddAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final account = Account(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        accountType: _accountType,
      );

      final accountService = ref.read(accountServiceProvider);
      await accountService.addAccount(account);

      if (mounted) {
        // Invalidar cache das contas
        ref.invalidate(accountsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conta ${account.fullName} adicionada com sucesso!'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showErrorDialog('Erro de Autenticação', e.message);
    } on NetworkException catch (e) {
      _showErrorDialog('Erro de Conexão', e.message);
    } on AppException catch (e) {
      _showErrorDialog('Erro', e.message);
    } catch (e) {
      _showErrorDialog('Erro Desconhecido', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                24,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mediumGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Adicionar Nova Conta',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Preencha os dados abaixo para criar uma nova conta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Formulário
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nome
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      label: Text('Nome'),
                      hintText: 'João',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  // Sobrenome
                  TextFormField(
                    controller: _lastNameController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      label: Text('Sobrenome'),
                      hintText: 'Silva',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: _validateLastName,
                  ),
                  const SizedBox(height: 16),
                  // Saldo Inicial
                  TextFormField(
                    controller: _balanceController,
                    enabled: !_isLoading,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      label: Text('Saldo Inicial'),
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: _validateBalance,
                  ),
                  const SizedBox(height: 16),
                  // Tipo de Conta
                  DropdownButtonFormField<String>(
                    value: _accountType,
                    decoration: const InputDecoration(
                      label: Text('Tipo de Conta'),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Corrente',
                        child: Text('Corrente'),
                      ),
                      DropdownMenuItem(
                        value: 'Poupança',
                        child: Text('Poupança'),
                      ),
                      DropdownMenuItem(
                        value: 'Investimento',
                        child: Text('Investimento'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _accountType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAddAccount,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.white,
                                    ),
                                  ),
                                )
                              : const Text('Adicionar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
