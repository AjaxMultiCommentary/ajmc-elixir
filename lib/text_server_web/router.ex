defmodule TextServerWeb.Router do
  use TextServerWeb, :router

  import TextServerWeb.UserAuth
  import TextServerWeb.Plugs.API, only: [authenticate_api_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TextServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TextServerWeb.Plugs.API
  end

  scope "/api", TextServerWeb do
    pipe_through [:api]

    scope "/versions" do
      pipe_through [:authenticate_api_user]

      get "/:id/download", VersionController, :download
    end

    get "/:collection/:text_group/:work/:version", VersionController, :show
    get "/:collection/:text_group/:work/:version/lemmas", VersionController, :lemmas

    resources "/lemmaless_comments", LemmalessCommentController, except: [:new, :edit]
  end

  scope "/:locale", TextServerWeb do
    pipe_through :browser

    get "/", PageController, :home

    # these logged-out routes must come last, otherwise they
    # match on /{resource}/new
    live_session :default,
      on_mount: [
        {TextServerWeb.Locale, :set_locale},
        {TextServerWeb.UserAuth, :mount_current_user}
      ] do
      live "/bibliography", CommentariesLive.Index, :index
      live "/versions/:urn", VersionLive.Show, :show
    end
  end

  scope "/iiif", TextServerWeb do
    pipe_through :browser

    get "/:commentary_pid/*image", IiifController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:components, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TextServerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TextServerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TextServerWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", AccountLive.UserRegistrationLive, :new
      live "/users/log_in", AccountLive.UserLoginLive, :new
      live "/users/reset_password", AccountLive.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", AccountLive.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TextServerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TextServerWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", AccountLive.UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", AccountLive.UserSettingsLive, :confirm_email
    end
  end

  scope "/", TextServerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TextServerWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", AccountLive.UserConfirmationLive, :edit
      live "/users/confirm", AccountLive.UserConfirmationInstructionsLive, :new
    end
  end

  scope "/", TextServerWeb do
    pipe_through :browser

    get "/", PageController, :redirect_to_locale
    get "/versions/:urn", PageController, :redirect_to_locale
  end
end
