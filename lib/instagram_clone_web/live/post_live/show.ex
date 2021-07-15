defmodule InstagramCloneWeb.PostLive.Show do
    use InstagramCloneWeb, :live_view
    

    alias InstagramClone.Posts
    alias InstagramClone.Uploaders.Avatar
    alias InstagramCloneWeb.PostLive.LikeComponent

    @impl true
    def mount(%{"id" => id}, session, socket) do
        socket = assign_defaults(session, socket)
        post = Posts.get_post_by_url!(URI.decode(id))

        {:ok,
            socket 
            |> assign(post: post)}
    end

    @impl true
    def handle_info({LikeComponent, :update_post_likes, post_id}, socket) do
        {:noreply,
            socket
            |> assign(post: Posts.get_post!(post_id))}
    end
end