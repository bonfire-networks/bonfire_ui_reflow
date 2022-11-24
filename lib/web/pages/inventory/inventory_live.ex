defmodule Bonfire.UI.Reflow.InventoryLive do
  use Bonfire.UI.Common.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient,
    schema: Bonfire.API.GraphQL.Schema,
    action: [mode: :internal]

  alias Bonfire.UI.Me.LivePlugs
  alias Bonfire.Me.Users

  def mount(params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
  end

  defp mounted(_params, _session, socket) do
    resources = agent_resources(%{id: e(current_user(socket), :id, nil)}, socket)

    # debug(Jason.encode!(resources))
    # debug(resources)

    {:ok,
     assign(
       socket,
       page_title: "My inventory",
       resource_url_prefix: "/resource/",
       page: "inventory",
       smart_input: false,
       resources: e(resources, :agent, :inventoried_economic_resources, [])
     )}
  end

  @graphql """
  query($id: ID) {
  agent(id: $id) {
    inventoried_economic_resources {
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
          label
          symbol
        }
      }
    }
  }}
  """
  def agent_resources(params \\ %{}, socket),
    do: liveql(socket, :agent_resources, params)

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
end
