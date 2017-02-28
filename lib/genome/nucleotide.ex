defmodule Genome.Nucleotide do
  @all MapSet.new([0, 1, 2, 3])

  def all, do: @all

  def encode(?A), do: 0
  def encode(?C), do: 1
  def encode(?G), do: 2
  def encode(?T), do: 3

  def decode(0), do: ?A
  def decode(1), do: ?C
  def decode(2), do: ?G
  def decode(3), do: ?T

  def reverse(0), do: 3
  def reverse(1), do: 2
  def reverse(2), do: 1
  def reverse(3), do: 0
end
