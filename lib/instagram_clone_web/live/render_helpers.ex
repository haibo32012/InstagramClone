defmodule InstagramCloneWeb.RenderHelpers do
    import Phoenix.LiveView.Helpers
    def selected_link?(current_uri, menu_link) when current_uri == menu_link do
        "border-1-2 border-black -ml-0.5 text-gray-900 font-semibold"
    end

    def selected_link?(_current_uri, _menu_link) do
        "hover:border-1-2 -ml-0.5 hover:border-gray-300 hover:bg-gray-50"
    end

    def display_website_uri(website) do
        website = website
        |> String.replace_leading("https://", "")
        |> String.replace_leading("http://", "")
        website
    end

    def live_modal(socket, component, opts) do
        path = Keyword.fetch!(opts, :return_to)
        width = Keyword.fetch!(opts, :width)
        modal_opts = [id: :modal, return_to: path, width: width, component: component, opts: opts]
        live_component(socket, InstagramCloneWeb.ModalComponent, modal_opts)
    end
end