defmodule GitHub.API do
  def get_commentaries_data! do
    base_req() |> Req.get!(url: "/contents")
  end

  def get_commentary_data!(tess_retrained_url) do
    commentary_data =
      Req.get!(tess_retrained_url)

    commentary_data.body |> Jason.decode!()
  end

  def get_image!(ajmc_id, image_id) do
    resp = base_req() |> Req.get!(url: "/contents/#{ajmc_id}/images/png/#{image_id}.png")

    resp.body["content"]
  end

  def get_tess_retrained_file!(ajmc_id) do
    resp = base_req() |> Req.get!(url: "/contents/#{ajmc_id}/canonical")
    files = resp.body

    Enum.find(files, fn file ->
      String.ends_with?(file["name"], "_tess_retrained.json")
    end)
  end

  def get_pytorch_file!(ajmc_id) do
    resp = base_req() |> Req.get!(url: "/contents/#{ajmc_id}/canonical")
    files = resp.body

    Enum.find(files, fn file ->
      Map.get(file, "name", "")
      |> String.ends_with?("_pytorch.json")
    end)
  end

  defp base_req do
    github_config = Application.get_env(:text_server, GitHub.API)

    Req.new(
      base_url: github_config[:base_url],
      auth: {:bearer, github_config[:token]},
      headers: [{"accept", "application/vnd.github+json"}, {"x-github-api-version", "2022-11-28"}]
    )
  end
end
