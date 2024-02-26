defmodule Bonfire.UI.Reflow.MapLive do
  use Bonfire.UI.Common.Web, :live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, session, socket) do
    # intents = Bonfire.UI.ValueFlows.ProposalLive.all_intents(socket)
    # debug(intents)

    {:ok,
     assign(
       socket,
       page_title: "Map of events",
       page: "map",
       selected_tab: "about",
       places: fetch_resources_places(socket),
       fetch_place_things_fn: &Bonfire.UI.Reflow.MapLive.fetch_resources_places/2
     )}
  end

  def fetch_resources_places(filters \\ [], _socket) do
    with {:ok, things} <-
           ValueFlows.EconomicResource.EconomicResources.many(
             [{:preload, :current_location}] ++ filters
           ) do
      debug(things: things)

      things
      |> Enum.map(
        &Map.merge(
          Map.get(&1, :current_location) || %{},
          &1
        )
      )
      |> Enum.filter(&Map.has_key?(&1, :geom))

      # |> debug("fetch_place_things")
    else
      e ->
        debug(error: e)
        nil
    end
  end

  def fetch_events_places(filters \\ [], _socket) do
    with {:ok, things} <-
           ValueFlows.EconomicEvent.EconomicEvents.many([{:preload, :locations}] ++ filters) do
      # debug(things)

      things
      |> Enum.map(
        &Map.merge(
          Map.get(&1, :at_location) || Map.get(&1, :to_resource_inventoried_as) ||
            Map.get(&1, :resource_inventoried_as) || %{},
          &1
        )
      )
      |> Enum.filter(&Map.has_key?(&1, :geom))

      # |> debug("fetch_place_things")
    else
      e ->
        debug(error: e)
        nil
    end
  end

  # proxy relevent events to the map component # FIXME
  def handle_event("map_" <> _action = event, params, socket) do
    debug(proxy_event: event)
    debug(proxy_params: params)
    Bonfire.Geolocate.MapLive.handle_event(event, params, socket, true)
  end
end
