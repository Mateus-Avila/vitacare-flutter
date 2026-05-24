# VitaCare

Portal responsivo em Flutter para acompanhamento contínuo de pacientes, com autenticação Firebase, dados em Cloud Firestore, pesquisa, atualização em tempo real e consumo de API REST pública.

Projeto acadêmico da disciplina **Programação Mobile II** - UNAERP.

## Equipe

- Mateus Mendonça de Ávila
- Joaquim Neto

## Tecnologias

- Flutter SDK
- Dart
- Material Design 3
- Provider / ChangeNotifier
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- FlutterFire CLI
- HTTP
- API ViaCEP
- Firebase Hosting, para publicação futura

## Firebase

O projeto já está vinculado ao Firebase pelo FlutterFire CLI.

Arquivos principais:

- `lib/firebase_options.dart`
- `firebase.json`
- `android/app/google-services.json`

O app inicializa o Firebase em `lib/main.dart` com:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Funcionalidades Implementadas

### RF001 - Autenticação

- Login com e-mail e senha usando Firebase Authentication.
- Validação de campos obrigatórios.
- Validação de formato de e-mail.
- Loading durante login.
- Mensagens de erro e sucesso.
- Redirecionamento para o dashboard após login.
- Recuperação de senha real via `sendPasswordResetEmail`.

### RF002 - Cadastro de Usuário

- Cadastro com:
  - nome completo;
  - telefone;
  - cidade;
  - perfil ou área;
  - e-mail;
  - senha;
  - confirmação de senha.
- Criação do usuário no Firebase Authentication.
- Salvamento dos dados adicionais na coleção `usuarios`.
- Senha não é salva no Firestore.
- Senha forte obrigatória:
  - mínimo de 8 caracteres;
  - letra maiúscula;
  - letra minúscula;
  - número;
  - caractere especial.

### RF003 - Inserção no Firestore

O projeto usa quatro coleções principais, todas com `uid` do usuário logado:

- `pacientes`
- `registros_saude`
- `atividades_cuidado`
- `metas_cuidado`

Cada inserção valida campos obrigatórios, mostra loading/feedback e grava o `uid`.

### RF004 - Atualização no Firestore

A atualização foi implementada nas quatro coleções:

- editar paciente;
- editar registro de saúde;
- editar atividade de cuidado;
- editar meta de cuidado.

Antes de atualizar, o serviço verifica se o documento pertence ao usuário logado.

### RF005 - Recuperação em Tempo Real

As telas usam `StreamBuilder` com `ListView.builder`:

- listagem de pacientes;
- histórico de registros;
- alertas;
- atividades de cuidado;
- metas de cuidado;
- pesquisa.

As telas possuem estados de carregamento, erro, lista vazia e lista preenchida.

### RF006 - Pesquisa

Tela exclusiva de pesquisa:

- campo de busca;
- busca por nome, condição ou cuidador;
- filtro por `uid`;
- busca sem diferenciar maiúsculas/minúsculas;
- ordenação por:
  - nome;
  - data de cadastro;
  - status;
  - idade.

### RF007 - API REST Pública

Tela de consulta de CEP usando a API pública ViaCEP:

- serviço dedicado em `lib/services/api_service.dart`;
- loading;
- tratamento de erro;
- exibição de logradouro, bairro, cidade, UF, IBGE e DDD.

## Coleções do Firestore

### `usuarios/{uid}`

- `uid`
- `nome`
- `nomeLowercase`
- `telefone`
- `email`
- `cidade`
- `perfil`
- `criadoEm`
- `atualizadoEm`

### `pacientes/{docId}`

- `uid`
- `nome`
- `nomeLowercase`
- `idade`
- `condicaoCronica`
- `cuidador`
- `telefone`
- `status`
- `ultimaSistolica`
- `ultimaDiastolica`
- `ultimaGlicemia`
- `ultimoRegistroEm`
- `criadoEm`
- `atualizadoEm`

### `registros_saude/{docId}`

- `uid`
- `pacienteId`
- `pacienteNome`
- `pacienteNomeLowercase`
- `sistolica`
- `diastolica`
- `glicemia`
- `peso`
- `sintomas`
- `alimentacao`
- `locomocao`
- `humor`
- `sono`
- `adesaoMedicacao`
- `adesaoAtividades`
- `registradoPor`
- `observacoes`
- `status`
- `registradoEm`
- `atualizadoEm`

### `atividades_cuidado/{docId}`

- `uid`
- `pacienteId`
- `pacienteNome`
- `titulo`
- `tituloLowercase`
- `descricao`
- `prioridade`
- `status`
- `dataLimite`
- `concluida`
- `criadoEm`
- `atualizadoEm`

### `metas_cuidado/{docId}`

- `uid`
- `pacienteId`
- `pacienteNome`
- `titulo`
- `tituloLowercase`
- `descricao`
- `progresso`
- `dataInicio`
- `dataFim`
- `status`
- `criadoEm`
- `atualizadoEm`

## Separação por Usuário

Todos os dados gravados possuem `uid`.

Todas as consultas principais usam:

```dart
.where('uid', isEqualTo: currentUid)
```

Atualizações chamam verificação de propriedade do documento antes de salvar alterações.

## Estrutura Principal

```text
lib/
├── core/
├── models/
├── providers/
├── screens/
├── services/
├── theme/
├── widgets/
├── firebase_options.dart
└── main.dart
```

Serviços principais:

- `auth_service.dart`
- `firestore_service.dart`
- `api_service.dart`

## Como Rodar

```bash
flutter pub get
flutter run -d chrome
```

## Validação

```bash
flutter analyze
flutter test
flutter build web
```

Se não existir pasta `test/`, o comando `flutter test` pode não executar testes do projeto.

## Como Testar os Requisitos

1. Crie uma conta pela tela de cadastro.
2. Confirme que o usuário aparece no Firebase Authentication.
3. Confirme que os dados adicionais aparecem em `usuarios/{uid}`.
4. Faça logout e login com e-mail/senha.
5. Teste recuperação de senha.
6. Cadastre um paciente.
7. Edite o paciente na listagem.
8. Cadastre um registro de saúde.
9. Edite o registro no histórico.
10. Cadastre atividade e meta em "Ações e Metas".
11. Edite atividade e meta.
12. Abra a pesquisa e teste busca/ordenação.
13. Abra "Consulta CEP" e consulte um CEP válido.
14. Entre com outro usuário e confirme que os dados anteriores não aparecem.

## Roteiro do Vídeo de Apresentação

O vídeo deve demonstrar:

- login com Firebase Authentication;
- recuperação de senha;
- cadastro de usuário;
- dados adicionais salvos em `usuarios`;
- inserção no Firestore;
- atualização no Firestore;
- recuperação em tempo real com `StreamBuilder` e `ListView.builder`;
- pesquisa com ordenação;
- consumo da API ViaCEP;
- explicação breve de `auth_service.dart`, `firestore_service.dart` e `api_service.dart`;
- explicação do uso de `uid` para separar dados por usuário.

## Firebase Hosting

Não publique antes da autorização final.

Passo a passo futuro:

```bash
flutter build web
firebase init hosting
```

Durante o `firebase init hosting`:

- escolha o projeto Firebase já existente;
- use `build/web` como pasta pública;
- configure como single-page app, se solicitado.

Depois, somente quando autorizado:

```bash
firebase deploy
```

## Observação Acadêmica

O VitaCare tem caráter acadêmico e demonstrativo, mas os fluxos de autenticação, Firestore, pesquisa e API foram implementados de forma funcional para apresentação e avaliação.
