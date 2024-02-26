defmodule Bonfire.UI.Reflow.ProcessLive do
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

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(%{"id" => id} = _params, _session, socket) do
    {:ok,
     assign(
       socket,
       page_title: "process",
       page: "process",
       selected_tab: "events",
       smart_input: false,
       units: units_for_select(socket),
       # |> debug()
       process: process(%{id: id}, socket)

       # resource: resource,
     )}
  end

  @process_fields_basic """
  __typename
  id
  name
  note
  has_end
  finished
  """

  @agent_fields """
  {
    __typename
    id
    name
    image
    display_username
  }
  """

  @quantity_fields """
  {
    __typename
    has_numerical_value
    has_unit {
      label
      symbol
    }
  }
  """

  @resource_fields """
  {
    __typename
    id
    name
    note
    image
    onhand_quantity #{@quantity_fields}
    accounting_quantity #{@quantity_fields}
  }
  """

  @event_fields_basic """
    __typename
    id
    note
    provider #{@agent_fields}
    receiver #{@agent_fields}
    action {
      label
    }
    resource_quantity #{@quantity_fields}

    resource_inventoried_as #{@resource_fields}
    to_resource_inventoried_as #{@resource_fields}
  """

  @event_fields """
  {
    #{@event_fields_basic}

    effort_quantity #{@quantity_fields}

    output_of
    input_of
  }
  """

  def process_fields_basic, do: @process_fields_basic
  def event_fields_basic, do: @event_fields_basic
  def event_fields, do: @event_fields

  @graphql """
    query($id: ID) {
      process(id: $id) {
        #{@process_fields_basic}
        outputs #{@event_fields}
      }
    }
  """
  def process(params \\ %{}, socket), do: liveql(socket, :process, params)

  @graphql """
    {
      units_pages {
        edges {
          id
          label
        }
      }
    }
  """
  def units_pages(params \\ %{}, socket),
    do: liveql(socket, :units_pages, params)

  # |> IO.inspect
  def units_for_select(socket),
    do: units_pages(socket) |> e(:edges, []) |> Enum.map(&{&1.label, &1.id})
end
