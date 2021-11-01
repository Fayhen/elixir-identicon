defmodule ElixirIdenticon do
  @moduledoc """
  Documentation for `ElixirIdenticon`.
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %ElixirIdenticon.Image{hex: hex}
  end

  def pick_color(%ElixirIdenticon.Image{hex: [r, g, b | _tail]} = image) do
    %ElixirIdenticon.Image{image | color: {r, g, b}}
  end

  def build_grid(%ElixirIdenticon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%ElixirIdenticon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({ hex, _index } = _square) ->
      rem(hex, 2) == 0
    end

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def build_pixel_map(%ElixirIdenticon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_hex, index}) ->
      start_pos_x = rem(index, 5) * 50
      start_pos_y = div(index, 5) * 50

      coordinates_top_left = {start_pos_x, start_pos_y}
      coordinates_bottom_right = {start_pos_x + 50, start_pos_y + 50}

      {coordinates_top_left, coordinates_bottom_right}
    end

    %ElixirIdenticon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%ElixirIdenticon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start_coordinates, stop_coordinates}) ->
      :egd.filledRectangle(image, start_coordinates, stop_coordinates, fill)
    end

    :egd.render(image)
  end

  def save_image(in_memory_image, filename) do
    # File.mkdir(Path.dirname("/outputs"))
    File.write("#{File.cwd!}/outputs/#{filename}.png", in_memory_image)
  end
end
