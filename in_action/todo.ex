defmodule TodoList do
    
end

defmodule TodoList.CsvImporter do
    def import(file) do
        File.stream!(file)
        |> Stream.map(fn line -> 
            String.replace(line, "\n", "")
            |> String.replace(" ", "")
            end)
        |> Stream.map(fn line -> 
            [date, title] = String.split(line, ",", trim: true)
            [year, month, date] = String.split(date,"/", trim: true)
            {{String.to_integer(year), String.to_integer(month), String.to_integer(date)}, title}
            end)
        |> Enum.map(fn entry -> 
            {{year, month, date}, title} = entry
            {_, d} = Date.new(year, month, date)
            %{date: d, title: title}
            end)
    end
end