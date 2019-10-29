defmodule SpellingWeb.ClipController do
  use SpellingWeb, :controller

  alias Spelling.Content

  def get(conn, %{"id" => id}) do
    word = Content.get_word!(id)
    clip = "data:audio/webm;codecs=opus;base64," <> Base.encode64(word.clip)

    text(conn, clip)
  end
end
