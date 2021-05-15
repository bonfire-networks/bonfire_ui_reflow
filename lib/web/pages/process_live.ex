defmodule Bonfire.UI.Reflow.ProcessLive do
  use Bonfire.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias Bonfire.UI.ValueFlows.{IntentCreateActivityLive, CreateMilestoneLive, ProposalFeedLive, FiltersLive}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  # alias Bonfire.UI.Reflow.ResourceWidget

  def mount(params, session, socket) do

    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(%{"id"=> id} = _params, _session, socket) do

    {:ok, socket
    |> assign(
      page_title: "process",
      page: "process",
      selected_tab: "events",
      smart_input: false,
      process: process(%{id: id}, socket) |> IO.inspect()
      # resource: resource,
    )}
  end

  @quantity_fields """
  {
    has_numerical_value
    has_unit {
      label
      symbol
    }
  }
  """

  @graphql """
    query($id: ID) {
      process(id: $id) {
        id
        name
        note
        has_end
        finished
        outputs {
          id
          __typename
          note
          provider
          receiver
          action {
            label
          }
          resource_quantity {
            has_numerical_value
            has_unit {
              label
              symbol
            }
          }
          effort_quantity {
            has_numerical_value
            has_unit {
              label
              symbol
            }
          }
          resource_inventoried_as {
            id
            name
            note
            image
            onhand_quantity {
              has_numerical_value
              has_unit {
                label
                symbol
              }
            }
            accounting_quantity {
              has_numerical_value
              has_unit {
                label
                symbol
              }
            }
          }
          to_resource_inventoried_as {
            id
            name
            note
            image
            onhand_quantity #{@quantity_fields}
            accounting_quantity {
              has_numerical_value
              has_unit {
                label
                symbol
              }
            }
          }

        }
      }
    }
  """
  def process(params \\ %{}, socket), do: liveql(socket, :process, params)


  defdelegate handle_params(params, attrs, socket), to: Bonfire.Web.LiveHandler
  def handle_event(action, attrs, socket), do: Bonfire.Web.LiveHandler.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Web.LiveHandler.handle_info(info, socket, __MODULE__)

end
