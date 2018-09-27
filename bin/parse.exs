alias Mps7Parse.Parser

parsed =
  "test/support/txnlog.dat"
  |> Path.expand()
  |> Parser.parse()

debit_total = Enum.reduce(parsed.debits(), 0, fn debit, total ->
                total + debit.amount()
              end)

IO.puts "Debit total: $#{Float.round(debit_total, 2)}"

credit_total = Enum.reduce(parsed.credits(), 0, fn credit, total ->
                 total + credit.amount()
               end)

IO.puts "Credit total: $#{Float.round(credit_total, 2)}"

{starts, stops} = Enum.reduce(parsed.autopays(), {0, 0}, fn autopay, {starts, stops} ->
                    case autopay.type() do
                      :start ->
                        {starts + 1, stops}
                      :stop ->
                        {starts, stops + 1}
                    end
                  end)

IO.puts "Autopays started: #{starts}"
IO.puts "Autopays stopped: #{stops}"

black = Enum.reduce(parsed.credits(), 0, fn credit, total ->
          case credit.account() do
            2456938384156277127 -> total + credit.amount()
            _ -> total
          end
        end)

red = Enum.reduce(parsed.debits(), 0, fn debit, total ->
        case debit.account() do
          2456938384156277127 -> total + debit.amount()
          _ -> total
        end
      end)

IO.puts "Balance for 2456938384156277127: $#{black - red}"
