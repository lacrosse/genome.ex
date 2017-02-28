defmodule Genome.Sequence do
  alias Genome.Nucleotide

  def from_enumerable(stream), do: stream |> Enum.map(&Nucleotide.encode/1)

  def from_string(string), do: string |> to_charlist() |> from_enumerable()

  def to_string(seq), do: seq |> Enum.map(&Nucleotide.decode/1) |> Kernel.to_string()

  def encode(seq), do: seq |> Integer.undigits(4)

  def decode(hash, k), do: hash |> Integer.digits(4) |> :string.right(k, 0)

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
          {MapSet.new([decode(encoded_pattern, k)]), count}
        {encoded_pattern, count}, {patterns, count} ->
          {MapSet.put(patterns, decode(encoded_pattern, k)), count}
        _, acc ->
          acc
      end)

    patterns
  end

  def reverse_complement(seq), do: seq |> Enum.map(&Nucleotide.reverse/1) |> Enum.reverse()

  def pattern_matches(seq, pattern, index \\ 0, acc \\ [])
  def pattern_matches(seq, pattern, _, acc) when length(pattern) > length(seq), do: acc
  def pattern_matches(seq, pattern, index, acc) do
    k = length(pattern)
    kmer = Enum.take(seq, k)
    new_acc = if kmer == pattern, do: [index | acc], else: acc
    pattern_matches(tl(seq), pattern, index + 1, new_acc)
  end

  def frequencies(seq, k, acc \\ %{}) do
    with kmer <- Enum.take(seq, k),
         ^k <- Enum.count(kmer) do
      frequencies(tl(seq), k, Map.update(acc, encode(kmer), 1, & &1 + 1))
    else
      _ -> acc
    end
  end

  def clumps(seq, k, window_size, saturation) do
    seq
    |> Stream.chunk(window_size, 1)
    |> Stream.map(& &1 |> :array.from_list())
    |> Enum.reduce({MapSet.new(), nil}, fn window, {patterns, freqs_template} ->
      {freqs, candidate_freqs} =
        case freqs_template do
          nil ->
            with freqs = frequencies(window |> :array.to_list(), k),
                 do: {freqs, freqs}
          value ->
            with encoded_last_kmer = window |> array_slice(window_size - k..window_size - 1) |> encode(),
                 freqs = Map.update(value, encoded_last_kmer, 1, & &1 + 1),
                 do: {freqs, [{encoded_last_kmer, Map.get(freqs, encoded_last_kmer)}]}
        end
      new_patterns =
        candidate_freqs
        |> Enum.filter_map(
          fn {_, freq} -> freq >= saturation end,
          fn {pattern, _} -> pattern end
        )
        |> Enum.into(MapSet.new())
        |> MapSet.union(patterns)

      {_, next_freqs} =
        freqs
        |> Map.get_and_update!(window |> array_slice(0..k - 1) |> encode, &(if &1 == 1, do: :pop, else: {nil, &1 - 1}))

      {new_patterns, next_freqs}
    end)
    |> elem(0)
  end

  def skews(seq) do
    seq
    |> Enum.reduce([0], fn
      1, [prev | skews] -> [prev - 1, prev | skews]
      2, [prev | skews] -> [prev + 1, prev | skews]
      _, [prev | skews] -> [prev, prev | skews]
    end)
    |> Enum.reverse()
  end

  def minimum_skews(seq) do
    seq
    |> skews()
    |> Enum.with_index()
    |> Enum.sort()
    |> Enum.reduce_while(nil, fn
      {skew, index}, nil ->
        {:cont, {skew, [index]}}
      {skew, index}, {skew, acc} ->
        {:cont, {skew, [index | acc]}}
      _, {_, acc} ->
        {:halt, Enum.reverse(acc)}
    end)
  end

  defp array_slice(array, range) do
    range |> Enum.map(&:array.get(&1, array))
  end
end
