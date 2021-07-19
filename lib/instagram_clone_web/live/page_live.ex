defmodule InstagramCloneWeb.PageLive do
  use InstagramCloneWeb, :live_view

  alias InstagramClone.Accounts
  alias InstagramClone.Uploaders.Avatar
  alias InstagramClone.UserLive.FollowComponent
  alias InstagramClone.Posts
  alias InstagramCloneWeb.Live.LikeComponent
  alias InstagramClone.Posts.Post

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    if connected?(socket), do: Posts.subscribe
    {:ok, 
      socket
      |> assign(page_title: "InstagramClone")
      |> assign(new_posts_added: false)
      |> assign(page: 1, per_page: 15),
      temporary_assigns: [user_feed: []]}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
      socket
      |> assign(live_action: apply_action(socket.assigns.current_user))
      |> assign_posts()}
  end

  @impl true
  def handle_event("load-more-profile-posts", _, socket) do
    {:noreply, socket |> load_posts}
  end

  defp load_posts(socket) do
    total_posts = socket.assigns.accounts_feed_total
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    total_pages = ceil(total_posts / per_page)

    if page == total_pages do
      socket
    else
      socket
      |> update(:page, &(&1 + 1))
      |> assign_user_feed()
    end
  end

  @impl true
  def handle_info({LikeComponent, :update_comment_likes, _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({FollowComponent, :update_totals, _}, socket) do
    {:noreply, socket}
  end


  @impl true
  def handle_info({LikeComponent, :update_post_likes, post}, socket) do
    post_feed = Posts.get_post_feed!(post.id)
    {:noreply,
      socket
      |> update(:user_feed, fn user_feed -> [post_feed | user_feed] end)}
  end

  @impl true
  def handle_info(%{event: "new_post", payload: %{post: %Post{user_id: post_user_id}}}, socket) do
    if post_user_id in socket.assigns.following_list do
      {:noreply, socket |> assign(new_posts_added: true)}
    else
      {:noreply, socket}
    end
  end

  defp apply_action(current_user) do
    if !current_user, do: :root_path
  end

  defp assign_posts(socket) do
    if socket.assigns.current_user do
      current_user = socket.assigns.current_user
      following_list = Accounts.get_following_list(current_user)
      accounts_feed_total = Posts.get_accounts_feed_total(following_list, socket.assigns)
      random_5_users = Accounts.random_5(current_user)

      socket
      |> assign(following_list: following_list)
      |> assign(accounts_feed_total: accounts_feed_total)
      |> assign(users: random_5_users)
      |> assign_user_feed()
    else
      socket
    end
  end

  defp assign_user_feed(socket) do
    user_feed = Posts.get_accounts_feed(socket.assigns.following_list, socket.assigns)
    socket |> assign(user_feed: user_feed)
  end
end