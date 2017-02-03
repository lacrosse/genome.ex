defmodule Genome.SequenceTest do
  use ExUnit.Case, async: true

  alias Genome.{Sequence, Nucleotide}

  doctest Genome.Sequence

  test "encode" do
    [seq_string] = dataset("3010_2") |> String.split()

    assert seq_string |> Sequence.from_string() |> Sequence.encode() == 407127899
  end

  test "decode" do
    [hash, k] = dataset("3010_5") |> String.split()
    k = k |> String.to_integer()

    assert hash |> String.to_integer() |> Sequence.decode(k) |> Enum.map(&Nucleotide.decode/1) == 'AAGAAGCGC'
  end

  test "pattern_count" do
    [seq_string, pattern_string] = dataset("2_7") |> String.split()
    pattern = pattern_string |> Sequence.from_string()

    assert seq_string |> Sequence.from_string() |> Sequence.pattern_count(pattern) == 33
  end

  test "frequent_patterns" do
    [string, k] = dataset("2_10") |> String.split()
    k = k |> String.to_integer()

    assert string |> Sequence.from_string() |> Sequence.frequent_patterns(k) |> MapSet.new() ==
      ~w|GTTCCGACGTTCCG CGTTCCGACGTTCC TTCCGACGTTCCGA|c
      |> Enum.map(&Sequence.from_string/1) |> MapSet.new()
  end

  test "pattern_matches" do
    [pattern_string, seq_string] = dataset("3_5") |> String.split()
    pattern = pattern_string |> Sequence.from_string()

    assert seq_string |> Sequence.from_string() |> Sequence.pattern_matches(pattern) ==
      ~w|8200 8169 8082 8075 8068 8061 8025 8008 7975 7968 7943
      7906 7899 7889 7882 7826 7807 7773 7708 7701 7676 7467 7433 7407 7391 7375 7347 7340 7277 7257 7218 7210 7203
      7179 7138 7111 7084 7073 7066 7059 7042 7005 6952 6924 6865 6838 6792 6763 6686 6650 6613 6596 6588 6491 6447
      6440 6433 6426 6381 6338 6304 6286 6271 6264 6224 6217 6200 6142 6135 6111 6104 6097 6090 6056 6049 6042 6035
      6028 5981 5952 5945 5922 5915 5907 5885 5874 5848 5831 5786 5742 5647 5640 5597 5554 5457 5379 5371 5364 5356
      5321 5278 5241 5234 5225 5185 5076 5040 5021 4981 4933 4883 4875 4767 4760 4697 4682 4660 4614 4607 4555 4548
      4509 4492 4485 4478 4471 4464 4457 4450 4443 4388 4372 4365 4358 4301 4255 4226 4205 4197 4189 4123 4116 4076
      4026 3957 3908 3901 3893 3840 3833 3826 3811 3804 3768 3754 3721 3624 3606 3574 3567 3515 3491 3448 3406 3378
      3348 3292 3264 3257 3190 3131 2993 2977 2957 2915 2864 2845 2778 2770 2731 2724 2700 2671 2636 2629 2594 2564
      2557 2534 2519 2456 2415 2397 2358 2332 2324 2317 2213 2197 2190 2126 2071 2031 1983 1966 1951 1943 1913 1893
      1796 1776 1728 1711 1646 1607 1591 1556 1525 1517 1509 1501 1470 1463 1403 1380 1289 1263 1256 1238 1231 1223
      1182 1174 1167 1136 1115 1099 1024 939 932 925 918 911 798 791 784 764 717 681 674 667 649 642 635 627 620
      613 606 599 555 548 478 404 374 367 325 274 267 221 212 155 96 52 45 38 17| |> Enum.map(&String.to_integer/1)
  end

  test "frequencies" do
    [string, k] = dataset("2994_5") |> String.split()
    k = k |> String.to_integer()

    expected = %{
      462 => 2, 513 => 1, 500 => 1, 105 => 1, 313 => 4, 484 => 1, 888 => 2, 635 => 3, 230 => 2, 626 => 1, 921 => 1,
      343 => 1, 205 => 1, 962 => 3, 727 => 1, 333 => 3, 913 => 1, 762 => 1, 164 => 1, 851 => 1, 821 => 1, 957 => 2,
      83 => 3, 265 => 1, 958 => 1, 784 => 1, 658 => 2, 725 => 2, 803 => 2, 372 => 1, 928 => 1, 806 => 1, 480 => 3,
      838 => 1, 866 => 4, 811 => 1, 178 => 2, 938 => 2, 181 => 1, 676 => 2, 565 => 2, 759 => 1, 154 => 1, 624 => 1,
      600 => 1, 794 => 1, 139 => 1, 721 => 1, 1001 => 1, 578 => 1, 679 => 1, 897 => 1, 141 => 2, 607 => 1, 799 => 1,
      306 => 1, 715 => 1, 212 => 1, 652 => 1, 890 => 1, 697 => 1, 288 => 1, 997 => 1, 563 => 3, 594 => 1, 819 => 2,
      75 => 1, 81 => 1, 871 => 1, 747 => 1, 802 => 1, 638 => 1, 983 => 1, 873 => 1, 675 => 2, 242 => 1, 1017 => 2,
      404 => 1, 765 => 1, 559 => 1, 895 => 1, 894 => 1, 583 => 1, 303 => 1, 503 => 1, 616 => 1, 495 => 3, 438 => 1,
      926 => 2, 332 => 3, 20 => 1, 612 => 2, 1007 => 1, 109 => 3, 380 => 1, 984 => 2, 165 => 1, 699 => 2, 286 => 1,
      553 => 1, 111 => 1, 643 => 1, 867 => 1, 395 => 2, 785 => 2, 305 => 3, 420 => 1, 889 => 1, 345 => 1, 376 => 3,
      25 => 1, 307 => 2, 298 => 1, 595 => 3, 618 => 1, 65 => 1, 436 => 1, 590 => 1, 863 => 1, 950 => 1, 501 => 1,
      13 => 1, 649 => 2, 773 => 2, 191 => 1, 637 => 1, 502 => 1, 964 => 1, 143 => 1, 455 => 3, 44 => 2, 1008 => 1,
      820 => 1, 916 => 1, 196 => 2, 961 => 1, 162 => 1, 797 => 1, 207 => 3, 283 => 3, 279 => 1, 562 => 1, 604 => 2,
      852 => 2, 610 => 1, 244 => 1, 231 => 2, 798 => 1, 518 => 1, 85 => 1, 945 => 2, 221 => 2, 826 => 1, 398 => 1,
      497 => 1, 76 => 2, 718 => 1, 995 => 1, 69 => 2, 596 => 1, 37 => 1, 421 => 1, 267 => 1, 935 => 1, 379 => 1,
      84 => 1, 617 => 1, 937 => 2, 893 => 3, 946 => 1, 266 => 1, 908 => 1, 354 => 1, 156 => 1, 338 => 1, 478 => 2,
      790 => 1, 3 => 1, 767 => 1, 479 => 3, 222 => 1, 887 => 1, 348 => 1, 119 => 1, 449 => 1, 788 => 2, 753 => 1,
      454 => 2, 426 => 2, 55 => 1, 829 => 1, 158 => 1, 568 => 1, 636 => 3, 49 => 1, 140 => 2, 152 => 1, 201 => 1,
      177 => 1, 653 => 1, 334 => 2, 198 => 1, 489 => 1, 180 => 1, 990 => 1, 510 => 1, 41 => 1, 474 => 2, 943 => 1,
      472 => 1, 796 => 1, 326 => 1, 87 => 1, 168 => 2, 668 => 1, 394 => 3, 746 => 2, 680 => 1, 1014 => 1, 42 => 1,
      814 => 1, 777 => 2, 189 => 1, 233 => 1, 120 => 1, 350 => 4, 834 => 2, 989 => 1, 584 => 1, 567 => 2, 585 => 1,
      316 => 1, 791 => 2, 1000 => 1, 113 => 2, 393 => 1, 204 => 2, 574 => 1, 839 => 1, 881 => 2, 371 => 2, 208 => 1,
      123 => 1, 437 => 2, 712 => 2, 19 => 1, 418 => 1, 632 => 2, 954 => 1, 698 => 2, 250 => 3, 988 => 3, 678 => 1,
      724 => 1, 924 => 1, 247 => 1, 116 => 1, 95 => 1, 673 => 1, 580 => 1, 281 => 1, 128 => 1, 552 => 1, 406 => 2,
      633 => 2, 498 => 1, 179 => 1, 805 => 2, 101 => 1, 587 => 1, 276 => 1, 644 => 1, 861 => 1, 708 => 2, 912 => 1,
      268 => 1, 555 => 1, 494 => 1, 751 => 1, 523 => 1, 582 => 2, 855 => 2, 148 => 2, 5 => 1, 203 => 1, 391 => 1,
      227 => 1, 615 => 1, 240 => 1, 482 => 3, 461 => 1, 830 => 2, 657 => 1, 423 => 1, 496 => 2, 681 => 2, 61 => 1,
      103 => 1, 849 => 1, 663 => 3, 882 => 1, 508 => 1, 778 => 1, 910 => 1, 787 => 2, 662 => 1, 905 => 1, 456 => 1,
      310 => 2, 914 => 1, 904 => 2, 458 => 1, 605 => 2, 21 => 2, 909 => 1, 215 => 2, 970 => 1, 810 => 1, 670 => 2,
      414 => 2, 812 => 1, 922 => 1, 527 => 1, 949 => 1, 335 => 1, 369 => 4, 509 => 1, 588 => 1, 599 => 1, 832 => 1,
      748 => 2, 403 => 1, 256 => 1, 100 => 1, 291 => 1, 301 => 1, 206 => 1, 487 => 2, 723 => 1, 447 => 1, 860 => 2,
      339 => 2, 353 => 1, 187 => 1, 88 => 1, 999 => 2, 77 => 2, 260 => 1, 793 => 1, 541 => 1, 407 => 1, 703 => 1,
      277 => 1, 171 => 1, 711 => 1, 325 => 1, 382 => 1, 341 => 3, 531 => 1, 1015 => 2, 933 => 2, 153 => 2, 237 => 2,
      572 => 1, 213 => 1, 92 => 1, 330 => 2, 630 => 1, 825 => 1, 754 => 1, 299 => 1, 729 => 2, 978 => 1, 911 => 1,
      965 => 1, 557 => 1, 981 => 2, 464 => 1, 927 => 3, 1021 => 1, 659 => 1, 274 => 1, 795 => 1, 401 => 2, 869 => 1,
      686 => 2, 93 => 1, 569 => 1, 886 => 2, 492 => 1, 127 => 1, 551 => 2, 556 => 1, 683 => 1, 757 => 2, 375 => 3,
      336 => 1, 766 => 1, 827 => 2, 621 => 1, 357 => 3, 216 => 2, 383 => 1, 666 => 1, 853 => 1, 151 => 1, 840 => 1,
      323 => 1, 284 => 1, 197 => 1, 956 => 2, 547 => 2, 228 => 2, 976 => 1, 874 => 1, 465 => 1, 627 => 1, 405 => 1,
      223 => 2, 159 => 1, 898 => 1, 38 => 2, 505 => 1, 601 => 2, 155 => 1, 174 => 3, 342 => 1, 453 => 3, 507 => 1,
      295 => 1, 483 => 2, 917 => 1, 969 => 2, 311 => 2, 1002 => 2, 846 => 1, 550 => 2, 504 => 1, 415 => 1, 309 => 1,
      741 => 1
    }

    assert string |> Sequence.from_string() |> Sequence.frequencies(k) == expected
  end

  test "clumps" do
    [string|params] = dataset("4_5") |> String.split()
    [k, l, t] = params |> Enum.map(&String.to_integer/1)

    expected =
      ~w|CCAGTCTTAC CGAACGGAGC ACGGATTTTA AGACTCAAAA AGGGCTAAAA TGGCTGCAGT TTCGGGGTAC GCCGATAGGT|
      |> Enum.map(&Sequence.from_string/1)
      |> Enum.map(&Sequence.encode/1)
      |> MapSet.new()

    assert string |> Sequence.from_string() |> Sequence.clumps(k, l, t) == expected
  end

  @tag timeout: 180_000
  @tag skip: true
  test "clumps in E. coli" do
    seq = stream_file("E_coli") |> Stream.flat_map(&to_charlist/1) |> Sequence.from_enumerable()

    assert seq |> Sequence.clumps(9, 500, 3) |> MapSet.size == 1904
  end

  test "skews" do
    seq = "GAGCCACCGCGATA" |> Sequence.from_string()

    assert seq |> Sequence.skews() == [0, 1, 1, 2, 1, 0, 0, -1, -2, -1, -2, -1, -1, -1, -1]
  end

  test "minimum_skews" do
    [string] = dataset("7_6") |> String.split()

    assert string |> Sequence.from_string() |> Sequence.minimum_skews() == [197, 198, 38898, 38899]
  end

  test "hamming_distance" do
    [str1, str2] = dataset("9_3") |> String.split()

    assert Sequence.hamming_distance(Sequence.from_string(str1), Sequence.from_string(str2)) == 789
  end

  test "approximate_pattern_matches" do
    [patstr, seqstr, dstr] = dataset("9_4") |> String.split()
    assert Sequence.approximate_pattern_matches(Sequence.from_string(seqstr), Sequence.from_string(patstr), String.to_integer(dstr)) ==
      ~w|17299 17222 16209 15138 15094 14917 14771 14756 14231 13929 13548 13435 13099 12946 11717 10262 9554 9435
      9428 8992 8335 7898 7783 7429 7299 6897 6266 5761 5292 5217 4910 4830 4612 4254 4149 3705 3594 3306 178|
      |> Enum.map(&String.to_integer/1)
  end

  test "approximate_pattern_count small" do
    assert "AACAAGCTGATAAACATTTAAAGAG" |> Sequence.from_string() |> Sequence.approximate_pattern_count(Sequence.from_string("AAAAA"), 2) == 11
  end

  test "approximate_pattern_count" do
    [patstr, seqstr, dstr] = dataset("9_6") |> String.split()
    assert Sequence.approximate_pattern_count(Sequence.from_string(seqstr), Sequence.from_string(patstr), String.to_integer(dstr)) == 32
  end

  defp read_file(id), do: "datasets/#{id}.txt" |> Path.expand() |> File.read!()
  defp stream_file(id), do: "datasets/#{id}.txt" |> Path.expand() |> File.stream!([], 10240)
  defp dataset(id), do: read_file("dataset_#{id}")
end
