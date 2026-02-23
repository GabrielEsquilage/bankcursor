defmodule BankcursorWeb.HomeLive do
  use BankcursorWeb, :live_view

  alias Bankcursor.Users
  alias Bankcursor.Users.User
  alias Bankcursor.ViaCep.Client

  @impl true
  def mount(_params, _session, socket) do
    changeset = User.changeset_for_registration(%{addresses: [%{}]})

    socket =
      assign(socket,
        form: to_form(changeset, as: "user"),
        error_message: nil,
        show_modal: false
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative isolate overflow-hidden bg-zinc-950 min-h-[80vh] flex flex-col">
      <div :if={@show_modal}>
        <.modal id="register-modal" show={@show_modal} on_cancel={JS.push("hide_modal")}>
          <div class="mx-auto">
            <.header class="text-center">
              Crie sua conta no Bankcursor
              <:subtitle>
                Já tem uma conta?
                <.link navigate={~p"/login"} class="font-semibold text-brand hover:underline">
                  Entrar
                </.link>
                na sua conta agora.
              </:subtitle>
            </.header>

            <.simple_form
              for={@form}
              id="register_form"
              phx-submit="save"
            >
              <.error :if={@error_message}><%= @error_message %></.error>

              <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <.input field={@form[:name]} type="text" label="Nome Completo" required />
                <.input field={@form[:email]} type="email" label="E-mail" required />
                <.input field={@form[:cpf]} type="text" label="CPF (apenas números)" required maxlength="11" />
                <.input field={@form[:password]} type="password" label="Senha" required />
              </div>

              <h2 class="text-lg font-semibold text-white mt-6">Endereço</h2>

              <.inputs_for :let={address_form} field={@form[:addresses]}>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <.input
                    field={address_form[:zip_code]}
                    type="text"
                    label="CEP"
                    required
                    maxlength="8"
                    phx-change="validate_cep"
                    phx-debounce="500"
                  />
                  <.input field={address_form[:street]} type="text" label="Rua" required />
                  <.input field={address_form[:number]} type="text" label="Número" />
                </div>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
                  <.input field={address_form[:complement]} type="text" label="Complemento" />
                  <.input field={address_form[:neighborhood]} type="text" label="Bairro" required />
                  <.input field={address_form[:city]} type="text" label="Cidade" required />
                </div>
                <.input field={address_form[:state]} type="text" label="Estado" required class="mt-4" />
              </.inputs_for>

              <:actions>
                <div class="flex justify-end gap-4 w-full mt-6">
                  <.button phx-click={JS.push("hide_modal")} type="button" class="rounded-full bg-zinc-700 border border-zinc-600 px-16 py-4 text-sm font-bold text-white hover:bg-zinc-800 transition-all duration-300 transform hover:scale-105">
                    Voltar
                  </.button>
                  <.button phx-disable-with="Criando conta..." class="rounded-full bg-black border border-red-800 px-16 py-4 text-sm font-bold text-white hover:bg-zinc-800 transition-all duration-300 transform hover:scale-105">
                    Criar conta <span aria-hidden="true">→</span>
                  </.button>
                </div>
              </:actions>
            </.simple_form>
          </div>
        </.modal>
      </div>

      <!-- Background effects -->
      <div class="absolute inset-x-0 -top-40 -z-10 transform-gpu blur-3xl sm:-top-80" aria-hidden="true">
        <div class="relative left-[calc(50%-40rem)] aspect-[1155/678] w-[80rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-[#ff4d4d] to-[#b91c1c] opacity-5 sm:left-[calc(50%-75rem)] sm:w-[150rem]" style="clip-path: polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)"></div>
      </div>

      <div class="m-auto max-w-4xl px-6 lg:px-8">
        <div class="text-center">
          <h1 class="text-4xl font-extrabold tracking-tight text-white sm:text-6xl bg-clip-text text-transparent bg-gradient-to-r from-white to-zinc-400">
            A nova era da sua vida financeira
          </h1>
          <p class="mt-6 text-lg leading-8 text-zinc-400 max-w-2xl mx-auto">
            Bankcursor: simplicidade, segurança e controle total na palma da sua mão. 
            O banco feito para acompanhar o seu ritmo.
          </p>
          <div class="mt-10 flex items-center justify-center">
            <.button phx-click="show_modal" class="rounded-full bg-black border border-red-800 px-12 py-4 text-sm font-bold text-white hover:bg-zinc-800 transition-all duration-300 transform hover:scale-105">
              Criar Conta Gratuita <span aria-hidden="true">→</span>
            </.button>
          </div>
        </div>
      </div>

      <!-- Features quick-look -->
      <div class="mt-auto grid grid-cols-1 gap-8 sm:grid-cols-3 mx-auto max-w-4xl px-6 lg:px-8 pb-8">
        <div class="rounded-2xl border border-white/2 bg-white/2 p-6 backdrop-blur-sm">
          <div class="text-red-500 mb-2 font-bold text-xl">100% Digital</div>
          <p class="text-sm text-zinc-500">Abra sua conta em minutos e comece a usar na hora.</p>
        </div>
        <div class="rounded-2xl border border-white/2 bg-white/2 p-6 backdrop-blur-sm">
          <div class="text-red-500 mb-2 font-bold text-xl">Taxa Zero</div>
          <p class="text-sm text-zinc-500">Sem mensalidades ou taxas escondidas para você.</p>
        </div>
        <div class="rounded-2xl border border-white/2 bg-white/2 p-6 backdrop-blur-sm">
          <div class="text-red-500 mb-2 font-bold text-xl">Segurança</div>
          <p class="text-sm text-zinc-500">Tecnologia de ponta para proteger seu patrimônio.</p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> User.changeset_for_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "user"))}
  end

  def handle_event("validate_cep", %{"user" => user_params}, socket) do
    cep = get_in(user_params, ["addresses", "0", "zip_code"])

    case Client.call(cep) do
      {:ok, address} ->
        IO.inspect(address, label: "ViaCEP Address Data")
        IO.inspect(user_params, label: "HomeLive before User.changeset_for_registration (ok)")
        changeset = User.changeset_for_registration(%User{}, user_params)
        IO.inspect(changeset, label: "HomeLive after User.changeset_for_registration (ok)")

        {:noreply, assign(socket, form: to_form(changeset, as: "user"))}

      _ ->
        IO.inspect(user_params, label: "HomeLive before User.changeset_for_registration (error)")
        changeset_with_current_data = User.changeset_for_registration(%User{}, user_params)
        IO.inspect(changeset_with_current_data, label: "HomeLive after User.changeset_for_registration (error)")

        {:noreply,
         socket
         |> put_flash(:error, "CEP não encontrado")
         |> assign(form: to_form(changeset_with_current_data, as: "user"))}
    end
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.create(user_params) do
      {:ok, user, _account} ->
        {:noreply,
         socket
         |> assign(show_modal: false)
         |> put_flash(:info, "Conta criada com sucesso! Bem-vindo #{user.name}!")
         |> redirect(to: ~p"/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "user"))}

      {:error, :email_already_registered} ->
        {:noreply, assign(socket, error_message: "E-mail já está em uso")}

      _ ->
        {:noreply, assign(socket, error_message: "Erro ao criar conta")}
    end
  end

  def handle_event("show_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end
end
