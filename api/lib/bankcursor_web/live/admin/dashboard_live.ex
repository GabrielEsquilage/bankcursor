defmodule BankcursorWeb.Admin.DashboardLive do
  use BankcursorWeb, {:live_view, layout: {BankcursorWeb.Layouts, :admin}}

  alias Bankcursor.Users
  alias Bankcursor.Scoring

  alias Bankcursor.Repo
  alias Bankcursor.Staff.StaffMember

  def mount(_params, %{"user_id" => user_id}, socket) do
    case Repo.get(StaffMember, user_id) do
      nil ->
        {:ok, redirect(socket, to: "/admin/login")}
      user ->
        {:ok, assign(socket, 
          current_user: user,
          search_cpf: "", 
          selected_user: nil, 
          score: 0,
          loading: false,
          error_message: nil
        )}
    end
  end

  def handle_event("search_user", %{"cpf" => cpf}, socket) do
    case Users.get_by_cpf(cpf) do
      nil ->
        {:noreply, assign(socket, selected_user: nil, error_message: "Usuário não encontrado.")}
      
      user ->
        {:ok, user} = Users.get_with_associations(user.id)
        score = Scoring.get_user_score(user)
        {:noreply, assign(socket, selected_user: user, score: score, error_message: nil)}
    end
  end

  defp mask_cpf(cpf, "admin"), do: cpf
  defp mask_cpf(cpf, _) do
    String.slice(cpf, 0, 3) <> ".***.***-" <> String.slice(cpf, -2, 2)
  end

  defp mask_balance(balance, "admin"), do: "R$ #{balance}"
  defp mask_balance(_balance, _), do: "R$ ••••••"

  defp mask_address(address, "admin"), do: address
  defp mask_address(_address, _), do: "Acesso restrito (Privacidade)"

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-zinc-950 text-white">
      <.header class="border-b border-zinc-800 pb-6 mb-8">
        Painel Administrativo
        <:subtitle>Identidade: <%= @current_user.role %></:subtitle>
        <:actions>
          <div class="flex items-center gap-6">
            <%= if @current_user.role == "admin" do %>
              <.link navigate={~p"/admin/staff"} class="text-xs font-bold text-zinc-400 hover:text-white transition-all">
                Gestão de Equipe
              </.link>
            <% end %>
            <.link 
              href={~p"/admin/logout"} 
              method="delete" 
              class="text-xs font-bold text-red-500 hover:text-red-400 transition-all"
            >
              Sair
            </.link>
          </div>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-1">
          <div class="bg-zinc-900/50 border border-zinc-800 p-6 rounded-2xl backdrop-blur-sm">
            <h3 class="text-sm font-bold text-zinc-400 uppercase tracking-wider mb-6">Localizar Cliente</h3>
            <form phx-submit="search_user" class="space-y-4">
              <.input name="cpf" value={@search_cpf} label="CPF" placeholder="000.000.000-00" />
              <%= if @error_message do %>
                <p class="text-red-500 text-xs mt-1 font-medium"><%= @error_message %></p>
              <% end %>
              <.button class="w-full mt-4 py-3 text-base">
                Consultar Base <.icon name="hero-magnifying-glass" class="ml-2 h-4 w-4" />
              </.button>
            </form>
          </div>
        </div>

        <div class="lg:col-span-2 space-y-8">
          <%= if @selected_user do %>
            <div class="animate-in fade-in slide-in-from-bottom-4 duration-500 grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="bg-zinc-900/50 border border-zinc-800 p-6 rounded-2xl">
                <h3 class="text-sm font-bold text-zinc-400 uppercase tracking-wider mb-4 border-b border-zinc-800 pb-2">Informações</h3>
                <.list>
                  <:item title="Nome"><span class="text-white font-medium"><%= @selected_user.name %></span></:item>
                  <:item title="E-mail"><%= @selected_user.email %></:item>
                  <:item title="CPF"><%= mask_cpf(@selected_user.cpf, @current_user.role) %></:item>
                </.list>
              </div>

              <div class="bg-zinc-900/50 border border-zinc-800 p-6 rounded-2xl text-center flex flex-col items-center justify-center">
                <h3 class="text-sm font-bold text-zinc-400 uppercase tracking-wider mb-4">Score de Crédito</h3>
                <div class="text-7xl font-black text-white"><%= @score %></div>
              </div>

              <div class="md:col-span-2 bg-gradient-to-br from-zinc-900 to-black border border-zinc-800 p-8 rounded-3xl">
                <h3 class="text-zinc-500 text-xs font-bold uppercase mb-8 tracking-widest">Conta Digital</h3>
                <%= if @selected_user.account do %>
                  <div class="flex justify-between items-end">
                    <div>
                      <div class="text-zinc-500 text-[10px] mb-1 font-mono uppercase">Account ID</div>
                      <div class="text-3xl font-mono text-white tracking-tighter"><%= @selected_user.account.account_number %></div>
                    </div>
                    <div class="text-right">
                      <div class="text-zinc-500 text-[10px] mb-1 uppercase font-bold">Saldo Disponível</div>
                      <div class="text-5xl font-black text-white"><%= mask_balance(@selected_user.account.balance, @current_user.role) %></div>
                    </div>
                  </div>
                <% else %>
                  <div class="text-zinc-500 italic py-4">Este cliente não possui conta ativa.</div>
                <% end %>
              </div>

              <div class="md:col-span-2 bg-zinc-900/30 border border-zinc-800 p-6 rounded-2xl">
                <h3 class="text-sm font-bold text-zinc-400 uppercase mb-6">Endereços Vinculados</h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <%= for address <- @selected_user.addresses do %>
                    <div class="bg-zinc-950 p-4 rounded-xl border border-zinc-800">
                      <p class="text-sm text-zinc-200 font-medium"><%= mask_address("#{address.street}, #{address.neighborhood}", @current_user.role) %></p>
                      <p class="text-xs text-zinc-500"><%= address.city %> - <%= address.state %> | CEP: <%= address.zip_code %></p>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          <% else %>
            <div class="h-full flex flex-col items-center justify-center py-20 border-2 border-dashed border-zinc-900 rounded-3xl bg-zinc-900/10">
               <.icon name="hero-user-group" class="h-16 w-16 text-zinc-800 mb-6" />
               <p class="text-zinc-500 font-medium text-center max-w-xs text-lg">
                 Selecione um cliente para visualizar os dados detalhados.
               </p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
