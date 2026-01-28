# 🏦 Banco Douro - Sistema de Gestão de Contas

Uma aplicação Flutter profissional de gestão de contas bancárias com integração GitHub Gist para persistência de dados.

## 📋 Visão Geral

Banco Douro é uma aplicação mobile desenvolvida com Flutter que permite gerenciar contas bancárias de forma simples e intuitiva. A aplicação utiliza GitHub Gist como backend para armazenar dados de forma segura.

## ✨ Recursos Principais

- **Autenticação**: Sistema de login com validação de e-mail e senha
- **Gestão de Contas**: Criar, ler, atualizar e deletar contas
- **Design Responsivo**: Interface adaptável para diferentes tamanhos de tela
- **Gerenciamento de Estado**: Riverpod para estado global robusto
- **Tratamento de Erros**: Exceções customizadas e feedback ao usuário
- **Tema Profissional**: Design system centralizado e consistente
- **Logs em Tempo Real**: Stream de logs para monitoramento

## 🛠️ Tecnologias Utilizadas

### Dependencies
- **flutter_riverpod**: Gerenciamento de estado reativo
- **freezed_annotation**: Geração de código para modelos imutáveis
- **json_serializable**: Serialização JSON automática
- **flutter_dotenv**: Carregamento de variáveis de ambiente
- **http**: Cliente HTTP para requisições
- **uuid**: Geração de IDs únicos
- **string_validator**: Validação de strings

### Dev Dependencies
- **build_runner**: Geração de código
- **freezed**: Gerador de código para classes imutáveis
- **riverpod_generator**: Gerador de código Riverpod

## 🚀 Como Começar

### Pré-requisitos

- Flutter 3.5.3 ou superior
- Dart 3.5.3 ou superior
- Git
- Token de API do GitHub (para escrever no Gist)

### Instalação

1. **Clone o repositório**
```bash
git clone <seu-repositorio>
cd flutter_banco_douro
```

2. **Configure variáveis de ambiente**
```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite .env com suas credenciais
GITHUB_API_KEY=seu_token_github
GITHUB_GIST_ID=seu_gist_id
```

3. **Instale dependências**
```bash
flutter pub get
```

4. **Gere código necessário**
```bash
flutter pub run build_runner build
```

5. **Execute a aplicação**
```bash
flutter run
```

## 📂 Estrutura do Projeto

```
lib/
├── config/
│   └── app_theme.dart          # Tema centralizado
├── exceptions/
│   └── app_exceptions.dart     # Exceções customizadas
├── models/
│   └── account.dart            # Modelo Account (com Freezed)
├── providers/
│   ├── account_provider.dart   # Providers de contas
│   └── auth_provider.dart      # Providers de autenticação
├── services/
│   └── account_service.dart    # Serviço de contas
├── ui/
│   ├── home_screen.dart        # Tela principal
│   ├── login_screen.dart       # Tela de login
│   └── widgets/
│       ├── account_widget.dart
│       └── add_account_modal.dart
└── main.dart                   # Ponto de entrada
```

## 🔑 Configuração do GitHub Gist

1. Crie um token de acesso pessoal em https://github.com/settings/tokens
   - Selecione escopo `gist`

2. Crie um novo Gist com um arquivo `accounts.json`
```json
[]
```

3. Copie o ID do Gist da URL (ex: `3a23981583ce0672cf94fee4978a83ff`)

4. Atualize o arquivo `.env` com suas credenciais

## 🎨 Design System

### Cores Principais
- **Primária**: `#2C3E50` (Azul Escuro)
- **Secundária**: `#E67E22` (Laranja)
- **Sucesso**: `#27AE60` (Verde)
- **Erro**: `#E74C3C` (Vermelho)
- **Info**: `#3498DB` (Azul)

### Tipografia
- Display Large: 32px Bold
- Headline: 20px Semi-bold
- Body: 14px Regular
- Caption: 12px Regular

## 🔐 Segurança

- ✅ API Keys armazenadas em variáveis de ambiente (`.env`)
- ✅ Validação de entrada em todos os formulários
- ✅ Tratamento robusto de erros HTTP
- ✅ Timeout em requisições (10 segundos)
- ✅ Serialização segura de dados

## 📦 Modelos de Dados

### Account
```dart
class Account {
  String id;              // ID único (UUID)
  String name;            // Nome do titular
  String lastName;        // Sobrenome
  double balance;         // Saldo em R$
  String? accountType;    // Tipo: Corrente, Poupança, Investimento
}
```

## 🧪 Tratamento de Erros

A aplicação implementa exceções customizadas:

- **NetworkException**: Erros de conexão
- **AuthException**: Falhas de autenticação
- **ValidationException**: Erros de validação
- **NotFoundException**: Recurso não encontrado
- **ServerException**: Erros do servidor
- **GeneralException**: Erros genéricos

## 🌐 APIs Utilizadas

### GitHub Gist API
- **Endpoint**: `https://api.github.com/gists/{gist_id}`
- **Métodos**: GET (ler), PATCH (atualizar)
- **Autenticação**: Bearer Token

## 📊 Gerenciamento de Estado (Riverpod)

```dart
// Providers disponíveis
accountsProvider          // FutureProvider<List<Account>>
accountServiceProvider    // Provider<AccountService>
authProvider             // StateProvider<bool>
userProvider             // StateProvider<String?>
logsStreamProvider        // StreamProvider
```

## 🎯 Próximas Melhorias

- [ ] Autenticação real com back-end
- [ ] Suporte a múltiplos usuários
- [ ] Histórico de transações
- [ ] Gráficos de saldo
- [ ] Notificações push
- [ ] Sincronização offline
- [ ] Testes unitários
- [ ] Testes de integração
- [ ] CI/CD com GitHub Actions

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 👤 Autor

**Daniel Barbieri**
- GitHub: [@DanielBarbieri21](https://github.com/DanielBarbieri21)
- Gist: [3a23981583ce0672cf94fee4978a83ff](https://gist.github.com/DanielBarbieri21/3a23981583ce0672cf94fee4978a83ff)

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Faça um Fork
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request


Para reportar bugs ou sugerir melhorias, abra uma issue no repositório.




