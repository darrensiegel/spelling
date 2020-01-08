defmodule SpellingWeb.DetailsLive do
  use Phoenix.LiveView

  alias Spelling.Content
  alias Spelling.Content.List
  alias Spelling.Content.Word
  alias SpellingWeb.DetailsLive
  alias SpellingWeb.Router.Helpers, as: Routes
  alias Spelling.Repo
  import Ecto.Query, only: [from: 2]

  def render(assigns) do
    ~L"""
    <div>
      <h3>Week ending <%= @list.week_ending %></h3>
      <%= live_link "Multiple Choice!", to: Routes.live_path(@socket, SpellingWeb.MultipleChoiceLive, @list.id) %>
      <%= live_link "Spelling!", to: Routes.live_path(@socket, SpellingWeb.SpellLive, @list.id) %>

      <table class="ui table celled">
        <thead>
          <tr>
            <th>Word</th>
            <th></th>
          </tr>
        </thead>
        <tbody id="lists" phx-update="append">
          <%= for word <- @words do %>
            <tr id="word-<%= word.id %>">
              <td>
                <a href="#" phx-click="play" phx-value-id="<%= word.id %>"><%= word.word %></a>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <div class="ui divider"></div>

      <div class="ui form">
        <div class="fields">
          <div class="inline field">
            <label>Create new word:</label>
            <input id="name" type="text" placeholder="The word" phx-hook="AudioWord">
          </div>
          <div class="ui icon buttons" >
            <button class="ui button" id="record" phx-hook="AudioRecord">
              <i class="microphone icon"></i>
            </button>
            <button class="ui button" id="stop" phx-hook="AudioStop">
              <i class="stop icon"></i>
            </button>
            <button class="ui button" id="save" phx-hook="AudioSave">
              <i class="save icon"></i>
            </button>
          </div>
        </div>
      </div>


      <audio style="display: none;" id="audio" src="<%= @clip %>" phx-hook="AudioClip"></audio>

    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, word: "", loaded: false, list: nil, clip: nil, state: "none")}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    words = Content.get_just_words!(id)

    {:noreply,
     assign(socket, %{
       list_id: id,
       list: Content.get_list!(id),
       words: words
     })}
  end

  def handle_event("create", %{"word" => word, "clip" => clip}, socket) do
    list_id = socket.assigns.list_id

    {:ok, _word} = Content.create_word(%{word: word, clip: clip, list_id: list_id})

    words = Content.get_just_words!(list_id)

    {:noreply, assign(socket, words: words)}
  end

  def handle_event("play", %{"id" => id}, socket) do
    IO.puts("play: " <> id)

    word = Content.get_word!(id)

    clip = "data:audio/webm;codecs=opus;base64," <> Base.encode64(word.clip)

    {:noreply, assign(socket, clip: clip, state: "loaded")}
  end

  def handle_event("record", _params, socket) do
    IO.puts("record")
    {:noreply, assign(socket, clip: nil, loaded: false, state: "recording")}
  end

  def handle_event("stop", _params, socket) do
    IO.puts("stop")
    {:noreply, assign(socket, clip: nil, loaded: false, state: "stopped")}
  end

  def handle_event("save", %{"clip" => encoded_clip}, socket) do
    IO.puts("save")
    list_id = socket.assigns.list_id
    word = socket.assigns.word

    prefix = "data:audio/webm;codecs=opus;base64,"

    clip =
      Base.decode64!(
        String.slice(encoded_clip, String.length(prefix), String.length(encoded_clip))
      )

    IO.puts(word)
    IO.puts(list_id)
    IO.puts(encoded_clip)

    Content.create_word(%{word: word, list_id: list_id, clip: clip})
    words = Content.get_just_words!(list_id)

    IO.puts(words)

    {:noreply, assign(socket, words: words, clip: nil, loaded: false, state: "none")}
  end

  def handle_event("word", %{"value" => word}, socket) do
    IO.puts("word")
    {:noreply, assign(socket, word: word)}
  end
end
