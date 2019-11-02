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
          <input class="<%= @input %>" style="<%= style %>" type="text" phx-keyup="input" phx-hook="InputBox">
        </div>
      </div>

      <div data-clip-id="<%= @word.id %>" phx-hook="AudioClipPlay"></div>

      <button
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

  def mount(_session, socket) do
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

  def handle_event("input", %{"value" => input}, socket) do
    IO.puts("input")

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
end
