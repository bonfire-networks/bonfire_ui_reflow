defmodule Bonfire.UI.Reflow.MaterialsLive do
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

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    resources = resources(socket)
    debug(resources)

    {:ok,
     assign(
       socket,
       resource_url_prefix: "/resource/",
       page_title: "All materials",
       page: "materials",
       smart_input: false,
       resources: e(resources, :economicResources, [])
     )}
  end

  @graphql """
  {
    economicResources {
      __typename
      id
      name
      note
      image
      current_location {
        __typename
        id
        name
        mappable_address
      }
      onhand_quantity {
        __typename
        id
        has_numerical_value
        has_unit {
          __typename
          label
          symbol
        }
      }
    }
  }
  """
  def resources(params \\ %{}, socket), do: liveql(socket, :resources, params)

  defdelegate handle_params(params, attrs, socket),
    to: Bonfire.UI.Common.LiveHandlers

  def handle_event(
        action,
        attrs,
        socket
      ),
      do:
        Bonfire.UI.Common.LiveHandlers.handle_event(
          action,
          attrs,
          socket,
          __MODULE__
          # &do_handle_event/3
        )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
