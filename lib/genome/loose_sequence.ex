defmodule Genome.LooseSequence do
  alias Genome.Nucleotide

  import Genome.Sequence, only: [encode: 1, decode: 2, reverse_complement: 1]

  def pattern_count(seq, pattern, d), do: Enum.count(pattern_matches(seq, pattern, d))

  def pattern_matches(seq, pattern, d, index \\ 0, acc \\ [])
  def pattern_matches(seq, pattern, _, _, acc) when length(pattern) > length(seq), do: acc
  def pattern_matches(seq, pattern, d, index, acc) do
    k = length(pattern)
    kmer = Enum.take(seq, k)
    new_acc = if hamming_distance(kmer, pattern) <= d, do: [index | acc], else: acc
    pattern_matches(tl(seq), pattern, d, index + 1, new_acc)
  end

  def frequencies(seq, k, d, acc \\ %{}) do
    with kmer <- Enum.take(seq, k),
         ^k <- Enum.count(kmer) do
      new_acc =
        kmer
        |> neighbors(d)
        |> Enum.reduce(acc, fn neighbor, acc -> Map.update(acc, encode(neighbor), 1, & &1 + 1) end)
      frequencies(tl(seq), k, d, new_acc)
    else
      _ -> acc
    end
  end

  @doc """
  Finds the most frequent k-mers with mismatches in a sequence.

      iex> "ACGTTGCATGTCGCATGATGCATGAGAGCT"
      ...> |> Genome.Sequence.from_string()
      ...> |> Genome.LooseSequence.frequent_patterns(4, 1)
      ...> |> Enum.map(&Genome.Sequence.to_string/1)
      ...> |> MapSet.new()
      MapSet.new(~w|GATG ATGC ATGT|)
  """
  def frequent_patterns(seq, k, d) do
    {patterns, _} =
      seq
      |> frequencies(k, d)
      |> reduce_to_most_frequent(k)

    patterns
  end

  @doc """
  Finds the most frequent k-mers with mismatches and reverse complements in a sequence.

      iex> "ACGTTGCATGTCGCATGATGCATGAGAGCT"
      ...> |> Genome.Sequence.from_string()
      ...> |> Genome.LooseSequence.frequent_patterns_with_reverse_complements(4, 1)
      ...> |> Enum.map(&Genome.Sequence.to_string/1)
      ...> |> MapSet.new()
      MapSet.new(~w|ATGT ACAT|)
  """
  def frequent_patterns_with_reverse_complements(seq, k, d) do
    direct_freqs =
      seq
      |> frequencies(k, d)

    freqs =
      seq
      |> reverse_complement()
      |> frequencies(k, d, direct_freqs)

    {patterns, _} =
      freqs
      |> reduce_to_most_frequent(k)

    patterns
  end

  @doc """
      iex> "ACG"
      ...> |> Genome.Sequence.from_string()
      ...> |> Genome.LooseSequence.neighbors(1)
      ...> |> Enum.map(&Genome.Sequence.to_string/1)
      ...> |> MapSet.new()
      MapSet.new(~w|CCG TCG GCG AAG ATG AGG ACA ACC ACT ACG|)
  """
  def neighbors(seq, 0), do: MapSet.new([seq])
  def neighbors([_], _), do: Nucleotide.all() |> Enum.map(&[&1])
  def neighbors([head|tail], d) when d > 0 do
    tail
    |> neighbors(d)
    |> Enum.flat_map(fn neighbor ->
      if hamming_distance(neighbor, tail) < d,
      do: Nucleotide.all() |> Enum.map(& [&1|neighbor]),
      else: [[head|neighbor]]
    end)
    |> MapSet.new()
  end

  @doc """
      iex> Genome.LooseSequence.hamming_distance([0, 1, 2, 3, 2, 1, 0], [1, 2, 3, 3, 2, 1, 0])
      3
  """
  def hamming_distance(seq1, seq2) do
    Enum.zip(seq1, seq2)
    |> Enum.count(fn {a, b} -> a != b end)
  end

  defp reduce_to_most_frequent(freqs, k) do
    freqs
    |> Enum.reduce({[], 0}, fn
      {encoded_pattern, count}, {_, winning_count} when count > winning_count ->
        {MapSet.new([decode(encoded_pattern, k)]), count}
      {encoded_pattern, count}, {patterns, count} ->
        {MapSet.put(patterns, decode(encoded_pattern, k)), count}
      _, acc ->
        acc
    end)
  end
end
