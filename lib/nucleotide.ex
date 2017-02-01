defmodule Genome.Nucleotide do
  def reverse("A"), do: "T"
  def reverse("C"), do: "G"
  def reverse("G"), do: "C"
  def reverse("T"), do: "A"

  def encode("A"), do: 0
  def encode("C"), do: 1
  def encode("G"), do: 2
  def encode("T"), do: 3

  def decode(0), do: "A"
  def decode(1), do: "C"
  def decode(2), do: "G"
  def decode(3), do: "T"
end
