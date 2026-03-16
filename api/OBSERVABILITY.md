# Documentação de Observabilidade - Sistema Bankcursor (Módulos de Conta e Transação)

Esta documentação descreve os pontos de observabilidade (Logging, Métricas e Rastreamento) para os módulos centrais do sistema de contas e transações do Bankcursor. O objetivo é fornecer visibilidade sobre o comportamento do sistema, identificar gargalos, diagnosticar falhas e monitorar a saúde operacional.

---

## Módulo: Bankcursor.Accounts.TransactionRouter

### Propósito
O `TransactionRouter` é um `GenServer` responsável por orquestrar o recebimento e o roteamento de novas transações para os respectivos `AccountWorker`s. Ele se inscreve em eventos de transação publicados no `Phoenix.PubSub` e garante que cada transação seja processada pelo `AccountWorker` correto, iniciando um novo supervisor/worker se necessário. É o ponto de entrada para as transações no sistema de processamento assíncrono.

### Pontos de Observabilidade

#### Logging
*   **Início do Router:** Registrar quando o `TransactionRouter` inicia (`init/1`).
    *   **Sugestão de Log:** `Logger.info("TransactionRouter started.")`
*   **Recebimento de Nova Transação:** Logar quando uma nova mensagem de transação é recebida do `PubSub`, incluindo detalhes como ID da transação e ID da conta.
    *   **Sugestão de Log:** `Logger.debug("Received new transaction for account ID: #{transaction.account_id}, transaction ID: #{transaction.id}")`
*   **Falhas no Roteamento:** Logar quaisquer problemas inesperados que possam surgir ao tentar iniciar um worker ou rotear a transação.

#### Métricas
*   **Transações Recebidas (Contador):**
    *   **Métrica:** `transaction_router.transaction_received.count`
    *   **Descrição:** Número total de mensagens de transação recebidas pelo router.
    *   **Tags:** `type: transaction.type`, `account_id: transaction.account_id` (para granularidade, se não for excessivo).
*   **Tempo de Processamento do Roteador (Histograma/Tempo):**
    *   **Métrica:** `transaction_router.handle_info.duration`
    *   **Descrição:** Duração total da execução da função `handle_info`, que inclui o início do worker e o envio da transação para o `AccountWorker`. Pode indicar gargalos no roteamento.

#### Rastreamento (Tracing)
*   **Início do Trace:** A recepção de `{:new_transaction, transaction}` deve iniciar um novo trace.
*   **Identificador do Trace:** O `transaction.id` é um candidato ideal para o ID do trace (ou `correlation_id`).
*   **Spans:**
    *   Um span principal para `handle_info`.
    *   Spans para chamadas subsequentes: `AccountSupervisor.start_worker` e `AccountWorker.process`.
    *   Esses spans devem ser interligados com o ID do trace da transação para permitir a visualização completa do ciclo de vida da transação através de múltiplos processos.

---

## Módulo: Bankcursor.Accounts.AccountSupervisor

### Propósito
O `AccountSupervisor` é um `DynamicSupervisor` responsável por supervisionar dinamicamente instâncias de `Bankcursor.Accounts.AccountWorker`. Cada `AccountWorker` gerencia transações para uma conta específica. O supervisor garante a resiliência do sistema, reiniciando workers em caso de falha. Ele utiliza um `Registry` para associar `account_id`s aos seus respectivos `AccountWorker`s, permitindo que as transações sejam direcionadas para o processo correto.

### Pontos de Observabilidade

#### Logging
*   **Início do Supervisor:** Registrar quando o `AccountSupervisor` inicia.
    *   **Sugestão de Log:** `Logger.info("AccountSupervisor started.")`
*   **Início de Worker:** Logar quando um novo `AccountWorker` é iniciado dinamicamente para um `account_id`.
    *   **Sugestão de Log (dentro de `start_worker/1`):** `Logger.debug("Starting new AccountWorker for account ID: #{account_id}")`
*   **Reinício/Encerramento de Worker:** O próprio `DynamicSupervisor` logará automaticamente eventos importantes como reinícios de workers devido a falhas, shutdowns e start-ups. Monitore os logs do sistema para mensagens como `[info] Application Bankcursor exited: :stopped` ou logs de crash de `GenServer`s supervisionados.

#### Métricas
*   **Workers Iniciados (Contador):**
    *   **Métrica:** `account_supervisor.worker_started.count`
    *   **Descrição:** Número total de `AccountWorker`s iniciados pelo supervisor.
*   **Workers Ativos (Gauge):**
    *   **Métrica:** `account_supervisor.active_workers.gauge`
    *   **Descrição:** Número atual de `AccountWorker`s rodando sob este supervisor. Uma queda brusca pode indicar um problema em cascata.
*   **Reinícios de Workers (Contador):**
    *   **Métrica:** `account_supervisor.worker_restarted.count`
    *   **Descrição:** Número de vezes que um `AccountWorker` foi reiniciado devido a falhas. Um número alto indica instabilidade nos workers.
    *   **Tags:** `account_id` (para identificar contas problemáticas).
*   **Falhas de Workers (Contador):**
    *   **Métrica:** `account_supervisor.worker_crashed.count`
    *   **Descrição:** Número de vezes que um `AccountWorker` falhou e foi encerrado ou reiniciado.

#### Rastreamento (Tracing)
*   **Span para `start_worker`:** A chamada para `AccountSupervisor.start_worker/1` a partir do `TransactionRouter` deve ser um span dentro do trace da transação.
*   **Associação de Contexto:** O `account_id` é o elo principal entre o supervisor e a transação sendo processada. Certifique-se de que o contexto do trace (ID da transação, `account_id`) seja propagado ao iniciar o worker.
*   **Eventos de Ciclo de Vida:** Eventos como "worker started" podem ser emitidos como eventos dentro do trace, enriquecendo a visualização do ciclo de vida de uma transação.

---

## Módulo: Bankcursor.Accounts.AccountWorker

### Propósito
O `AccountWorker` é um processo `GenServer` que atua como o principal executor das operações financeiras para uma conta específica. Ele recebe solicitações de transação (depósito, saque, transferência), valida-as, executa as operações necessárias no banco de dados (atualizando saldos e status da transação) e lida com cenários de falha. Ele é supervisionado dinamicamente pelo `AccountSupervisor` e registrado via `Registry`.

### Pontos de Observabilidade

#### Logging
*   **Início do Worker:** Logar quando um `AccountWorker` é inicializado para um `account_id` específico.
    *   **Sugestão de Log (em `init/1`):** `Logger.info("AccountWorker started for account ID: #{account_id}")`
*   **Recebimento de Transação:** Registrar o recebimento de uma transação para processamento.
    *   **Sugestão de Log (em `handle_cast/2`):** `Logger.debug("Processing transaction ID: #{tx.id} for account ID: #{state.account_id}")`
*   **Status Inicial da Transação:** Logar se a transação não estiver mais `pending` ou pertencer a outra conta.
    *   **Sugestão de Log (antes do `if` inicial):** `Logger.warning("Transaction ID: #{tx.id} not in pending state or account mismatch.")`
*   **Resultado da Validação:** Logar o sucesso ou falha da validação da transação (`TransactionDigester.validate`).
    *   **Sugestão de Log (pós `TransactionDigester.validate`):**
        *   `Logger.debug("Transaction ID: #{fresh_tx.id} validation successful.")`
        *   `Logger.warning("Transaction ID: #{fresh_tx.id} validation failed: #{reason}")`
*   **Mudança de Status da Transação:** Logar cada transição de status da transação (pending -> processing, processing -> completed, processing -> failed).
    *   **Sugestão de Log (após `Repo.update()`):** `Logger.info("Transaction ID: #{tx.id} status changed to :#{new_status}")`
*   **Execução da Transação (Detalhes):** Logar os parâmetros da transação sendo executada (`execute_transaction/1`).
    *   **Sugestão de Log:** `Logger.debug("Executing #{tx.type} transaction ID: #{tx.id} with value: #{tx.value} for account ID: #{tx.account_id}")`
*   **Falhas Específicas da Transação:**
    *   `insufficient_funds`: Logar quando houver fundos insuficientes para saque ou transferência.
        *   **Sugestão de Log:** `Logger.warning("Insufficient funds for transaction ID: #{tx.id}. Account ID: #{account.id}, Balance: #{account.balance}, Value: #{value}")`
    *   `db_error`: Logar erros durante a transação de banco de dados.
        *   **Sugestão de Log:** `Logger.error("Database transaction failed for transaction ID: #{tx.id}. Error: #{inspect(error_details)}")`
    *   `invalid_digest`, `validation_error`, `generic_error`: Logar estas falhas específicas.
*   **Sucesso da Transação:** Logar quando uma transação é completada com sucesso.
    *   **Sugestão de Log (em `handle_db_transaction/2` com sucesso):** `Logger.info("Transaction ID: #{completed_tx.id} completed successfully. Account ID: #{completed_tx.account_id}, Type: #{completed_tx.type}, Value: #{completed_tx.value}")`
*   **Broadcast de Evento:** Logar quando um evento de transação completa é transmitido via `PubSub`.
    *   **Sugestão de Log:** `Logger.debug("Broadcasting transaction_completed for transaction ID: #{completed_tx.id}")`

#### Métricas
*   **Transações Processadas (Contador):**
    *   **Métrica:** `account_worker.transaction_processed.count`
    *   **Descrição:** Número total de transações que o worker tentou processar.
    *   **Tags:** `type: tx.type`, `account_id: tx.account_id` (para análise granular).
*   **Transações Concluídas (Contador):**
    *   **Métrica:** `account_worker.transaction_completed.count`
    *   **Descrição:** Número de transações que foram concluídas com sucesso.
    *   **Tags:** `type: tx.type`, `account_id: tx.account_id`.
*   **Transações Falhas (Contador):**
    *   **Métrica:** `account_worker.transaction_failed.count`
    *   **Descrição:** Número de transações que falharam.
    *   **Tags:** `type: tx.type`, `reason: failure_reason`, `account_id: tx.account_id`.
*   **Duração da Execução da Transação (Histograma/Tempo):**
    *   **Métrica:** `account_worker.execute_transaction.duration`
    *   **Descrição:** Tempo que leva para executar uma transação completa (desde a validação até o commit no DB).
    *   **Tags:** `type: tx.type`, `status: :completed | :failed`.
*   **Saldo da Conta (Gauge):**
    *   **Métrica:** `account_worker.account_balance.gauge`
    *   **Descrição:** O saldo atual da conta. Emitido após cada transação bem-sucedida. Permite monitorar o saldo das contas em tempo real.
    *   **Tags:** `account_id: account.id`.
*   **Eventos de Scoring Broadcastados (Contador):**
    *   **Métrica:** `account_worker.scoring_event_broadcasted.count`
    *   **Descrição:** Número de eventos `transaction_completed` enviados para o `PubSub` para o sistema de scoring.

#### Rastreamento (Tracing)
*   **Span Principal (`handle_cast`):** O `handle_cast/2` que recebe a transação deve ser o span principal para a execução da transação no worker. Este span deve ser filho do span do `TransactionRouter`.
*   **Spans de Operações Chave:**
    *   `TransactionDigester.validate`: Span para a validação.
    *   `Repo.update` (status para processing): Span para a atualização inicial de status.
    *   `execute_transaction`: Span para a lógica de execução da transação (depósito, saque, transferência).
    *   `Repo.transaction`: Span para a transação de banco de dados propriamente dita.
    *   `mark_as_failed`: Span para marcar a transação como falha.
    *   `Phoenix.PubSub.broadcast`: Span para o broadcast do evento de scoring.
*   **Contexto:** O `transaction.id` deve ser propagado como o ID do trace (ou `correlation_id`) através de todos esses spans, permitindo a visualização completa de cada passo. O `account_id` também é um atributo importante para o trace.
*   **Atributos do Span:** Adicionar atributos relevantes aos spans, como `transaction.type`, `transaction.value`, `transaction.status`, `error_reason` (em caso de falha), `account.balance` (após a atualização).

---

## Módulo: Bankcursor.Accounts.TransactionRecord

### Propósito
O `TransactionRecord` é um módulo `Ecto.Schema` que define a estrutura de dados para as transações no sistema. Ele mapeia a tabela `transactions` no banco de dados, especificando campos como tipo de transação (`:deposit`, `:withdraw`, `:transfer`), valor, status (`:pending`, `:processing`, `:completed`, `:failed`), um digest de validação (`validation_digest`) e uma razão de erro (`error_reason`). Ele também fornece um `changeset` para validação e manipulação dos dados da transação.

### Pontos de Observabilidade

O `TransactionRecord` é primariamente um esquema de dados e não executa lógica de negócios complexa por si só. A observabilidade para este módulo se concentra em como seus dados são manipulados e refletidos por outros módulos (como `AccountWorker`) e no estado persistido no banco de dados.

#### Logging
O `TransactionRecord` não deve conter chamadas de `Logger` diretamente, pois ele representa a definição de dados. O logging relacionado às transações deve ser realizado pelos módulos que interagem com o esquema (ex: `AccountWorker` ao criar, atualizar ou ler registros de transação).

*   **Criação/Atualização de Registros:** Os logs devem ser emitidos pelos módulos que persistem ou modificam os `TransactionRecord`s.
    *   **Exemplo (no `AccountWorker` ou serviço de criação):**
        *   `Logger.info("Creating new transaction record ID: #{tx.id} for account ID: #{tx.account_id}")`
        *   `Logger.debug("Updating transaction record ID: #{tx.id}, status to: #{new_status}")`
*   **Erros de Esquema:** Logs sobre erros de validação de `changeset` devem ser capturados onde o `changeset` é aplicado.
    *   **Exemplo (no módulo que usa o changeset):** `Logger.warning("Changeset invalid for transaction: #{inspect(changeset.errors)}")`

#### Métricas
As métricas relacionadas a `TransactionRecord`s fornecem insights sobre o volume, o estado e a saúde geral das transações no sistema.

*   **Contador de Transações por Status:**
    *   **Métrica:** `transaction_record.status.count`
    *   **Descrição:** Número total de transações em cada status (`:pending`, `:processing`, `:completed`, `:failed`).
    *   **Tags:** `status: :pending | :processing | :completed | :failed`, `type: :deposit | :withdraw | :transfer`.
    *   **Como Obter:** Esta métrica pode ser obtida por:
        1.  Agregando eventos de atualização de status emitidos pelo `AccountWorker`.
        2.  Consultando o banco de dados periodicamente (e.g., `Repo.aggregate(TransactionRecord, :count, :id, group_by: [:status, :type])`).
*   **Contador de Transações por Razão de Erro:**
    *   **Métrica:** `transaction_record.error_reason.count`
    *   **Descrição:** Número de transações que falharam, categorizadas pela `error_reason`.
    *   **Tags:** `error_reason: :invalid_digest | :insufficient_funds | :db_error | ...`.
    *   **Como Obter:** Agregando eventos de transação falha com a razão, ou consultando o DB.
*   **Tempo Médio para Completar Transação (Histograma/Timing):**
    *   **Métrica:** `transaction_record.time_to_complete.duration`
    *   **Descrição:** Duração desde a criação da transação até que seu status mude para `:completed` ou `:failed`.
    *   **Como Obter:** Cálculo da diferença entre `inserted_at` e `updated_at` (quando o status final é alcançado), ou via eventos instrumentados.

#### Rastreamento (Tracing)
Os dados do `TransactionRecord` são fundamentais para o rastreamento, pois o `transaction.id` serve como o identificador principal para correlacionar todos os eventos e operações relacionados a uma única transação.

*   **Atributos de Trace:** Os campos do `TransactionRecord` (especialmente `id`, `type`, `value`, `account_id`, `recipient_account_id`, `status`, `error_reason`) devem ser incluídos como atributos em todos os spans relevantes no trace de uma transação.
*   **Contexto da Validação:** O `validation_digest` e `error_reason` são particularmente importantes para entender o caminho que uma transação tomou e por que ela pode ter falhado.
