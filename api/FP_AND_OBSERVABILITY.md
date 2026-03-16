# Documentação: Conceitos de Programação Funcional e Observabilidade em Elixir (com exemplos do Bankcursor)

Este documento explora dois aspectos cruciais do desenvolvimento de software em Elixir, utilizando como base os módulos `AccountSupervisor`, `AccountWorker`, `TransactionRecord` e `TransactionRouter` do sistema Bankcursor: os conceitos de Programação Funcional (FP) e as práticas de Observabilidade.

---

## Parte 1: Conceitos de Programação Funcional em Elixir (com exemplos do Bankcursor)

A linguagem Elixir é construída sobre a Erlang Virtual Machine (BEAM) e adota fortemente o paradigma de Programação Funcional (FP). Isso se reflete na forma como o código é estruturado, na manipulação de dados e na abordagem à concorrência. Abaixo, exploramos os principais conceitos de FP presentes nos módulos analisados do sistema Bankcursor.

---

### 1. Imutabilidade (Immutability)

Em FP, os dados são imutáveis, o que significa que uma vez criados, não podem ser alterados. Em vez de modificar um valor existente, as operações retornam uma nova versão do dado com as alterações desejadas. Isso simplifica o raciocínio sobre o fluxo de dados e ajuda a prevenir efeitos colaterais inesperados, além de ser fundamental para a concorrência sem bloqueios.

**Exemplo em `Bankcursor.Accounts.AccountWorker`:**

```elixir
# Em execute_transaction/1
Multi.new()
|> Multi.update(
  :deposit,
  Account.changeset(account, %{balance: Decimal.add(account.balance, value)})
)
|> Multi.update(:transaction, TransactionRecord.changeset(tx, %{status: :completed}))
|> Repo.transaction()
```

Aqui, `Account.changeset/2` e `TransactionRecord.changeset/2` não modificam o `account` ou `tx` originais. Em vez disso, eles retornam um novo `Changeset` (estrutura de dados Ecto) que descreve as alterações a serem aplicadas. Quando `Repo.transaction()` é chamado, ele usa essas descrições para criar ou atualizar registros no banco de dados, mas os objetos Elixir originais permanecem inalterados na memória do processo.

**Exemplo em `Bankcursor.Accounts.TransactionRecord`:**

```elixir
# Em changeset/2
def changeset(struct, attrs) do
  struct
  |> cast(attrs, @required_params ++ @optional_params ++ [:validation_digest, :error_reason])
  |> validate_required(@required_params)
end
```

A função `changeset/2` recebe uma `struct` e um mapa de `attrs`. Ela retorna um *novo* `Changeset` com as informações de validação e as alterações propostas. A `struct` original passada como argumento permanece intocada.

---

### 2. Funções Puras (Pure Functions)

Uma função pura tem duas características principais:
1.  Dado o mesmo input, ela sempre retorna o mesmo output.
2.  Não causa efeitos colaterais (e.g., modificações de estado global, I/O, etc.).

Embora muitas funções em sistemas reais envolvam I/O (como acesso ao banco de dados), Elixir incentiva a isolar efeitos colaterais para manter a maior parte do código pura, tornando-o mais fácil de testar e raciocinar.

**Exemplo em `Bankcursor.Accounts.AccountWorker`:**

```elixir
# Em via_tuple/1
defp via_tuple(account_id),
  do: {:via, Registry, {Bankcursor.Accounts.AccountRegistry, account_id}}
```

A função `via_tuple/1` é um exemplo perfeito de uma função pura. Para qualquer `account_id` dado, ela sempre retornará a mesma tupla. Ela não modifica nenhum estado externo e não realiza I/O.

---

### 3. Pattern Matching (Casamento de Padrões)

Pattern matching é uma poderosa ferramenta em Elixir para controlar o fluxo do programa e desestruturar dados. Permite que você defina diferentes implementações de uma função (ou cláusulas de função) que serão selecionadas com base na forma e/ou conteúdo dos argumentos passados.

**Exemplo em `Bankcursor.Accounts.AccountWorker`:**

```elixir
# Múltiplas cláusulas para execute_transaction/1
defp execute_transaction(
       %TransactionRecord{type: :deposit, account_id: account_id, value: value} = tx
     ) do ... end

defp execute_transaction(
       %TransactionRecord{type: :withdraw, account_id: account_id, value: value} = tx
     ) do ... end

defp execute_transaction(
       %TransactionRecord{
         type: :transfer,
         account_id: from_id,
         recipient_account_id: to_id,
         value: value
       } = tx
     ) do ... end

# Múltiplas cláusulas para handle_db_transaction/2
defp handle_db_transaction({:ok, %{transaction: completed_tx}}, _) do ... end
defp handle_db_transaction({:error, _op, _reason, _changes}, tx) do ... end
```

Aqui, a função `execute_transaction` possui três cláusulas diferentes, cada uma casando com um tipo específico de `%TransactionRecord{}`. O Elixir seleciona automaticamente a cláusula correta com base no `type` da transação. Da mesma forma, `handle_db_transaction` casa com o resultado de uma operação de `Repo.transaction` (`{:ok, ...}` ou `{:error, ...}`).

**Exemplo em `Bankcursor.Accounts.TransactionRouter`:**

```elixir
# Em handle_info/2
def handle_info({:new_transaction, transaction}, state) do
  AccountSupervisor.start_worker(transaction.account_id)
  AccountWorker.process(transaction)
  {:noreply, state}
end
```

A função `handle_info` casa com uma tupla específica `{:new_transaction, transaction}`. Se uma mensagem com um padrão diferente chegasse, esta cláusula não seria executada, e o `GenServer` procuraria outra cláusula ou levantaria um erro.

---

### 4. O Operador Pipeline (`|>`)

O operador pipeline (`|>`) é uma característica sintática que facilita a leitura de sequências de transformações de dados, promovendo um estilo de código que se assemelha a uma "linha de montagem" funcional. O resultado da expressão à esquerda do `|>` é passado como o primeiro argumento da função à direita.

**Exemplo em `Bankcursor.Accounts.AccountWorker`:**

```elixir
# Em handle_cast/2
fresh_tx
|> TransactionRecord.changeset(%{status: :processing})
|> Repo.update()
```

Neste exemplo, `fresh_tx` é passado como o primeiro argumento para `TransactionRecord.changeset/2`. O resultado dessa chamada é então passado como o primeiro argumento para `Repo.update/1`. Isso torna a sequência de operações muito clara e linear.

---

### 5. Concorrência Baseada em Atores (Actor Model)

Elixir herda o modelo de atores de Erlang, onde processos leves e isolados (atores) se comunicam exclusivamente via troca de mensagens. Isso permite construir sistemas concorrentes e tolerantes a falhas de forma robusta e explícita. O estado é mantido dentro de cada ator, isolado, e acessível apenas por mensagens, o que alinha-se perfeitamente com o conceito de imutabilidade.

**Exemplo em `Bankcursor.Accounts.TransactionRouter` e `Bankcursor.Accounts.AccountWorker`:**

```elixir
# Em TransactionRouter.handle_info/2
AccountWorker.process(transaction)

# Em AccountWorker
def process(transaction) do
  account_id = transaction.account_id
  GenServer.cast(via_tuple(account_id), {:process, transaction})
end
```

Quando o `TransactionRouter` recebe uma nova transação, ele não executa a lógica diretamente. Em vez disso, ele envia uma mensagem para o `AccountWorker` apropriado (identificado por `account_id`) usando `GenServer.cast`. Cada `AccountWorker` é um processo independente (ator) que gerencia o estado de uma conta específica, processando mensagens de forma sequencial, mas concorrentemente com outros `AccountWorker`s.

**Exemplo em `Bankcursor.Accounts.AccountSupervisor`:**

```elixir
# Em AccountSupervisor.start_worker/1
def start_worker(account_id) do
  DynamicSupervisor.start_child(__MODULE__, {Bankcursor.Accounts.AccountWorker, account_id: account_id})
end
```

O `AccountSupervisor` gerencia o ciclo de vida desses `AccountWorker`s (atores), iniciando-os dinamicamente conforme a demanda e reiniciando-os em caso de falha, demonstrando a tolerância a falhas inerente ao modelo de atores.

---

## Parte 2: Conceitos de Observabilidade em Sistemas Elixir (com exemplos do Bankcursor)

A observabilidade é a capacidade de inferir o estado interno de um sistema a partir de seus dados externos. Em sistemas distribuídos e assíncronos como os construídos com Elixir, é crucial para entender o comportamento do sistema, diagnosticar problemas, otimizar performance e garantir a confiabilidade. Os pilares da observabilidade são Logs, Métricas e Tracing.

---

### 1. Logging (Registros)

Logging é a prática de registrar eventos importantes que ocorrem dentro de um aplicativo. Logs são como um "diário" do seu sistema, fornecendo narrativas detalhadas sobre o que aconteceu, quando e por quê.

### Importância:
*   **Diagnóstico de Erros:** Ajuda a identificar a causa raiz de falhas e comportamentos inesperados.
*   **Auditoria e Conformidade:** Fornece um registro auditável de ações e transações.
*   **Depuração:** Permite entender o fluxo de execução em ambientes de produção.

### Exemplos no Bankcursor:

#### `Bankcursor.Accounts.AccountWorker`
Este módulo é um ponto crítico para logs detalhados, pois é o principal executor das transações.

*   **Início de Worker:** `Logger.info("AccountWorker started for account ID: #{account_id}")`
    *   **Conceito:** Indica o ciclo de vida do processo, útil para entender a carga e o comportamento do supervisor.
*   **Recebimento de Transação:** `Logger.debug("Processing transaction ID: #{tx.id} for account ID: #{state.account_id}")`
    *   **Conceito:** Registra o início de uma operação crítica, fornecendo contexto inicial para o rastreamento.
*   **Falha na Validação:** `Logger.warning("Transaction ID: #{fresh_tx.id} validation failed: #{reason}")`
    *   **Conceito:** Captura um ponto de decisão importante e um possível ponto de falha, com a razão específica.
*   **Mudança de Status:** `Logger.info("Transaction ID: #{tx.id} status changed to :#{new_status}")`
    *   **Conceito:** Fornece visibilidade sobre o progresso e o estado final de uma transação.

#### `Bankcursor.Accounts.TransactionRouter`
Como ponto de entrada, o roteador deve logar o fluxo principal.

*   **Recebimento de Nova Transação:** `Logger.debug("Received new transaction for account ID: #{transaction.account_id}, transaction ID: #{transaction.id}")`
    *   **Conceito:** Confirma que a transação chegou ao sistema e está sendo processada inicialmente.

---

### 2. Métricas (Metrics)

Métricas são agregações numéricas de dados ao longo do tempo, usadas para quantificar o comportamento de um sistema. Diferente dos logs (narrativa), métricas são sobre números e tendências.

### Importância:
*   **Monitoramento de Performance:** Acompanhar latência, taxa de erro, throughput.
*   **Alertas:** Acionar notificações quando os limites operacionais são excedidos.
*   **Capacidade e Planejamento:** Entender o uso de recursos e planejar expansões.
*   **Visão Geral da Saúde do Sistema:** Dashboards que mostram o estado geral.

### Exemplos no Bankcursor:

#### `Bankcursor.Accounts.AccountWorker`
É a fonte mais rica para métricas de transação.

*   **Transações Concluídas (Contador):** `account_worker.transaction_completed.count`
    *   **Conceito:** Mede o sucesso das operações, com tags para tipo e conta, permitindo análise granular.
*   **Transações Falhas (Contador):** `account_worker.transaction_failed.count`
    *   **Conceito:** Mede a taxa de erro, essencial para alertas e identificação de problemas. Tags de `reason` são cruciais para entender os tipos de falha.
*   **Duração da Execução da Transação (Histograma/Tempo):** `account_worker.execute_transaction.duration`
    *   **Conceito:** Avalia a performance da lógica de negócios, identificando gargalos ou degradações.
*   **Saldo da Conta (Gauge):** `account_worker.account_balance.gauge`
    *   **Conceito:** Uma métrica de estado, mostrando o valor atual de um recurso chave (saldo), útil para monitorar anomalias financeiras.

#### `Bankcursor.Accounts.AccountSupervisor`
Métricas sobre o comportamento dos workers supervisionados.

*   **Workers Ativos (Gauge):** `account_supervisor.active_workers.gauge`
    *   **Conceito:** Indica a capacidade de processamento atual do sistema de contas.
*   **Reinícios de Workers (Contador):** `account_supervisor.worker_restarted.count`
    *   **Conceito:** Mede a estabilidade dos processos, um alto número pode indicar bugs ou recursos insuficientes.

#### `Bankcursor.Accounts.TransactionRecord`
Métricas indiretas, focando no estado dos dados.

*   **Contador de Transações por Status:** `transaction_record.status.count`
    *   **Conceito:** Fornece um panorama do volume de transações em cada fase do ciclo de vida, útil para identificar bloqueios ou atrasos.

---

### 3. Rastreamento Distribuído (Distributed Tracing)

Tracing é a prática de seguir uma única requisição ou transação conforme ela se propaga através de múltiplos serviços, processos e componentes em um sistema distribuído. Ele visualiza o "caminho" completo percorrido por uma operação.

### Importância:
*   **Análise de Latência:** Identificar onde o tempo é gasto em uma requisição complexa.
*   **Análise de Causa Raiz em Sistemas Distribuídos:** Entender a sequência de eventos que leva a uma falha em microserviços.
*   **Visualização do Fluxo de Serviço:** Mapear as interações entre diferentes componentes.

### Exemplos no Bankcursor:

#### `Bankcursor.Accounts.TransactionRouter`
Onde o trace de uma transação geralmente começa.

*   **Início do Trace:** A recepção de `{:new_transaction, transaction}` pelo `handle_info/2` no `TransactionRouter` serve como o ponto de partida para um novo trace.
*   **Identificador de Trace:** O `transaction.id` é usado como o `correlation_id` principal, ligando todos os spans relacionados a essa transação.

#### `Bankcursor.Accounts.AccountWorker`
O core da execução da transação, gerando muitos spans.

*   **Spans de Operações Chave:**
    *   `handle_cast/2`: Span principal da execução no worker.
    *   `TransactionDigester.validate`: Um span para a validação da transação.
    *   `Repo.transaction`: Um span para a operação de banco de dados, mostrando o tempo gasto com persistência.
    *   `Phoenix.PubSub.broadcast`: Um span para a publicação do evento de `transaction_completed`.
*   **Contexto e Atributos:** O `transaction.id` e `account_id` são propagados em todos os spans. Atributos como `transaction.type`, `value`, `status` e `error_reason` (em caso de falha) enriquecem cada span, permitindo filtrar e analisar o trace em detalhes.

#### `Bankcursor.Accounts.AccountSupervisor`
As ações do supervisor são links no trace.

*   **Span para `start_worker`:** Quando o `TransactionRouter` chama `AccountSupervisor.start_worker/1`, isso pode ser um span no trace, mostrando o tempo para iniciar ou localizar o worker.

#### `Bankcursor.Accounts.TransactionRecord`
Embora não gere spans diretamente, seus dados são cruciais para o tracing.

*   **Atributos de Trace:** Os campos do `TransactionRecord` (`id`, `type`, `status`, `error_reason`) são fundamentais como atributos nos spans de outros módulos, fornecendo contexto detalhado para cada etapa do trace.
```