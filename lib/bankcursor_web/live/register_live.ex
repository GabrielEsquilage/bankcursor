defmodule BankcursorWeb.RegisterLive do
  use BankcursorWeb, :live_view

  alias Bankcursor.Users
  alias Bankcursor.Users.User

  @impl true
  def mount(_params, _session, socket) do
    changeset = User.changeset(%{})
    {:ok, assign(socket, form: to_form(changeset, as: "user"), error_message: nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
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

        <.simple_form for={@form} id="register_form" phx-submit="save" phx-change="validate">
          <.error :if={@error_message}><%= @error_message %></.error>

          <.input field={@form[:name]} type="text" label="Nome Completo" required />
          <.input field={@form[:email]} type="email" label="E-mail" required />
          <.input field={@form[:cpf]} type="text" label="CPF (apenas números)" required maxlength="11" />
          <.input field={@form[:password]} type="password" label="Senha" required />

          <:actions>
            <.button phx-disable-with="Criando conta..." class="w-full">
              Criar conta <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.create(user_params) do
      {:ok, user, _account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conta criada com sucesso! Bem-vindo #{user.name}!")
         |> redirect(to: ~p"/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, :email_already_registered} ->
        {:noreply, assign(socket, error_message: "E-mail já está em uso")}
      
      _ ->
        {:noreply, assign(socket, error_message: "Erro ao criar conta")}
    end
  end
end
