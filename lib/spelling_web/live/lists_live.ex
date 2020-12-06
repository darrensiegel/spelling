defmodule SpellingWeb.ListsLive do
  use Phoenix.LiveView, layout: {SpellingWeb.LayoutView, "live.html"}
  use Phoenix.HTML
  alias Spelling.Content
  alias Spelling.Content.List
  alias SpellingWeb.DetailsLive
  alias SpellingWeb.Router.Helpers, as: Routes
  alias Spelling.Repo
  import Ecto.Query, only: [from: 2]

  def render(assigns) do
    ~L"""
    <div>
      <h3>Spelling lists</h3>
      <table class="ui table celled">
        <thead>
          <tr>
            <th>Week ending</th>
          </tr>
        </thead>
        <tbody id="lists" phx-update="append">
          <%= for list <- @lists do %>
            <tr id="row-<%= list.id %>">
              <td>
                <%= link list.week_ending, to: Routes.live_path(@socket, DetailsLive, list.id) %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
      <button class="ui button primary" phx-click="create">New</button>
    </div>
    """
  end

  def mount(_, _session, socket) do
    IO.inspect "mounted"
    {:ok, socket}
  end

  def handle_params(%{"user" => user}, _uri, socket) do
    lists = Content.lists_for_user(user)

    {:noreply,
     assign(socket, %{
       lists: lists,
       user: user
     })}
  end

  def handle_event("create", _, socket) do
    now = Date.utc_today()
    day_of_week = Date.day_of_week(now)
    user = socket.assigns.user

    next_friday =
      case day_of_week do
        5 -> Date.add(now, 7)
        6 -> Date.add(now, 6)
        7 -> Date.add(now, 5)
        _ -> Date.add(now, 5 - day_of_week)
      end

    query = from(p in List, select: max(p.week_ending), where: p.name == ^user)

    week_ending =
      case Repo.one(query) do
        nil -> next_friday
        max -> Date.add(max, 7)
      end

    IO.inspect(week_ending)

    {:ok, list} = Content.create_list(%{week_ending: week_ending, name: user})

    lists = [list] ++ socket.assigns.lists

    {:noreply, assign(socket, lists: lists)}
  end
end
