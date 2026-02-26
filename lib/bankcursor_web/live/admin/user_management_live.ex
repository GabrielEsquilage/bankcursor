defmodule BankcursorWeb.Admin.UserManagementLive do
  use BankcursorWeb, {:live_view, layout: {BankcursorWeb.Layouts, :admin}}

  alias Bankcursor.Repo
  alias Bankcursor.Staff.StaffMember
  alias Bankcursor.Staff.Update

  def mount(_params, %{"user_id" => user_id}, socket) do
    user = Repo.get(StaffMember, user_id)
    
    if user.role != "admin" do
      {:ok, redirect(socket, to: "/admin")}
    else
      {:ok, assign(socket, 
        current_user: user,
        staff_users: list_staff_users(),
        form: to_form(%{"name" => "", "email" => "", "password" => "", "role" => "collaborator"}),
        error_message: nil,
        selected_user: nil
      )}
    end
  end

  def handle_event("save", %{"name" => _, "email" => _, "password" => _, "role" => _} = params, socket) do
    %StaffMember{}
    |> StaffMember.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, _staff} ->
        {:noreply, assign(socket, 
          staff_users: list_staff_users(), 
          form: to_form(%{"name" => "", "email" => "", "password" => "", "role" => "collaborator"}),
          error_message: nil
        )}
      {:error, _changeset} ->
        {:noreply, assign(socket, error_message: "Erro no cadastro. Verifique os dados.")}
    end
  end

  def handle_event("show_user", %{"id" => id}, socket) do
    user = Enum.find(socket.assigns.staff_users, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_user: user)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, selected_user: nil)}
  end

  def handle_event("reset_password", %{"id" => id}, socket) do
    user = Enum.find(socket.assigns.staff_users, &(&1.id == String.to_integer(id)))

    case Update.reset_password(user) do
      {:ok, {_user, _new_password}} ->
        {:noreply,
          socket
          |> put_flash(:info, "Senha redefinida com sucesso!")
          |> assign(selected_user: nil)}
      {:error, _changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, "Erro ao redefinir a senha.")
          |> assign(selected_user: nil)}
    end
  end

  defp list_staff_users do
    import Ecto.Query
    from(u in StaffMember, order_by: [desc: u.inserted_at])
    |> Repo.all()
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-zinc-950 text-white">
      <.header class="border-b border-zinc-800 pb-6 mb-8">
        Gestão de Equipe
        <:subtitle>Gerenciamento de acesso interno</:subtitle>
        <:actions>
          <.link navigate={~p"/admin"} class="text-xs font-bold text-zinc-400 hover:text-white transition-all">
            Voltar ao Painel
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-1">
          <div class="bg-zinc-900/50 border border-zinc-800 p-8 rounded-2xl backdrop-blur-sm">
            <h3 class="text-sm font-bold text-zinc-400 uppercase tracking-widest mb-6 border-b border-zinc-800 pb-2">Novo Membro</h3>
            <form phx-submit="save" class="space-y-6">
              <.input name="name" value={@form[:name].value} label="Nome Completo" required />
              <.input name="email" type="email" value={@form[:email].value} label="E-mail Corporativo" required />
              <.input name="password" type="password" value={@form[:password].value} label="Senha Provisória" required />
              <.input 
                name="role" 
                type="select" 
                label="Cargo / Permissão" 
                options={[{"Colaborador", "collaborator"}, {"Administrador", "admin"}]} 
                value={@form[:role].value} 
              />
              <%= if @error_message do %>
                <p class="text-red-500 text-xs mt-1 font-semibold text-center"><%= @error_message %></p>
              <% end %>
              <.button class="w-full mt-6 py-4 text-sm font-black uppercase tracking-widest">
                Cadastrar Membro
              </.button>
            </form>
          </div>
        </div>

        <div class="lg:col-span-2">
          <div class="bg-zinc-900/50 border border-zinc-800 p-8 rounded-3xl">
            <h3 class="text-sm font-bold text-zinc-400 uppercase tracking-widest mb-6 flex items-center gap-2">
              <.icon name="hero-shield-check" class="h-5 w-5" /> Equipe Ativa
            </h3>
            <div class="overflow-x-auto">
              <table class="w-full text-left text-sm">
                <thead>
                  <tr class="text-zinc-500 border-b border-zinc-800">
                    <th class="py-4 px-4 font-bold uppercase text-[10px] tracking-widest">Matrícula</th>
                    <th class="py-4 px-4 font-bold uppercase text-[10px] tracking-widest">Nome</th>
                    <th class="py-4 px-4 font-bold uppercase text-[10px] tracking-widest">Nível de Acesso</th>
                    <th class="py-4 px-4 font-bold uppercase text-[10px] tracking-widest text-right">E-mail</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-zinc-800/30">
                  <%= for user <- @staff_users do %>
                    <tr phx-click="show_user" phx-value-id={user.id} class="hover:bg-zinc-900/30 transition-colors group cursor-pointer">
                      <td class="py-5 px-4 font-mono text-zinc-400 text-xs"><%= user.staff_number %></td>
                      <td class="py-5 px-4 font-medium text-zinc-200"><%= user.name %></td>
                      <td class="py-5 px-4">
                        <span class={"px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter #{if user.role == "admin", do: "bg-red-900/40 text-red-400 border border-red-900/50", else: "bg-zinc-800 text-zinc-400 border border-zinc-700"}"}>
                          <%= user.role %>
                        </span>
                      </td>
                      <td class="py-5 px-4 text-zinc-500 text-right font-mono text-xs group-hover:text-zinc-300"><%= user.email %></td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <%= if @selected_user do %>
      <.modal id="user-details-modal" show={true} on_cancel={JS.push("close_modal")}>
        <div class="p-6">
          <h2 class="text-2xl font-bold mb-4"><%= @selected_user.name %></h2>
          <p class="text-sm text-zinc-400 mb-2"><strong>Email:</strong> <%= @selected_user.email %></p>
          <p class="text-sm text-zinc-400 mb-2"><strong>Matrícula:</strong> <%= @selected_user.staff_number %></p>
          <p class="text-sm text-zinc-400 mb-6"><strong>Cargo:</strong> <%= @selected_user.role %></p>
          
          <.button phx-click="reset_password" phx-value-id={@selected_user.id} class="w-full">
            Redefinir Senha
          </.button>
        </div>
      </.modal>
    <% end %>
    """
  end
end
