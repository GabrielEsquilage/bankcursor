defmodule BankcursorWeb.HomeLive do
  use BankcursorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative isolate overflow-hidden bg-zinc-950 min-h-[80vh] flex items-center justify-center">
      <!-- Background effects -->
      <div class="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80" aria-hidden="true">
        <div class="relative left-[calc(50%-11rem)] aspect-[1155/678] w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-[#ff4d4d] to-[#b91c1c] opacity-20 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem]" style="clip-path: polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)"></div>
      </div>

      <div class="mx-auto max-w-4xl px-6 lg:px-8">
        <div class="text-center">
          <h1 class="text-4xl font-extrabold tracking-tight text-white sm:text-6xl bg-clip-text text-transparent bg-gradient-to-r from-white to-zinc-400">
            A nova era da sua vida financeira
          </h1>
          <p class="mt-6 text-lg leading-8 text-zinc-400 max-w-2xl mx-auto">
            Bankcursor: simplicidade, segurança e controle total na palma da sua mão. 
            O banco feito para acompanhar o seu ritmo.
          </p>
          <div class="mt-10 flex items-center justify-center">
            <.link navigate={~p"/register"} class="rounded-full bg-red-600 px-12 py-4 text-sm font-bold text-white shadow-lg shadow-red-600/20 hover:bg-red-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-red-600 transition-all duration-300 transform hover:scale-105">
              Criar Conta Gratuita <span aria-hidden="true">→</span>
            </.link>
          </div>
        </div>
        
        <!-- Features quick-look -->
        <div class="mt-20 grid grid-cols-1 gap-8 sm:grid-cols-3">
          <div class="rounded-2xl border border-white/5 bg-white/5 p-6 backdrop-blur-sm">
            <div class="text-red-500 mb-2 font-bold text-xl">100% Digital</div>
            <p class="text-sm text-zinc-500">Abra sua conta em minutos e comece a usar na hora.</p>
          </div>
          <div class="rounded-2xl border border-white/5 bg-white/5 p-6 backdrop-blur-sm">
            <div class="text-red-500 mb-2 font-bold text-xl">Taxa Zero</div>
            <p class="text-sm text-zinc-500">Sem mensalidades ou taxas escondidas para você.</p>
          </div>
          <div class="rounded-2xl border border-white/5 bg-white/5 p-6 backdrop-blur-sm">
            <div class="text-red-500 mb-2 font-bold text-xl">Segurança</div>
            <p class="text-sm text-zinc-500">Tecnologia de ponta para proteger seu patrimônio.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
