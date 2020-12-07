defmodule SpellingWeb.MultipleChoiceLive do
  use Phoenix.LiveView, layout: {SpellingWeb.LayoutView, "live.html"}

  alias Spelling.Content

  @pokemon ~w(blastoise.png
    bulbasaur.png
    charimander.png
    charizard.png
    oshawott.png
    pikachu.png
    popplio.png
    rowlet.png
    snivey.png
    squirtle.jpg
    )

  def render(assigns) do
    size = 50 * assigns.in_a_row
    font = 6 * assigns.in_a_row

    display =
      case assigns.rewarded do
        True -> "block"
        _ -> "none"
      end

    image = Enum.random(@pokemon)

    ~L"""
    <div style="position: relative;">

      <%= for c <- @choices do %>
        <% result = case c.result do
          "correct" -> "positive"
          "incorrect" -> "negative"
          _ -> ""
        end %>
        <div>
          <button
            id="button-<%= c.word.id %>"
            phx-click="choice"
            style="width: 200px; margin: 10px;"
            phx-value-choice="<%= c.word.word %>"
            phx-hook="ChoiceButton"
            class="ui choice button massive <%= result %>">
            <%= c.word.word %>
          </button>
        </div>
      <% end %>

      <div id="AudioPlay" data-clip-id="<%= @word.id %>" phx-hook="AudioClipPlay"></div>

      <button
        phx-click="next"
        style="margin-left: 10px; margin-top: 40px;"
        class="ui right labeled icon button mini orange">
        <i class="right arrow icon"></i>
        Next
      </button>

      <div style="display: <%= display %>; position: absolute; top: 10px; left: 300px;">
        <img height="<%= size %>px" width="<%= size %>px"
          id="image" phx-hook="Image" src="/images/<%= image %>"/>
        <div style="font-weight: bold; font-size: <%= font %>px; color: red; position: relative;">
          <%= @in_a_row %> in a row!
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"id" => id}, _session, socket) do

    socket = assign(socket, word: nil)
    socket = generate_question(id, socket)

    {:ok, assign(socket, in_a_row: 0)}
  end

  def generate_question(id, socket) do
    current =
      case socket.assigns.word do
        nil -> ""
        w -> w.id
      end

    words = Content.get_just_words!(id)

    word =
      Enum.filter(words, &(&1.id != current))
      |> Enum.random()

    distractors =
      Enum.filter(words, &(&1.id != word.id))
      |> Enum.shuffle()
      |> Enum.take(3)

    choices =
      ([word] ++ distractors)
      |> Enum.shuffle()
      |> Enum.map(fn w -> %{word: w, result: nil} end)


     assign(socket, %{
       list_id: id,
       word: word,
       rewarded: False,
       choices: choices
     })
  end

  def handle_event("choice", %{"choice" => choice}, socket) do
    IO.puts("handle choice")
    word = socket.assigns.word
    choices = socket.assigns.choices
    in_a_row = socket.assigns.in_a_row

    choices =
      Enum.map(choices, fn c ->
        %{
          c
          | result:
              cond do
                c.word.word == choice and choice == word.word -> "correct"
                c.word.word == choice -> "incorrect"
                True -> c.result
              end
        }
      end)

    in_a_row =
      if choice == word.word do
        in_a_row + 1
      else
        0
      end

    rewarded =
      cond do
        MapSet.new([3, 5, 10]) |> MapSet.member?(in_a_row) -> True
        in_a_row < 3 -> False
        Enum.random(1..7) == 1 -> True
        true -> False
      end

    {:noreply, assign(socket, choices: choices, in_a_row: in_a_row, rewarded: rewarded)}
  end

  def handle_event("next", _, socket) do
    IO.puts("handle next")
    {:noreply, generate_question(socket.assigns.list_id, socket)}
  end
end
