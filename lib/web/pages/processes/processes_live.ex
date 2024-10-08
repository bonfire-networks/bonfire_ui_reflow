defmodule Bonfire.UI.Reflow.ProcessesLive do
  use Bonfire.UI.Common.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient,
    schema: Bonfire.API.GraphQL.Schema,
    action: [mode: :internal]

  alias Bonfire.UI.Social.HashtagsLive
  alias Bonfire.UI.Social.ParticipantsLive

  alias Bonfire.UI.ValueFlows.IntentCreateActivityLive
  alias Bonfire.UI.ValueFlows.CreateMilestoneLive

  alias Bonfire.UI.ValueFlows.FiltersLive

  alias Bonfire.Me.Users
  alias Bonfire.UI.Me.CreateUserLive

  # alias Bonfire.UI.Coordination.ResourceWidget

  declare_extension("Reflow",
    icon: "tmdi:recycle",
    emoji: "♻️",
    href: "/reflow",
    description: l("reflowproject.eu")
  )

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> fetch_assigns()
     |> assign(
       page_title: "All Processes",
       page: "processes",
       smart_input: false,
       processes: [],
       page_info: nil
     )}
  end

  @graphql """
  query($after: Cursor, $limit: Int) {
    processes_pages(after: $after, limit: $limit) {
      page_info
      edges {
        __typename
        id
        name
        note
        has_end
        intended_outputs {
          finished
        }
      }
    }
  }
  """
  def processes_pages(params \\ %{}, socket),
    do: liveql(socket, :processes_pages, params)

  def fetch_assigns(params \\ %{}, socket) do
    with %{edges: processes, page_info: page_info} <-
           processes_pages(params, socket) do
      assign(
        socket,
        processes: (e(assigns(socket), :processes, []) ++ processes) |> Enum.uniq(),
        page_info: page_info
      )
    else
      _ ->
        socket
    end
  end

  def handle_event("load-more", params, socket) do
    {:noreply,
     input_to_atoms(params)
     |> fetch(socket)}
  end
end
