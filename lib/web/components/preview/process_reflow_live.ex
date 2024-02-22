defmodule Bonfire.UI.Reflow.Preview.ProcessReflowLive do
  use Bonfire.UI.Common.Web, :stateless_component

  # alias Bonfire.Social.Likes

  prop object, :any, required: true
  prop activity, :any, default: nil
  prop showing_within, :atom, default: nil
end
