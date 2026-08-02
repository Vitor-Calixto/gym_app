Aqui está a versão completa e atualizada do seu **`README.md`**, rigorosamente estruturada dentro da organização que você especificou e refletindo o avanço atual do desenvolvimento do **FitClan** (autenticação, roteamento, estado com Riverpod, telas e painel de início).

---

### 📄 Conteúdo para o arquivo `README.md`

```markdown
## 🎯 1. Visão Geral & Pilares do Produto

### 1.1. Perfis Isolados
Interfaces dedicadas para Professor (gestão) e Aluno (execução), vinculados por um ID único de afiliação.

### 1.2. Treinos (Offline-first)
Fichas de treino e banco com mais de 200 exercícios disponíveis sem internet, utilizando mídias leves (WebP/MP4) e banco NoSQL.

### 1.3 Gamificação e Clãs
Sistema de acúmulo de XP, ranks de alunos e metas coletivas por treinos concluídos.

### 1.4 Check-in Anti-trapaça
Validação de presença na academia via geolocalização (GPS) ou leitura de QR Code.

### 1.5 Agendamento Inteligente
Sistema de reservas de horários com limite de vagas e fila de espera automática.

### 1.6 Avaliação Física
Registro de anamnese, cálculo de dobras cutâneas (Pollock/Faulkner) e gráficos de evolução temporal.

### 1.7 Segurança Total
Dados confidenciais protegidos via Tokens, Webhooks e Row Level Security (RLS). Dados de pagamento não trafegam na memória do app.

---

## 🛠️ 2. Stack Tecnológica

### 2.1 Frontend
2.1.2 **Flutter** - Performance nativa cross-platform (iOS/Android/Windows).

### 2.2 Estado
2.2.1 **Riverpod** - Injeção de dependências e reatividade segura com StateNotifier e AsyncValue.

### 2.3 Banco Local
2.3.1 **Isar DB** - Persistência NoSQL ultrarrápida para modo offline.

### 2.4 Roteamento
2.4.1 **GoRouter** - Navegação declarativa baseada em caminhos estritos (`/login`, `/signup`, `/home`).

### 2.5 Backend (BaaS)
2.5.1 **Supabase** - PostgreSQL, Auth, Storage, Row Level Security (RLS) e Edge Functions.

### 2.6 Pagamentos
2.6.1 **Asaas / Stripe** - Gateway seguro com tokens e webhooks.

### 2.7 Design System
2.7.1 **Flex Color Scheme** - Padronização visual, temas dinâmicos e Google Fonts. 

---

## 🗺️ 3. Arquitetura e Topologia do Sistema

**FitClan** utiliza uma topologia baseada em features independentes e um fluxo de dados unidirecional, operando sob os rigorosos padrões da **Clean Architecture** adaptada para **Feature-First**.

### 3.1 Apresentação Passiva:
As telas (UI) não tomam decisões. Elas apenas exibem o estado e capturam o toque do usuário.

### 3.2 Gerência de Estado Reativa:
O `Riverpod` atua como o sistema nervoso, orquestrando as requisições assíncronas e blindando a interface contra travamentos.

### 3.3 Backend as a Service:
Toda a carga de banco de dados, criptografia de senhas e persistência relacional é delegada ao **Supabase**.

### 3.4 Topologia do Sistema (Blueprint)

**3.4.1 Mundo Externo**  
Composto pelo usuário (Aluno / Professor) interagindo com a aplicação e pelo Supabase (BaaS) atuando na nuvem.

**3.4.2 Camada de Apresentação (UI)**  
As Telas (`login_screen.dart`, `signup_screen.dart`, `home_screen.dart`) capturam os dados e toques do usuário, enquanto o GoRouter (`app_router.dart`) gerencia a injeção e proteção das rotas de navegação.

**3.4.3 Camada de Controle e Estado (Domínio)**  
O Riverpod (`auth_controller.dart`) recebe ações da interface, emite e atualiza os estados (como `AsyncLoading`, `AsyncData`, `AsyncError`) e solicita operações de autenticação.

**3.4.4 Camada de Dados**  
O `auth_repository.dart` comunica-se diretamente com o Supabase através da API Client Segura para validar, persistir e consultar informações.

**3.4.5 Fluxos de Comunicação**  
O usuário interage com as Telas -> As Telas disparam ações para o Controller -> O Controller altera o estado da UI e aciona o Repositório -> O Repositório consulta o Supabase -> O Controller atualiza as Telas e o Router injeta o redirecionamento.

### 3.5 Estrutura Base (Deep Dive no Módulo Auth e Home)

**3.5.1 core/theme/**  
Define paleta de cores e tipografia. Uma mudança reflete em 100% do app instantaneamente.

**3.5.2 core/routing/**  
Implementa o GoRouter (`app_router.dart`), protegendo rotas com middlewares de redirecionamento baseados no estado.

**3.5.3 auth/data/auth_repository.dart**  
Envia e recebe dados puros (HTTP/Supabase). Trata as promessas (Futures) e retorna sucesso ou exceções.

**3.5.4 auth/domain/auth_controller.dart**  
O Cérebro (`StateNotifier`). Ao iniciar login/cadastro, emite `AsyncLoading`. Confirma em `AsyncData` ou falha em `AsyncError`.

**3.5.5 auth/presentation/login_screen.dart & signup_screen.dart**  
UI Passiva. Exibe botões, capta toques e reage ativando SnackBars (Toasts) ao ler erros do estado.

**3.5.6 home/presentation/home_screen.dart**  
Dashboard inicial do usuário com banner de treino do dia, métricas de carga e navegação para funcionalidades chave.

---

## 💎 4. Regras de Acesso e RBAC (Role-Based Access Control)

FitClan difere de apps convencionais por injetar **metadados corporativos** diretamente no momento do cadastro. 

No arquivo de `signup_screen.dart`, o usuário é obrigado a selecionar sua hierarquia operacional. Esses dados são enviados ao Repositório de Autenticação empacotados em um payload JSON anexo à criação da conta.

### 4.1 role: 'student'
O usuário verá treinos, metas e evolução na interface final. Acesso restrito a execução e check-ins.

### 4.2 role: 'trainer'
A UI será adaptada para montagem de fichas, acompanhamento de mensalidades e chat com múltiplos alunos. Ferramentas de auditoria ativadas.

### 4.3 full_name
Registrado de forma isolada para conformidade jurídica/fiscal, mantendo a integridade independente do perfil de exibição.

> **Nota Arquitetural:** Esta abordagem impede que a interface solicite dados complementares em fluxos posteriores, mitigando a existência de contas "órfãs" (contas criadas sem perfil definido devido à queda de conexão).

---

## 🚨 5. Modos de Falha e Efeitos (FMEA)

Guia de engenharia para resolução de problemas comuns e tratamento de exceções na esteira do aplicativo, garantindo que o usuário nunca fique preso em um "beco sem saída" na interface.

### 5.1.0 AuthException: Invalid login / 429 Rate Limit
Supabase rejeitou o hash da senha, e-mail não existe no banco ou houve excesso de requisições de confirmação.

**5.1.1** O `auth_controller` emite `AsyncError`. A UI detecta e exibe o erro traduzido no rodapé via SnackBar.

### 5.2 Botão Travado / Timeout
O estado travou em `AsyncLoading` devido à queda de internet durante o request de rede.

**5.2.1** Riverpod captura o timeout. A UI deve ser construída lendo `isLoading` e restaurar o estado interativo do botão após a falha.

### 5.3 GoException: no routes
A rota digitada, solicitada ou redirecionada não está mapeada no app.

**5.3.1** Registrar o caminho exato e absoluto (ex: `'/home'`) dentro da árvore principal no arquivo `app_router.dart`.

### 5.4 PostgrestException: code 42501 (RLS Error)
Tentativa de escrita/leitura na tabela `profiles` bloqueada pelas políticas do banco de dados.

**5.4.1** Aplicar as políticas de Row Level Security (RLS) no Supabase permitindo `INSERT` (`auth.uid() = id`) e `SELECT`.

---

## 🚀 6. Guia de Instalação Rápida

Procedimento padrão para provisionamento do ambiente local de desenvolvimento.

```bash
# 1. Navegue até o diretório raiz do projeto
cd C:\workspace\gym_app\gymapp

# 2. Limpeza profilática de cache e builds antigos
flutter clean

# 3. Resgate das dependências (Riverpod, Supabase, GoRouter, etc.)
flutter pub get

# 4. Compilação e Execução (Ex: Ambiente Windows Desktop ou Emulador)
flutter run

```

---

## 📅 7. Roadmap de Execução

* [x] **Fase 1 - Modelagem Supabase & Segurança:** Criação do Schema SQL (tabelas e relacionamentos) e regras de RLS (Row Level Security).
* [x] **Fase 2 - Setup Flutter & Arquitetura Local:** Estruturação de pastas (Feature-First), setup do Isar DB (offline) e configuração do Riverpod/GoRouter.
* [x] **Fase 3 - Auth & Vínculo:** Autenticação via Supabase, RBAC, fluxos de login, cadastro, navegação para Dashboard e gestão de sessão.
* [ ] **Fase 4 - Motor de Treinos & Sincronização:** CRUD de exercícios, templates e tela de execução offline isolando a UI do cronômetro.
* [ ] **Fase 5 - Gamificação & Agendamento:** Lógica de check-in geolocalizado, sistema de XP, ranks e reservas inteligentes.
* [ ] **Fase 6 - Pagamentos & Webhooks:** Integração com Gateway de Pagamentos (Asaas/Stripe) via tokens e liberação de acesso seguro por Edge Functions.

```

---

### 📤 Como atualizar o arquivo e subir pelo VS Code

1. Abra o arquivo `README.md` no seu projeto dentro do VS Code.
2. Substitua todo o conteúdo atual pelo código acima e salve (**`Ctrl + S`**).
3. Abra o terminal do VS Code e execute os comandos Git para subir as alterações:

```bash
# 1. Verifica os arquivos alterados
git status

# 2. Adiciona o README atualizado para o commit
git add README.md

# 3. Cria o commit descrevendo as melhorias
git commit -m "docs: atualiza README com arquitetura do projeto, RLS e dashboard inicial"

# 4. Envia as alterações para o seu repositório remoto (GitHub/GitLab)
git push

```