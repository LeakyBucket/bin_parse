defmodule Mps7Parse.Parser do
  use GenServer
  alias Mps7Parse.Record.Debit
  alias Mps7Parse.Record.Credit
  alias Mps7Parse.Record.Autopay

  @debit_marker 0x00
  @credit_marker 0x01
  @autopay_start 0x02
  @autopay_end 0x03

  defstruct [version: nil, debits: [], credits: [], autopays: [], expected: nil]

  def start_link() do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def parse(file) do
    {:ok, data_file} = File.open(file)

    GenServer.call __MODULE__, {:parse, data_file}
  end

  def handle_call({:parse, data_file}, _from, state) do
    {:reply, parse_data(IO.binread(data_file, :all), state), state}
  end

  def parse_data(data, state) do
    data
    |> check_magic
    |> case do
      {:ok, remaining_data} ->
        remaining_data
        |> get_version(state)
        |> get_count
        |> process_records
      {:error, :bad_magic} ->
        {:error, "Bad Header"}
    end
  end

  defp check_magic(<< "MPS7", rest::bitstring >>), do: {:ok, rest}
  defp check_magic(_), do: {:error, :bad_magic}

  defp get_version(<< version::8, rest::bitstring >>, state) do
    {rest, struct(state, version: version)}
  end

  defp get_count({<< record_count::32, rest::bitstring >>, state}) do
    {rest, struct(state, expected: record_count)}
  end

  defp process_records({data, state}) when bit_size(data) == 0, do: state
  defp process_records({<< @autopay_start, rest::bitstring >>, state}) do
    process_records add_autopay(:start, rest, state)
  end
  defp process_records({<< @autopay_end, rest::bitstring>>, state}) do
    process_records add_autopay(:stop, rest, state)
  end
  defp process_records({<< @debit_marker, rest::bitstring>>, state}) do
    process_records add_debit(rest, state)
  end
  defp process_records({<< @credit_marker, rest::bitstring>>, state}) do
    process_records add_credit(rest, state)
  end

  defp add_autopay(type, << _time::32, account::64, rest::bitstring>>, state) do
    record = %Autopay{account: account, type: type}

    {rest, struct(state, autopays: [record] ++ state.autopays)}
  end

  defp add_debit(<< _time::32, account::64, amount::float-size(64), rest::bitstring>>, state) do
    record = %Debit{account: account, amount: amount}

    {rest, struct(state, debits: [record] ++ state.debits)}
  end

  defp add_credit(<<_time::32, account::64, amount::float-size(64), rest::bitstring>>, state) do
    record = %Credit{account: account, amount: amount}

    {rest, struct(state, credits: [record] ++ state.credits)}
  end
end
