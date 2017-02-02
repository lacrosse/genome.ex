defmodule Genome.Sequence do
  alias Genome.Nucleotide

  def from_string(string), do: string |> to_charlist() |> Enum.map(&Nucleotide.encode/1)

  def pattern_count(seq, pattern, acc \\ 0)
  def pattern_count(seq, pattern, acc) when length(pattern) > length(seq), do: acc
  def pattern_count(seq, pattern, acc) do
    pattern_count(tl(seq), pattern, acc + (if Enum.take(seq, length(pattern)) == pattern, do: 1, else: 0))
  end

  def frequent_patterns(seq, k) do
    {patterns, _max_count} =
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

    patterns
  end

  def reverse_complement([]), do: []
  def reverse_complement([nucleotide|tail]),
    do: reverse_complement(tail) <> (nucleotide |> Nucleotide.decode() |> Nucleotide.reverse() |> Nucleotide.encode())

  def pattern_matches(seq, pattern, index \\ 0, acc \\ [])
  def pattern_matches(seq, pattern, _, acc) when length(pattern) > length(seq), do: acc
  def pattern_matches(seq, pattern, index, acc) do
    k = length(pattern)
    kmer = Enum.take(seq, k)
    new_acc = if kmer == pattern, do: [index|acc], else: acc
    pattern_matches(tl(seq), pattern, index + 1, new_acc)
  end

  def encode(seq), do: seq |> Integer.undigits(4)

  def decode(hash, k), do: hash |> Integer.digits(4) |> :string.right(k, 0)

  def frequencies(seq, k, acc \\ %{})
  def frequencies(seq, k, acc) do
    with kmer <- Enum.take(seq, k),
         ^k <- Enum.count(kmer) do
      frequencies(tl(seq), k, Map.update(acc, encode(kmer), 1, & &1 + 1))
    else
      _ -> acc
    end
  end

  def find_clumps(seq, k, window_size, saturation) do
    seq
    |> Stream.chunk(window_size, 1)
    |> Enum.map_reduce(nil, fn window, freqs_template ->
      freqs =
        case freqs_template do
          nil -> frequencies(window, k)
          value -> Map.update(value, encode(Enum.slice(window, window_size - k, k)), 1, & &1 + 1)
        end
      next_freqs = Map.update!(freqs, encode(Enum.slice(window, 0, k)), & &1 - 1)

      {freqs, next_freqs}
    end)
    |> elem(0)
    |> Stream.flat_map(& &1 |> Enum.filter_map(fn {_, v} -> v >= saturation end, fn {k, _} -> k end))
    |> Stream.uniq()
    |> Stream.map(&decode(&1, k))
    |> Enum.into(MapSet.new())
  end
end
