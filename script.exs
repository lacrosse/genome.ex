[sequence|params] =
  File.read!("datasets/dataset_4_5.txt")
  |> String.split()

[k, l, t] = params |> Enum.map(&String.to_integer/1)

sequence
|> Genome.Sequence.find_clumps(k, l, t)
|> Enum.each(&IO.inspect/1)
