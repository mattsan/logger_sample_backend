defmodule LoggerSampleBackendTest do
  use ExUnit.Case
  doctest LoggerSampleBackend

  test "greets the world" do
    assert LoggerSampleBackend.hello() == :world
  end
end
