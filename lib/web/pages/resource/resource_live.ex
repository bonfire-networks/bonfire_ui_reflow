defmodule Bonfire.UI.Reflow.ResourceLive do
  use Bonfire.UI.Common.Web, :surface_live_view
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

  # alias Bonfire.UI.Reflow.ResourceWidget

  @recurse_limit 10

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(%{"id" => id} = _params, _session, socket) do
    # debug(post_plugs: socket)

    resource = economic_resource(%{id: id}, socket)

    # debug(resource: resource)

    {:ok,
     assign(
       socket,
       page_title: "resource",
       page: "Resource",
       selected_tab: "about",
       smart_input: false,
       # resource: "1234",
       resource: resource,
       json: resource |> nested_structs_to_maps() |> Jason.encode!(),
       units: Bonfire.UI.Reflow.ProcessLive.units_for_select(socket)
     )}
  end

  @resource_fields_basic """
    __typename
    id
    name
    note
    image
    primary_accountable {
      __typename
      id
      name
      image
      display_username
      canonical_url
    }
    onhand_quantity {
      __typename
      id
      has_numerical_value
      has_unit {
        label
        symbol
      }
    }
  """

  @track_trace """
  (recurse_limit: #{@recurse_limit}){
      __typename
      ...on EconomicEvent {#{Bonfire.UI.Reflow.ProcessLive.event_fields_basic()}}
      ...on EconomicResource {#{@resource_fields_basic}}
      ...on Process {#{Bonfire.UI.Reflow.ProcessLive.process_fields_basic()}}
    }
  """

  @graphql """
  query($id: ID) {
    economic_resource(id: $id) {
      #{@resource_fields_basic}
      current_location {
        __typename
        id
        name
        mappable_address
      }
      conforms_to {
        __typename
        id
        name
        note
        image
      }
      tags {
        __typename
        ...on Tag {
          id
          name
          summary
        }
        ...on Category {
          id
          name
          summary
        }
      }
      track#{@track_trace}
      trace#{@track_trace}
    }
  }
  """
  def economic_resource(params \\ %{}, socket),
    do: liveql(socket, :economic_resource, params)

  # FIXME: looks like we can't have multiple liveql queries in same module?
  # @graphql """
  # query($id: ID) {
  #   economic_resource(id: $id) {
  #     track #{Bonfire.UI.Reflow.ProcessLive.event_fields}
  #   }
  # }
  # """
  # def track(params \\ %{}, socket), do: liveql(socket, :economic_resource, params)

  # @graphql """
  # query($id: ID) {
  #   economic_resource(id: $id) {
  #     trace #{Bonfire.UI.Reflow.ProcessLive.event_fields}
  #   }
  # }
  # """
  # def trace(params \\ %{}, socket), do: liveql(socket, :economic_resource, params)

  def handle_params(%{"tab" => "track"}, attrs, socket) do
    resource = e(assigns(socket), :resource, nil)

    if resource do
      # resource = track(%{id: id}, socket)
      # debug(track: resource)

      {:noreply,
       assign(
         socket,
         selected_tab: "track",
         # |> debug("track")
         feed: e(resource, :track, [])
       )}
    end
  end

  def handle_params(_, attrs, socket) do
    resource = e(assigns(socket), :resource, nil)

    if resource do
      # resource = trace(%{id: id}, socket)
      # debug(trace: resource)

      {:noreply,
       assign(
         socket,
         selected_tab: "trace",
         # |> debug("trace")
         feed: e(resource, :trace, [])
       )}
    end
  end
end
