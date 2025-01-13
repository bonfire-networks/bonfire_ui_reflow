defmodule Bonfire.UI.Reflow.Routes do
  @behaviour Bonfire.UI.Common.RoutesModule

  defmacro __using__(_) do
    quote do
      # pages anyone can view
      scope "/reflow" do
        pipe_through(:browser)
        live("/", Bonfire.UI.Reflow.ProcessesLive)

        live("/resource/:id", Bonfire.UI.Reflow.ResourceLive, as: ValueFlows.EconomicResource)
        live("/resource/:id/:tab", Bonfire.UI.Reflow.ResourceLive)

        # , as: ValueFlows.Process)
        live("/process/", Bonfire.UI.Reflow.ProcessLive)
        # , as: ValueFlows.Process)
        live("/process/:id", Bonfire.UI.Reflow.ProcessLive)
        live("/process/:id/:tab", Bonfire.UI.Reflow.ProcessLive)

        live("/materials", Bonfire.UI.Reflow.MaterialsLive)

        live("/inventory", Bonfire.UI.Reflow.InventoryLive)

        live("/map", Bonfire.UI.Reflow.MapLive)

        live("/event/:id", Bonfire.UI.Social.DiscussionLive, as: ValueFlows.EconomicEvent)

        live("/resource_spec/:id", Bonfire.UI.Social.DiscussionLive,
          as: ValueFlows.Knowledge.ResourceSpecification
        )
      end
    end
  end
end
