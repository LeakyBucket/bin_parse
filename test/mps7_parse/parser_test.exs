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

  test "parsing a good file" do

  end
end
