# VitaCare

## Visão geral

O **VitaCare** é um portal responsivo desenvolvido em **Flutter** com foco no acompanhamento contínuo de pacientes, especialmente idosos e pessoas com doenças crônicas. O sistema foi concebido como um **trabalho acadêmico** da disciplina **Programação Mobile II**, da **UNAERP - Universidade de Ribeirão Preto**.

Este projeto foi desenvolvido pelos alunos:

- **Mateus Ávila**
- **Joaquim Neto**

## Objetivo do projeto

O objetivo do VitaCare é demonstrar, por meio de um aplicativo multiplataforma, uma solução digital para apoio à documentação do cuidado e à coordenação entre profissionais de saúde, cuidadores e familiares.

O sistema busca substituir anotações dispersas e registros em papel por uma interface moderna, simples e intuitiva, permitindo registrar e consultar informações importantes de acompanhamento clínico e operacional.

## Contexto do VitaCare

O projeto parte de um problema real: pacientes com condições crônicas, como **diabetes**, **hipertensão** e **DPOC**, frequentemente precisam de monitoramento contínuo. Na prática, porém, é comum haver:

- registros feitos manualmente em papel;
- esquecimento de medicações e atividades;
- dificuldade de comunicação entre cuidadores, equipe clínica e familiares;
- baixa centralização das informações entre consultas.

O VitaCare foi pensado para atender esse cenário, oferecendo uma base demonstrativa para:

- registrar sinais de saúde;
- organizar dados do paciente e do cuidador;
- manter histórico dos registros;
- visualizar alertas clínicos;
- apoiar a coordenação do cuidado.

## Escopo acadêmico

Este sistema foi desenvolvido com foco nos requisitos da disciplina, contemplando:

- elaboração de interfaces gráficas completas;
- fluxo de navegação entre telas;
- gerenciamento de estado com `ChangeNotifier` e `Provider`;
- formulários com validação;
- uso de `SnackBar` e `AlertDialog`;
- listagem de dados com `ListView`;
- implementação de funcionalidades específicas relacionadas ao tema escolhido.

O projeto possui caráter **acadêmico e demonstrativo**. Algumas funcionalidades representam uma simulação de comportamento esperado em um produto real, como por exemplo a recuperação de senha por e-mail.

## Funcionalidades implementadas

### Funcionalidades obrigatórias

- **Login de usuário**
- **Cadastro de usuário**
- **Recuperação de senha**
- **Tela Sobre**

### Funcionalidades específicas do VitaCare

- **Cadastro de paciente**
- **Listagem de pacientes**
- **Registro de dados de saúde**
- **Histórico de registros**
- **Alertas e status do paciente**

## O que pode ser registrado no sistema

O VitaCare permite registrar e exibir, em ambiente demonstrativo:

- pressão arterial sistólica e diastólica;
- glicemia;
- peso;
- sintomas observados;
- alimentação;
- locomoção;
- humor;
- sono;
- adesão medicamentosa;
- adesão às atividades planejadas;
- observações clínicas;
- identificação de quem realizou o registro.

Além disso, o histórico apresenta indicadores resumidos de acompanhamento, como:

- média do período;
- variação absoluta e percentual;
- percentual de leituras em faixa ideal;
- adesão aos registros;
- tendência simplificada;
- classificação automática do acompanhamento em **melhora**, **estabilidade** ou **piora**.

## Como acessar o sistema

Ao abrir o aplicativo, a tela inicial exibida é a de login.

### Credenciais de acesso padrão

Use a conta demonstrativa abaixo para entrar no sistema:

- **E-mail:** `admin@vitacare.com`
- **Senha:** `123456`

Também é possível:

- criar uma nova conta pela tela de cadastro;
- acessar a funcionalidade **Esqueceu a senha?**;
- entrar no painel principal após autenticação válida.

## Manual rápido de utilização

### 1. Login

- Abra o aplicativo.
- Informe e-mail e senha.
- Clique em **Entrar**.

Se os dados estiverem corretos, o sistema abrirá o painel principal.

### 2. Cadastro de novo usuário

- Na tela de login, clique em **Cadastrar**.
- Preencha nome, e-mail, telefone, senha e confirmação de senha.
- Clique em **Cadastrar**.

Após validação, o acesso ao sistema será liberado.

### 3. Recuperação de senha

- Na tela de login, clique em **Esqueceu a senha?**
- Informe o e-mail cadastrado.
- Clique em **Enviar recuperação**.

Nesta entrega acadêmica, o envio de recuperação é simulado por mensagem na interface.

### 4. Navegação principal

Após o login, utilize o menu lateral para acessar:

- Dashboard
- Cadastro de Paciente
- Listagem de Pacientes
- Registro de Dados
- Histórico de Registros
- Alertas e Status
- Sobre o App

### 5. Cadastro de paciente

- Acesse **Cadastro de Paciente**.
- Preencha os dados obrigatórios.
- Clique em **Salvar paciente**.

O paciente será adicionado à base demonstrativa do sistema.

### 6. Registro de dados de saúde

- Acesse **Registro de Dados**.
- Selecione um paciente.
- Preencha os indicadores clínicos e de cuidado.
- Informe o responsável pelo registro.
- Clique em **Salvar registro**.

Se os valores indicarem risco, o sistema poderá sugerir acesso à tela de alertas.

### 7. Histórico de registros

- Acesse **Histórico de Registros**.
- Filtre por paciente, se desejar.
- Consulte os registros realizados e os indicadores resumidos de evolução.

### 8. Alertas e status

- Acesse **Alertas e Status**.
- Consulte pacientes com prioridade alta.
- Visualize orientações rápidas de acompanhamento para casos críticos.

### 9. Tela Sobre

- Acesse **Sobre o App** pelo menu.
- Consulte o objetivo do projeto, contexto, equipe e informações acadêmicas.

## Estrutura geral do projeto

O código está organizado em pastas principais:

- `lib/screens` para as telas do sistema;
- `lib/widgets` para componentes reutilizáveis;
- `lib/providers` para gerenciamento de estado;
- `lib/models` para as entidades do domínio;
- `lib/core` para rotas, validações, feedback e utilitários;
- `lib/theme` para identidade visual e personalização dos componentes.

## Tecnologias utilizadas

- **Flutter SDK**
- **Dart**
- **Provider**
- **ChangeNotifier**
- **Material Design 3**
- **Google Fonts**

## Como clonar o projeto

```bash
git clone <url-do-repositorio>
cd vitacare-flutter
```

Se estiver usando GitHub, substitua `<url-do-repositorio>` pela URL real do repositório.

## Como instalar as dependências

```bash
flutter pub get
```

## Como executar o sistema

### Web

```bash
flutter run -d chrome
```

### Windows

```bash
flutter run -d windows
```

### Dispositivo ou emulador

```bash
flutter run
```

## Como gerar build

### Build Web

```bash
flutter build web
```

### Build Windows

```bash
flutter build windows
```

## Requisitos para execução

Antes de rodar o projeto, é recomendado ter instalado:

- Flutter SDK configurado no ambiente;
- Dart SDK;
- navegador Chrome ou outro dispositivo compatível;
- Visual Studio Code ou Android Studio;
- suporte à plataforma desejada habilitado no Flutter.

Você pode verificar a instalação do Flutter com:

```bash
flutter doctor
```

## Observações finais

O VitaCare foi desenvolvido como uma aplicação acadêmica com foco em:

- usabilidade;
- design minimalista;
- navegação clara;
- organização de código;
- aderência aos requisitos da disciplina.

O projeto representa uma base funcional de demonstração, adequada para apresentação acadêmica e evolução futura.
