defmodule Mps7Parse.ParserTest do
  use ExUnit.Case
  alias Mps7Parse.Parser

  @bogus_file Path.expand("test/support/bad_head.dat")
  @good_file Path.expand("test/support/txnlog.dat")

  test "reporting a bad Magic 'Number'" do
    assert {:error, "Bad Header"} = Parser.parse(@bogus_file)
  end

  test "parsing the version" do
    assert 1 = Parser.parse(@good_file).version
  end

  test "parsing the record count" do
    assert 71 = Parser.parse(@good_file).expected
  end

  describe "parsing a good file" do
    test "it finds 18 autopays" do
      autopay_count =
        Parser.parse(@good_file).autopays
        |> Enum.count()

      assert 18 = autopay_count
    end

    test "it finds 36 debits" do
      debit_count =
        Parser.parse(@good_file).debits
        |> Enum.count()

      assert 36 = debit_count
    end

    test "it finds 18 credits" do
      credit_count =
        Parser.parse(@good_file).credits
        |> Enum.count()

      assert 18 = credit_count
    end
  end
end
