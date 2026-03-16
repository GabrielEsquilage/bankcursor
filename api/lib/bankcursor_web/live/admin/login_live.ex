defmodule BankcursorWeb.Admin.LoginLive do
  use BankcursorWeb, {:live_view, layout: {BankcursorWeb.Layouts, :admin}}

  alias Bankcursor.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, email: "", password: "", error_message: nil)}
  end

  @impl true
  def handle_event("login", %{"email" => email, "password" => password}, socket) do
    case Bankcursor.Staff.Verify.call(%{"identifier" => email, "password" => password}) do
      {:ok, user} ->
        if user.role in ["admin", "collaborator"] do
          {:noreply, redirect(socket, to: ~p"/admin/session/create?token=#{BankcursorWeb.Token.sign(user)}")}
        else
          {:noreply, assign(socket, error_message: "Acesso negado. Utilize o portal de clientes.")}
        end

      {:error, _} ->
        {:noreply, assign(socket, error_message: "E-mail ou senha inválidos.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center min-h-[80vh]">
      <div class="w-full max-w-sm">
        <.header class="text-center mb-10">
          Acesso Administrativo
          <:subtitle>Identifique-se para gerenciar a plataforma Bankcursor</:subtitle>
        </.header>

        <div class="bg-zinc-900/50 border border-zinc-800 p-8 rounded-3xl backdrop-blur-md shadow-2xl">
          <form phx-submit="login" class="space-y-6">
            <.input 
              name="email" 
              type="email" 
              label="E-mail" 
              value={@email} 
              required 
              placeholder="admin@bankcursor.com"
            />
            
            <.input 
              name="password" 
              type="password" 
              label="Senha" 
              required 
            />

            <%= if @error_message do %>
              <p class="text-red-500 text-xs font-semibold text-center mt-2 animate-pulse">
                <%= @error_message %>
              </p>
            <% end %>

            <.button class="w-full mt-6 py-4 text-sm uppercase tracking-widest">
              Acessar Painel <.icon name="hero-arrow-right-solid" class="ml-2 h-4 w-4" />
            </.button>
          </form>
        </div>
        
        <p class="mt-8 text-center text-zinc-600 text-[10px] uppercase font-bold tracking-widest">
          Sessão Protegida por Criptografia Bankcursor
        </p>
      </div>
    </div>
    """
  end
end
