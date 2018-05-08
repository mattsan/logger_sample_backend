defmodule LoggerSampleBackend do
  @behaviour :gen_event
  @path "./log/sample.log"
  @format "$date $time [$level] $message"

  def init(__MODULE__) do
    {:ok, %{path: @path, format: @format}}
  end

  def handle_call({:configure, opts}, state) do
    path = Keyword.get(opts, :path, @path)
    format = Keyword.get(opts, :format, @format)
    new_state = %{state | path: path, format: format}
    {:ok, {:ok, new_state}, new_state}
  end

  def handle_event({level, _group_leader, {Logger, message, timestamp, metadata}}, state) do
    state.path |> Path.dirname() |> File.mkdir_p()

    log_line =
      Logger.Formatter.format(
        Logger.Formatter.compile(state.format),
        level,
        message,
        timestamp,
        metadata
      )

    File.write(state.path, "#{log_line}\n", [:append])

    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_info({:io_reply, _, :ok}, state) do
    {:ok, state}
  end
end
