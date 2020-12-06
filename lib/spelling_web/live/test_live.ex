defmodule SpellingWeb.TestLive do
  use Phoenix.LiveView, layout: {SpellingWeb.LayoutView, "live.html"}

  def render(assigns) do
    ~L"""
    <div>
      <p>This is the result</p>
    </div>
    """
  end

  def mount(_, _session, socket) do
    {:ok, socket}
  end
end
