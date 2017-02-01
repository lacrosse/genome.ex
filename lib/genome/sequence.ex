defmodule Genome.Sequence do
  alias Genome.Nucleotide

  def pattern_count("", _), do: 0
  def pattern_count(seq, pattern) do
    pattern_size = String.length(pattern)
    case seq do
      <<^pattern::binary-size(pattern_size), tail::binary>> ->
        <<_, pre_tail::binary>> = pattern
        1 + pattern_count(pre_tail <> tail, pattern)
      <<_, tail::binary>> ->
        pattern_count(tail, pattern)
    end
  end

  def frequent_patterns(seq, k) do
    patterns = for i <- 0..String.length(seq) - k - 1, do: String.slice(seq, i, k)

    frequencies =
      patterns
      |> Enum.reduce(Map.new, fn pattern, freqs ->
        Map.put_new_lazy(freqs, pattern, fn -> pattern_count(seq, pattern) end)
      end)

    {_, top_frequency} =
      frequencies
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> Enum.at(0)

    frequencies
    |> Enum.filter_map(&elem(&1, 1) == top_frequency, &elem(&1, 0))
  end

  def faster_frequent_patterns(seq, k) do
    seq
    |> frequencies(k)
    |> Enum.reduce({[], 0}, fn
      {encoded_pattern, count}, {_, winning_count} when count > winning_count ->
        {[decode(encoded_pattern, k)], count}
      {encoded_pattern, count}, {patterns, count} ->
        {[decode(encoded_pattern, k)|patterns], count}
      _, acc ->
        acc
    end)
    |> elem(0)
  end

  def reverse_complement(""), do: ""
  def reverse_complement(<<nucleotide::binary-size(1), tail::binary>>),
    do: reverse_complement(tail) <> Nucleotide.reverse(nucleotide)

  def pattern_matches(seq, pattern), do: do_pattern_matches(seq, pattern, 0, [])

  def encode(seq, acc \\ "")
  def encode("", acc), do: acc |> String.to_integer(4)
  def encode(<<nucleotide::binary-1, tail::binary>>, acc),
    do: encode(tail, acc <> Integer.to_string(Nucleotide.encode(nucleotide)))

  def decode(hash, k) do
    hash
    |> Integer.to_string(4)
    |> String.pad_leading(k, "0")
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Nucleotide.decode/1)
    |> Enum.join()
  end

  def frequencies(seq, k, acc \\ %{})
  def frequencies(seq, k, acc) do
    with <<kmer::binary-size(k), _::binary>> <- seq do
      frequencies(String.slice(seq, 1..-1), k, Map.update(acc, encode(kmer), 1, & &1 + 1))
    else
      _ -> acc
    end
  end

  def find_clumps(seq, k, l, saturation) do
    seq
    |> to_charlist()
    |> Stream.chunk(l, 1)
    |> Stream.map(& &1 |> to_string() |> frequencies(k))
    |> Stream.flat_map(& &1 |> Enum.filter_map(fn {_, v} -> v >= saturation end, fn {k, _} -> k end))
    |> Stream.uniq
    |> Stream.map(&decode(&1, k))
  end

  defp do_pattern_matches("", _, _, acc), do: acc
  defp do_pattern_matches(seq, pattern, index, acc) do
    pattern_size = String.length(pattern)
    new_acc =
      case seq do
        <<^pattern::binary-size(pattern_size), _::binary>> -> [index|acc]
        _ -> acc
      end
    <<_, tail::binary>> = seq
    do_pattern_matches(tail, pattern, index + 1, new_acc)
  end
end
