defmodule YukiHelper.Docs do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def doc(), do: @moduledoc
    end
  end
end