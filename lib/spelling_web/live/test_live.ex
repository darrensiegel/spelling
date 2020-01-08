defmodule SpellingWeb.TestLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <p>This is the result</p>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, socket}
  end
end
