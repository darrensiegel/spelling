defmodule SpellingWeb.SpellLive do
  use Phoenix.LiveView

  alias Spelling.Content
  alias SpellingWeb.Utils
  alias Spelling.Content.Word
  alias SpellingWeb.DetailsLive
  alias SpellingWeb.Router.Helpers, as: Routes
  alias Spelling.Repo
  import Ecto.Query, only: [from: 2]

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

    hinting =
      case assigns.correct do
        False ->
          "error"

        _ ->
          ""
      end

    style =
      case assigns.correct do
        True -> "background-color: #D8E8D7; color: #3C6E3A; border: #6BA568;"
        _ -> ""
      end

    image = Enum.random(@pokemon)

    IO.puts(hinting)

    ~L"""
    <div style="position: relative;">

      <div class="ui massive form">
        <div class="field <%=hinting%>">
          <input style="<%= style %>" type="text" phx-keyup="input" value="<%= @input %>">
        </div>
        <button class="ui submit button" phx-click="check">Submit</button>
      </div>

      <div data-clip-id="<%= @word.id %>" phx-hook="AudioClipPlay"></div>

      <button
        phx-hook="ClickPlay"
        data-clip-id="<%= @word.id %>"
        style="margin-left: 10px; margin-top: 40px;"
        class="ui mini icon button orange">
        <i class="play icon"></i>
      </button>

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

  def mount(_session, socket) do
    {:ok,
     assign(socket,
       word: nil,
       list_id: nil,
       correct: nil,
       input: "",
       in_a_row: 0,
       rewarded: False
     )}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    IO.puts("handle params")
    generate_question(id, socket)
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

    {:noreply,
     assign(socket, %{
       list_id: id,
       input: "",
       word: word,
       correct: nil,
       rewarded: False
     })}
  end

  def handle_event("input", %{"value" => input}, socket) do
    IO.puts("input")
    {:noreply, assign(socket, input: input, correct: nil)}
  end

  def handle_event("check", _, socket) do
    IO.puts("handle check")
    word = socket.assigns.word
    input = socket.assigns.input
    in_a_row = socket.assigns.in_a_row

    {in_a_row, correct} =
      if input == word.word do
        {in_a_row + 1, True}
      else
        {0, False}
      end

    rewarded = Utils.rewarded?(in_a_row)

    {:noreply, assign(socket, correct: correct, in_a_row: in_a_row, rewarded: rewarded)}
  end

  def handle_event("next", _, socket) do
    IO.puts("handle next")
    generate_question(socket.assigns.list_id, socket)
  end
end
