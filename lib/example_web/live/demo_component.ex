defmodule ExampleWeb.DemoComponent do
  use ExampleWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="border-2 p-2 rounded-lg bg-blue-100">
      <h2>LiveComponent</h2>
      <p><%= inspect(self()) %></p>
      <.button phx-click="set_text" phx-target={@myself}>クリック</.button>
      <p :if={@set_text}>hello world!</p>
      <div class="my-2">
        <.button phx-click="send" phx-value-message="hello">
          親LiveViewにイベントを送信
        </.button>
      </div>

      <div class="my-2">
        <.button phx-click="clear" phx-target={@myself}>
          親LiveViewにメッセージを送信
        </.button>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:set_text, false)
      |> assign(assigns)

    {:ok, socket}
  end

  def handle_event("set_text", _params, socket) do
    {:noreply, assign(socket, :set_text, !socket.assigns.set_text)}
  end

  def handle_event("clear", _params, socket) do
    send(self(), {:send_message, :clear})
    {:noreply, socket}
  end
end
