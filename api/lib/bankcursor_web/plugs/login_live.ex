defmodule BankcursorWeb.LoginLive do
  use BankcursorWeb, :live_view

  alias Bankcursor.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Entrar na sua conta
      </.header>

      <.simple_form for={@form} id="login_form" phx-submit="login">
        <.input
          field={@form[:identifier]}
          type="text"
          label="E-mail, CPF ou Número da Conta"
          required
        />

        <.input
          field={@form[:password]}
          type="password"
          label="Senha"
          required
        />

        <:actions>
          <.button phx-disable-with="Entrando..." class="w-full">
            Entrar →
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("login", %{"user" => user_params}, socket) do
    case Users.login(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bem-vindo de volta, #{user.name}!")
         |> redirect(to: ~p"/")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Credenciais inválidas")
         |> assign(form: to_form(%{"identifier" => user_params["identifier"]}, as: "user"))}
    end
  end
end
