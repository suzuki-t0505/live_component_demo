defmodule ExampleWeb.Demo1Live do
  use ExampleWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="border-2 p-2 rounded-lg bg-red-100">
      <h1>親LiveView</h1>
      <p><%= inspect(self()) %></p>
      <p><%= @send_message %></p>
      <.live_component
        module={ExampleWeb.DemoComponent}
        id="demo"
      />
      <.live_component
        module={ExampleWeb.CalculatorComponent}
        id="calc1"
      />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :send_message, "")}
  end

  def handle_info({:send_message, :clear}, socket) do
    socket =
      socket
      |> put_flash(:info, "メッセージを受信しました。メッセージを削除します。")
      |> assign(:send_message, "")

    {:noreply, socket}
  end

  def handle_event("send", %{"message" => message}, socket) do
    {:noreply, assign(socket, :send_message, message)}
  end
end
