defmodule TextServerWeb.VersionLive.FormComponent do
  use TextServerWeb, :live_component

  alias TextServer.Languages
  alias TextServer.Versions

  alias TextServerWeb.Components
  alias TextServerWeb.Icons

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:version_file,
       accept: ~w(.docx .xml),
       max_entries: 1
     )
     |> assign(version_file_candidate: nil, work: nil)}
  end

  @impl true
  def update(%{version: version} = assigns, socket) do
    changeset = Versions.change_version(version)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"version" => version_params}, socket) do
    changeset =
      socket.assigns.version
      |> Versions.change_version(version_params)
      |> Map.put(:action, :validate)

    entries = socket.assigns.uploads.version_file.entries

    version_file_candidate =
      if Enum.count(entries) > 0 do
        Enum.fetch!(entries, 0)
      else
        nil
      end

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:version_file_candidate, version_file_candidate)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"version" => version_params, "selected_work" => work_params},
        socket
      ) do
    file_params =
      consume_uploaded_entries(
        socket,
        :version_file,
        fn %{path: path}, %{client_name: client_name} = _entry ->
          dir =
            Path.join([
              Application.get_env(:text_server, :user_uploads_directory, "uploads"),
              "version_files"
            ])

          dest =
            Path.join([
              dir,
              client_name
            ])

          file_body = File.read!(path)

          File.mkdir_p!(dir)
          File.cp!(path, dest)

          {:ok,
           %{
             "filename" => dest,
             "filemd5hash" => :crypto.hash(:md5, file_body) |> Base.encode16(case: :lower),
             "source" => "@@version/user_upload",
             "source_link" =>
               Routes.static_path(socket, "/uploads/version_files/#{Path.basename(dest)}")
           }}
        end
      )
      |> List.first()

    unless is_nil(file_params) do
      save_version(
        socket,
        socket.assigns.action,
        version_params
        |> Map.merge(file_params)
        |> Map.put("work_id", Map.get(work_params, "work_id"))
      )
    else
      {:noreply, socket}
    end
  end

  defp save_version(socket, :edit, version_params) do
    case Versions.update_version(
           socket.assigns.version,
           version_params
         ) do
      {:ok, _version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_version(socket, :new, version_params) do
    # see documentation for put_assoc/4 for why we're doing it this way
    language_slug = Map.get(version_params, "language") |> Map.get("title")
    language = Languages.get_language_by_slug(language_slug)

    case Versions.create_version(
           version_params |> Map.put("language_id", language.id) |> Map.delete("language"),
           socket.assigns.project
         ) do
      {:ok, _version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exemplar created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
