defmodule ExampleWeb.CalculatorComponent do
  use ExampleWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="mt-6">
      <.button phx-click="display_calc" phx-target={@myself}><%= if @set_calc, do: "計算機を非表示", else: "計算機を表示" %></.button>
      <div class="w-60 grid grid-cols-1 gap-4 p-4 mt-6 bg-gray-600 rounded-lg" :if={@set_calc}>
        <p class="font-bold text-xl bg-white rounded-lg px-2"><%= if @result == "", do: 0, else: @result %></p>
        <div class="grid grid-cols-4 gap-4">
          <% base_class = "w-10 p-1 rounded-lg text-center" %>
          <div class="grid grid-cols-3 gap-4 col-span-3 cursor-pointer">
            <div phx-click="clear" phx-target={@myself}>
              <div class={[base_class, "bg-red-300"]}>AC</div>
            </div>
            <div></div>
            <div></div>
            <div
              :for={n <- 9..0}
              phx-click="calc"
              phx-value-number={n}
              phx-target={@myself}
            >
              <div class={[base_class, "bg-gray-300"]}><%= n %></div>
            </div>
            <div phx-click="calc" phx-value-number="." phx-target={@myself}>
              <div class={[base_class, "bg-gray-300"]}>.</div>
            </div>
          </div>
          <div class="grid grid-cols-1 gap-4">
            <div
              :for={{display, value} <- [{"÷", "/"},  {"x", "*"},  {"-", "-"},  {"+", "+"}, {"=", "="}]}
              phx-click="calc"
              phx-value-formula={value}
              phx-target={@myself}
              class="cursor-pointer"
            >
              <div class={[base_class, "bg-amber-500"]}><%= display %></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:result, "")
      |> assign(:formula, [])
      |> assign(:set_calc, false)

    {:ok, socket}
  end

  def handle_event("display_calc", _, socket) do
    {:noreply, assign(socket, :set_calc, !socket.assigns.set_calc)}
  end

  def handle_event("calc", %{"formula" => "="}, socket)
    when length(socket.assigns.formula) > 1 do
    socket.assigns.formula
    |> formula_to_quoted()
    |> case do
      {:error, _} ->
        socket
        |> put_flash(:error, "Error!")
        |> assign(:result, "Error")

      {:ok, expr} ->
        {result, _} = Code.eval_quoted(expr)
        socket
        |> assign(:result, "#{result}")
        |> assign(:formula, ["#{result}"])
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("calc", %{"formula" => _}, socket)
    when length(socket.assigns.formula) == 0 do
    {:noreply, socket}
  end

  def handle_event("calc", %{"formula" => formula}, socket) do
    socket.assigns.formula
    |> formula_to_quoted()
    |> case do
      {:error, _} ->
        socket
      {:ok, _expr} ->
        formula = List.insert_at(socket.assigns.formula, -1, formula)
        assign_formula(socket, formula)
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("calc", %{"number" => number}, socket)
    when length(socket.assigns.formula) == 0 do
      socket
      |> assign_formula([number])
      |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("calc", %{"number" => number}, socket) do
    formula =
      if Enum.at(socket.assigns.formula, -1) in ~w(/ * - +) do
        List.insert_at(socket.assigns.formula, -1, number)
      else
        List.update_at(socket.assigns.formula, -1, fn f -> f <> number end)
      end
    socket
    |> assign_formula(formula)
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event("clear", _params, socket) do
    socket =
      socket
      |> assign(:result, "")
      |> assign(:formula, [])

    {:noreply, socket}
  end

  defp formula_to_string(formula) do
    formula
    |> Enum.join(" ")
    |> String.replace(["/"], "÷")
    |> String.replace(["*"], "x")
  end

  defp formula_to_quoted(formula) do
    formula
    |> Enum.join(" ")
    |> Code.string_to_quoted()
  end

  defp assign_formula(socket, formula) do
    socket
    |> assign(:formula, formula)
    |> assign(:result, formula_to_string(formula))
  end
end
