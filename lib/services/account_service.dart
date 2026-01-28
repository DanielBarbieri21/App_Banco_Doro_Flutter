import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../exceptions/app_exceptions.dart';
import '../models/account.dart';

class AccountService {
  late final String _githubApiKey;
  late final String _githubGistId;
  late final String _baseUrl;
  
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get streamInfos => _streamController.stream;

  AccountService() {
    _githubApiKey = dotenv.env['GITHUB_API_KEY'] ?? '';
    _githubGistId = dotenv.env['GITHUB_GIST_ID'] ?? '';
    _baseUrl = 'https://api.github.com/gists/$_githubGistId';

    if (_githubApiKey.isEmpty || _githubGistId.isEmpty) {
      _addLog('⚠️ Variáveis de ambiente não configuradas!');
    }
  }

  Future<List<Account>> getAll() async {
    try {
      _addLog('📥 Iniciando requisição de contas...');

      final response = await http
          .get(
            Uri.parse(_baseUrl),
            headers: _getHeaders(),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw NetworkException(
              message: 'Tempo limite de conexão excedido',
              code: 'TIMEOUT',
            ),
          );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException(
          message: 'Token de autenticação inválido',
          code: 'AUTH_FAILED',
        );
      }

      if (response.statusCode == 404) {
        throw NotFoundException(
          message: 'Gist não encontrado',
          code: 'GIST_NOT_FOUND',
        );
      }

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Erro ao buscar contas: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final mapResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final accountsContent = mapResponse['files']?['accounts.json']?['content'];

      if (accountsContent == null) {
        throw NotFoundException(
          message: 'Arquivo accounts.json não encontrado no gist',
        );
      }

      final listDynamic = jsonDecode(accountsContent) as List<dynamic>;
      final listAccounts = <Account>[];

      for (final item in listDynamic) {
        if (item is Map<String, dynamic>) {
          listAccounts.add(Account.fromJson(item));
        }
      }

      _addLog('✅ ${listAccounts.length} contas carregadas com sucesso');
      return listAccounts;
    } on AppException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      _addLog('❌ Erro: ${e.toString()}');
      throw NetworkException(
        message: 'Erro ao conectar com o servidor',
        originalException: e as Exception?,
      );
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      _addLog('➕ Adicionando conta: ${account.name} ${account.lastName}');

      final listAccounts = await getAll();
      listAccounts.add(account);
      await _save(listAccounts, accountName: account.fullName);

      _addLog('✅ Conta ${account.fullName} adicionada com sucesso');
    } on AppException {
      rethrow;
    } catch (e) {
      _addLog('❌ Erro ao adicionar conta: ${e.toString()}');
      throw GeneralException(
        message: 'Erro ao adicionar conta',
        originalException: e as Exception?,
      );
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      _addLog('✏️ Atualizando conta: ${account.name}');

      var listAccounts = await getAll();
      final index = listAccounts.indexWhere((a) => a.id == account.id);

      if (index == -1) {
        throw NotFoundException(
          message: 'Conta não encontrada',
        );
      }

      listAccounts[index] = account;
      await _save(listAccounts, accountName: account.fullName);

      _addLog('✅ Conta ${account.fullName} atualizada com sucesso');
    } on AppException {
      rethrow;
    } catch (e) {
      _addLog('❌ Erro ao atualizar conta: ${e.toString()}');
      throw GeneralException(
        message: 'Erro ao atualizar conta',
        originalException: e as Exception?,
      );
    }
  }

  Future<void> deleteAccount(String accountId, String accountName) async {
    try {
      _addLog('🗑️ Deletando conta: $accountName');

      var listAccounts = await getAll();
      listAccounts.removeWhere((a) => a.id == accountId);
      await _save(listAccounts, accountName: accountName);

      _addLog('✅ Conta $accountName deletada com sucesso');
    } on AppException {
      rethrow;
    } catch (e) {
      _addLog('❌ Erro ao deletar conta: ${e.toString()}');
      throw GeneralException(
        message: 'Erro ao deletar conta',
        originalException: e as Exception?,
      );
    }
  }

  Future<void> _save(
    List<Account> listAccounts, {
    String accountName = '',
  }) async {
    try {
      final listContent = listAccounts.map((a) => a.toJson()).toList();
      final content = jsonEncode(listContent);

      final response = await http
          .patch(
            Uri.parse(_baseUrl),
            headers: _getHeaders(),
            body: jsonEncode({
              'files': {
                'accounts.json': {
                  'content': content,
                }
              }
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw NetworkException(
              message: 'Tempo limite de conexão excedido',
            ),
          );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException(
          message: 'Falha de autenticação ao salvar',
        );
      }

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Erro ao salvar contas: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      _addLog('💾 Dados salvos com sucesso');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        message: 'Erro ao salvar dados',
        originalException: e as Exception?,
      );
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Accept': 'application/vnd.github.v3+json',
      'Authorization': 'Bearer $_githubApiKey',
      'Content-Type': 'application/json',
    };
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().split('.').first;
    final log = '[$timestamp] $message';
    _streamController.add(log);
  }

  void dispose() {
    _streamController.close();
  }
}

