defmodule LoggerSampleBackend do
  @moduledoc """
  Logger の backend の実装のサンプルです。

  詳細は Elixir の `Logger` のドキュメントを参照してください。
  """

  @behaviour :gen_event
  @path "./log/sample.log"
  @format "$date $time [$level] $message"

  @doc """
  初期化。

  config ファイル (`config/config.exs` など）で設定するか、実行時に `Logger.add_backend/1` で設定します。

  ##### config ファイルでの設定

  ```elixir
  config :logger,
    backends: [LoggerSampleBackend]
  ```

  ##### 実行時の設定

  ```elixir
  Logger.add_backend(LoggerSampleBackend)
  ```
  """
  def init(__MODULE__) do
    {:ok, %{path: @path, format: @format}}
  end

  @doc """
  実行時の設定の変更。


  `Logger.configure_backend/2` で設定を変更します。

  - `:path` 出力先のログファイルのパス。
  - `:format` 出力するログの形式。形式の内容については `Logger.Formatter` を参照してください。

  ```elixir
  Logger.configure_backend(LoggerSampleBackend,
    path: "./log/development.log",
    format: "$date $time [$level] $message"
  )
  ```
  """
  def handle_call({:configure, opts}, state) do
    path = Keyword.get(opts, :path, @path)
    format = Keyword.get(opts, :format, @format)
    new_state = %{state | path: path, format: format}
    {:ok, {:ok, new_state}, new_state}
  end

  @doc """
  ログ出力。

  ログ出力が実行された時に起動します。
  通知されるログ情報を `:format` で指定された形式で変換し `:path` で指定されたファイルに出力します。
  """
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

  @doc """
  フラッシュ。

  `Logger.flush/0` が実行されたときに起動します。
  ここでは特別な処理は実行していません。
  """
  def handle_event(:flush, state) do
    {:ok, state}
  end

  @doc """
  `:io_reply` のハンドリング。

  デフォルトの backend である `:console` と一緒に利用すると [I/O Protocol](http://erlang.org/doc/apps/stdlib/io_protocol.html) の応答のメッセージが送られてくるようです。
  そのメッセージを受け流すためにハンドリングしています。詳細は学習中。
  """
  def handle_info({:io_reply, _, :ok}, state) do
    {:ok, state}
  end
end
