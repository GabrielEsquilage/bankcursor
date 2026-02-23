defmodule BankcursorWeb.LoginLive do
  use BankcursorWeb, :live_view

  alias Bankcursor.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"identifier" => "", "password" => ""}), error_message: nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
        <.header class="text-center">
          Entrar na sua conta
          <:subtitle>
            Não tem uma conta?
            <.link navigate={~p"/"} class="font-semibold text-brand hover:underline">
              Cadastre-se
            </.link>
            agora.
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="login_form" phx-submit="login" phx-change="validate">
          <.error :if={@error_message}><%= @error_message %></.error>

          <.input field={@form[:identifier]} type="text" label="E-mail, CPF ou Número da Conta" required />
          <.input field={@form[:password]} type="password" label="Senha" required />

          <:actions>
            <.button phx-disable-with="Entrando..." class="w-full">
              Entrar <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end

  @impl true
  def handle_event("validate", %{"identifier" => identifier, "password" => password}, socket) do
    {:noreply, assign(socket, form: to_form(%{"identifier" => identifier, "password" => password}))}
  end

  @impl true
  def handle_event("login", %{"identifier" => identifier, "password" => password}, socket) do
    case Users.login(%{"identifier" => identifier, "password" => password}) do
      {:ok, user} ->
        if user.role == "client" do
          {:noreply,
           socket
           |> put_flash(:info, "Bem-vindo de volta, #{user.name}!")
           |> redirect(to: ~p"/")}
        else
          {:noreply, assign(socket, error_message: "Acesso restrito. Utilize o portal administrativo.", form: to_form(%{"identifier" => identifier, "password" => ""}))}
        end

      {:error, _reason} ->
        {:noreply, assign(socket, error_message: "Credenciais inválidas", form: to_form(%{"identifier" => identifier, "password" => ""}))}
    end
  end
end
