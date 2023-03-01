defmodule ElixirIdenticon do
  @moduledoc """
  Identicon generator module.
  """
  require Logger

  @doc """
  Main pipeline. Handles converting a string to an identicon
  PNG image.
  """
  def main(input) do
    input
    |> hash_string
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Converts a string to a list of numeric values, by hashing it
  through the MD5 algorithm.
  """
  def hash_string(input) do
    seed = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %ElixirIdenticon.Image{seed: seed}
  end

  @doc """
  Takes the first three values of the seed stored inside an
  `ElixirIdenticon.Image` struct and stores them as an RGB
  tuple in a new struct.
  """
  def pick_color(%ElixirIdenticon.Image{seed: [r, g, b | _tail]} = image) do
    %ElixirIdenticon.Image{image | color: {r,g,b}}
  end

  @doc """
  Takes the seed stored in an `ElixirIdenticon.Image` struct and
  uses it to build a identicon grid of 5x5 squares.

  An identicon grid is represented by a list of tuples, where each
  tuple contains a numeric value and its index on the list. The
  list has a length of 25, accounting for the grid's 5x5 size.

  The grid is set into a new `ElixirIdenticon.Image` struct.
  """
  def build_grid(%ElixirIdenticon.Image{seed: seed} = image) do
    grid = seed
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(&mirror_grid_row/1)
    |> List.flatten
    |> Enum.with_index

    %ElixirIdenticon.Image{image | grid: grid}
  end

  @doc """
  Takes a grid row and mirrors the first two values to its end.

  A grid row is a numeric list of length five, where the last
  two values are mirrors of the first two.
  """
  def mirror_grid_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  @doc """
  Filters tuples with odd values out of the grid property in an
  `ElixirIdenticon.Image` struct. The filtered grid is saved to
  a new `ElixirIdenticon.Image` struct.
  """
  def filter_odd_squares(%ElixirIdenticon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %ElixirIdenticon.Image{image | grid: grid}
  end

  @doc """
  Builds a pixel map from a filtered grid inside an `ElixirIdenticon.
  Image` struct and parses it into a pixel map to be fed to Erlang's
  `egd` module functions.

  A pixel map is a list of tuples containing top left and bottom right
  coordinates for each colored square composing an identicon image.any()

  This function is hardcoded to build a pixel map considering 50px
  squares.
  """
  def build_pixel_map(%ElixirIdenticon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      p1_x_coordinate = rem(index, 5) * 50
      p1_y_coordinate = div(index, 5) * 50

      p1 = {p1_x_coordinate, p1_y_coordinate}
      p2 = {p1_x_coordinate + 50, p1_y_coordinate + 50}

      {p1, p2}
    end

    %ElixirIdenticon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Draws an emoticon image through Erlang's `egd` module.
  """
  def draw_image(%ElixirIdenticon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start_coordinates, stop_coordinates}) ->
      :egd.filledRectangle(image, start_coordinates, stop_coordinates, fill)
    end

    :egd.render(image)
  end

  @doc """
  Saves an identicon image to the filesystem.
  """
  def save_image(in_memory_image, filename) do
    File.write("#{File.cwd!}/outputs/#{filename}.png", in_memory_image)
  end
end
