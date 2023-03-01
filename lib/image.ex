defmodule ElixirIdenticon.Image do
  @moduledoc """
  Defines a `hex` struct to hold identicon image data.
  By default, its initial value is `:nil`.
  """

  defstruct seed: nil, color: nil, grid: nil, pixel_map: nil
end
