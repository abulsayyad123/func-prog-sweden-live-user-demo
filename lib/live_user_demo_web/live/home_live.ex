defmodule LiveUserDemoWeb.HomeLive do
  use LiveUserDemoWeb, :live_view
  alias LiveUserDemoWeb.Presence
  @topic "users:list"

  alias LiveUserDemo.Accounts.User
  alias LiveUserDemo.Repo

  def mount(_params, _session, socket) do
    users = Repo.all(User)
    %{current_user: current_user} = socket.assigns
    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveUserDemo.PubSub, @topic)

      {:ok, _} = Presence.track(self(), @topic, current_user.id, %{})
    end

    socket = socket
      |> assign(:users, users)
      |> assign(:logged_in_users, Map.keys(Presence.list(@topic)))
    {:ok, socket}
  end

  def handle_info(%{topic: "users:list", event: "presence_diff", payload: diff}, socket) do
    socket =
      socket
      |> remove_logged_in_users(diff.leaves)
      |> add_logged_in_users(diff.joins)
    {:noreply, socket}
  end

  defp remove_logged_in_users(socket, leaves) do
    users = socket.assigns.logged_in_users -- Map.keys(leaves)
    assign(socket, :logged_in_users, users)
  end

  defp add_logged_in_users(socket, joins) do
    users = socket.assigns.logged_in_users ++ Map.keys(joins)
    assign(socket, :logged_in_users, users)
  end

  def render(assigns) do
    ~H"""
    <div id="presence">
      <div class="users">
        <ul>
          <li :for={user <- @users}>
            <span class="username">
              <%= user.email %>
            </span>
            <span class={if Enum.member?(@logged_in_users, to_string(user.id)), do: "online", else: "offline"}>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
