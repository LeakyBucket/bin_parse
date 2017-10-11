defmodule Mps7Parse.Data do
  def breakdown(results) do
    results
    |> autopays
    |> credit_total
    |> debit_total
    |> balance_for(2456938384156277127)
  end

  def autopays(results) do
    starts = Enum.reduce(results.autopays, 0, fn rec, seen ->
      case rec.type do
        :start ->
          seen + 1
        _ ->
          seen
      end
    end)

    stops = Enum.reduce(results.autopays, 0, fn rec, seen ->
      case rec.type do
        :stop ->
          seen + 1
        _ ->
          seen
      end
    end)

    IO.puts "Autopay starts: #{starts}"
    IO.puts "Autopay stops: #{stops}"

    results
  end

  def credit_total(results) do
    credits = results.credits
              |> Enum.reduce(0.0, fn credit, total ->
                total + credit.amount
              end)

    IO.puts "Total credits: #{credits}"

    results
  end

  def debit_total(results) do
    debits = results.debits
             |> Enum.reduce(0.0, fn debit, total ->
               total + debit.amount
             end)

    IO.puts "Total debits: #{debits}"

    results
  end

  def balance_for(results, account) do
    black = Enum.reduce(results.credits, 0.0, fn credit, total ->
              case credit.account do
                ^account ->
                  total + credit.amount
                _ ->
                  total
              end
            end)

    red = Enum.reduce(results.debits, 0.0, fn debit, total ->
            case debit.account do
              ^account ->
                total + debit.amount
              _ ->
                total
            end
          end)

    IO.puts "Account #{account} has a balance of #{black - red}"
  end
end
