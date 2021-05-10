defmodule YukiHelper do
  @moduledoc """
  Documentation for YukiHelper.
  """

  @type message() :: String.t()
  @type invalid_type :: :invalid_arguments | :invalid_option
  @type arguments() :: list(:integer | :string)
  @type options() :: {keyword(), list()} | []
  @type invalid_options() :: {invalid_type, message()}

  use Application

  def start(_type, _args) do
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end
  
  def success(str), do: IO.ANSI.green() <> str <> IO.ANSI.reset()
  def warning(str), do: IO.ANSI.yellow() <> str <> IO.ANSI.reset()
  def error(str), do: IO.ANSI.red() <> str <> IO.ANSI.reset()

  @doc """
  Parses common options.
  """
  @spec parse_options(list(), arguments(), keyword()) :: options() | invalid_options()
  def parse_options(argv, arguments, switches) do
    case OptionParser.parse(argv, strict: switches) do
      {_opts, _argv, [switch | _] = _invalid} ->
        {
          :invalid_option,
          "Invalid option: " <> (fn
            {name, nil} -> name
            {name, val} -> name <> "=" <> val
          end).(switch)
        }
      {[version: true], [], []} ->
        :version
      {opts, argv, []} when length(argv) == length(arguments) ->
        argv = parse_args(argv, arguments)
        if Enum.find_value(argv, &(&1 == :error)) do
          {:invalid_arguments, "Invalid arguments"}
        else
          {opts, argv}
        end
      {[], [], []} ->
        :help
      _ ->
        {:invalid_arguments, "Invalid arguments"}
    end
  end

  defp parse_args([], []), do: []
  defp parse_args([v | args0], [:string | args1]),
    do: [v | parse_args(args0, args1)]
  defp parse_args([v | args0], [:integer | args1]) do
    case Integer.parse(v) do
      {value, ""} ->
        [value | parse_args(args0, args1)]
      _ ->
        [:error]
    end
  end
end
