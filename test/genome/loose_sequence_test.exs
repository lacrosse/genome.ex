defmodule Genome.LooseSequenceTest do
  use ExUnit.Case, async: true

  alias Genome.{LooseSequence, Sequence}

  doctest Genome.LooseSequence

  test "pattern_count small" do
    assert "AACAAGCTGATAAACATTTAAAGAG" |> Sequence.from_string() |> LooseSequence.pattern_count(Sequence.from_string("AAAAA"), 2) == 11
  end

  test "pattern_count" do
    [patstr, seqstr, dstr] = dataset("9_6") |> String.split()
    assert LooseSequence.pattern_count(Sequence.from_string(seqstr), Sequence.from_string(patstr), String.to_integer(dstr)) == 32
  end

  test "pattern_matches" do
    [patstr, seqstr, dstr] = dataset("9_4") |> String.split()
    assert LooseSequence.pattern_matches(Sequence.from_string(seqstr), Sequence.from_string(patstr), String.to_integer(dstr)) ==
      ~w|17299 17222 16209 15138 15094 14917 14771 14756 14231 13929 13548 13435 13099 12946 11717 10262 9554 9435
      9428 8992 8335 7898 7783 7429 7299 6897 6266 5761 5292 5217 4910 4830 4612 4254 4149 3705 3594 3306 178|
      |> Enum.map(&String.to_integer/1)
  end

  defp read_file(id), do: "datasets/#{id}.txt" |> Path.expand() |> File.read!()
  defp dataset(id), do: read_file("dataset_#{id}")
end
