defmodule Population.API.Test do

  use ExUnit.Case, async: true
  import Population.API

  test "Returns a handled response given a proper path" do
    response = fetch_data("countries")
    assert {:ok, _} = response
  end

  test "Returns a handled response given a improper path" do
    response = fetch_data("nonsensepath")
    assert {:error, _} = response
  end

  test "Handles the reply back to the client based on a succesful response" do
    response = {:ok, %{"bar" => :foo, "foo" => :bar}}
    reply = {:reply, {:ok, %{bar: :foo, foo: :bar}}, %{bar: :foo, foo: :bar}}
    assert handle_reply(response, %{}) == reply
  end

  test "Handles the reply back to the client based on an unsuccessful response" do
    state = %{bar: :foo, foo: :bar}
    response = {:error, "reason"}
    reply = {:reply, response, state}
    assert handle_reply(response, state) == reply
  end

  test "Handles explicitely the reply back to the client based on a succesful response" do
    response = {:ok, %{"bar" => :foo, "foo" => :bar}}
    reply = {:reply, %{bar: :foo, foo: :bar}, %{bar: :foo, foo: :bar}}
    assert handle_reply!(response) == reply
  end

  test "Raises an exception when an unsuccessful response is retrieved" do
    response = {:error, "reason"}
    try do
      handle_reply!(response)
    rescue
      error ->
        assert error.message == "reason"
    end
  end
end
