defmodule SpellingWeb.SpellLive do
  use Phoenix.LiveView, layout: {SpellingWeb.LayoutView, "live.html"}

  alias Spelling.Content
  alias SpellingWeb.Utils

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

  @spec render(atom | %{in_a_row: number, rewarded: any, state: any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    size = 50 * assigns.in_a_row
    font = 6 * assigns.in_a_row

    display =
      case assigns.rewarded do
        true -> "block"
        _ -> "none"
      end

    style =
      case assigns.state do
        "incorrect" -> "background-color: #ffb3b3; color: darkred; border-color: darkred;"
        "done" -> "background-color: #2eb82e; color: white; border-color: #6BA568;"
        "correct" -> "background-color: #d6f5d6; color: black; border-color: #6BA568;"
        _ -> ""
      end

    image = Enum.random(@pokemon)

    ~L"""
    <div style="position: relative;">

      <div class="ui massive form">
        <div class="field">
          <input id="inputbox" class="<%= @input %>" style="<%= style %>" type="text" phx-keyup="input" phx-hook="InputBox">
        </div>
      </div>

      <div class="ui buttons" style="margin-top: 20px;">
        <button
          phx-click="letter"
          phx-value-letter="á"
          class="ui massive icon button">
          á
        </button>
        <button
          phx-click="letter"
          phx-value-letter="é"
          class="ui massive icon button">
          é
        </button>
        <button
          phx-click="letter"
          phx-value-letter="í"
          class="ui massive icon button">
          í
        </button>
        <button
          phx-click="letter"
          phx-value-letter="ó"
          class="ui massive icon button">
          ó
        </button>
        <button
          phx-click="letter"
          phx-value-letter="ú"
          class="ui massive icon button">
          ú
        </button>
        <button
          phx-click="letter"
          phx-value-letter="ü"
          class="ui massive icon button">
          ü
        </button>
        <button
          phx-click="letter"
          phx-value-letter="ñ"
          class="ui massive icon button">
          ñ
        </button>
      </div>

      <div id="<%= @word.id %>" data-clip-id="<%= @word.id %>" phx-hook="AudioClipPlay"></div>

      <button
        id="play-<%= @word.id %>"
        phx-hook="ClickPlay"
        data-clip-id="<%= @word.id %>"
        style="margin-left: 10px; margin-top: 40px;"
        class="ui mini icon button orange">
        <i class="play icon"></i>
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

  def mount(_, _session, socket) do
    {:ok,
     assign(socket,
       word: nil,
       list_id: nil,
       state: "none",
       input: "",
       in_a_row: 0,
       rewarded: false
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
       state: "none",
       rewarded: false
     })}
  end

  def handle_info(:next, socket) do
    IO.puts("input")
    id = socket.assigns.list_id
    generate_question(id, socket)
  end

  def process_input(input, socket) do
    word = socket.assigns.word
    in_a_row = socket.assigns.in_a_row

    {state, in_a_row, rewarded} =
      cond do
        word.word == input -> {"done", in_a_row + 1, Utils.rewarded?(in_a_row + 1)}
        String.starts_with?(word.word, input) -> {"correct", in_a_row, false}
        true -> {"incorrect", 0, false}
      end

    if state == "done", do: :timer.send_after(2000, self(), :next)

    {:noreply, assign(socket, input: input, state: state, in_a_row: in_a_row, rewarded: rewarded)}
  end

  def handle_event("input", %{"value" => input}, socket) do
    process_input(input, socket)
  end

  def handle_event("letter", %{"letter" => letter}, socket) do
    input = socket.assigns.input
    process_input(input <> letter, socket)
  end
end
