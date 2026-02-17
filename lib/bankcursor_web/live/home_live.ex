defmodule BankcursorWeb.HomeLive do
  use BankcursorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="jumbotron">
      <h1 class="display-4">Bem-vindo ao Bankcursor!</h1>
      
      <p class="lead">Seu novo frontend com Phoenix LiveView está funcionando.</p>
    </div>
    """
  end
end
