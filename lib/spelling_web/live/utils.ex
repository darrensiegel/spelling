defmodule SpellingWeb.Utils do
  def rewarded?(in_a_row) do
    cond do
      MapSet.new([3, 5, 10]) |> MapSet.member?(in_a_row) -> True
      in_a_row < 3 -> False
      Enum.random(1..7) == 1 -> True
      true -> False
    end
  end
end
