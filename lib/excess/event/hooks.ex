defmodule Excess.Event.Hooks do
  defmacro on(filter) do
    {match, guards} = :elixir_utils.extract_guards(filter)
    pattern = quote(do: event = unquote(match))

    head =
      for guard <- guards, reduce: pattern do
        head -> {:when, [], [head, guard]}
      end

    quote generated: true do
      fn
        unquote(head) ->
          {:ok, event}

        _ ->
          nil
      end
    end
  end
end
