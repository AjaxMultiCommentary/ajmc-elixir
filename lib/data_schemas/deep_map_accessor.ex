defmodule DataSchemas.DeepMapAccessor do
  @behaviour DataSchema.DataAccessBehaviour

  @impl true
  def field(data, path) when is_list(path) do
    get_in(data, path)
  end

  def field(data, path) do
    Map.get(data, path)
  end

  @impl true
  def list_of(data, path) when is_list(path) do
    get_in(data, path)
  end

  def list_of(data, path) do
    Map.get(data, path)
  end

  @impl true
  def has_many(data, path) when is_list(path) do
    get_in(data, path)
  end

  def has_many(data, path) do
    Map.get(data, path)
  end

  @impl true
  def has_one(data, path) when is_list(path) do
    get_in(data, path)
  end

  def has_one(data, path) do
    Map.get(data, path)
  end
end
