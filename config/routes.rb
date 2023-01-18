Rails.application.routes.draw do
  root "pages#show", defaults: { page: "home" }

  resources :public_authorities

  resources :users, only: %i[new edit index]

  resources :pa_users, only: %i[new edit index]

  scope "/user" do
    resources :user_steps, only: %i[edit update], path_names: { edit: "" }
  end

  scope "/pa_user" do
    resources :pa_user_steps, only: %i[edit update], path_names: { edit: "" }
  end

  patch "request/request_steps/:id/upload" => "request_steps#upload"
  patch "request/request_steps/:id/remove" => "request_steps#remove"
  get "request/submitted", to: "requests#submitted"
  get "requests/view/:id", to: "requests#view"
  get "dashboard", to: "requests#index"
  post "requests/reload/:id", to: "requests#reload"

  resources :requests # , only: %i[create index]

  resources :sau_requests, only: %i[show]
  get "sau_requests/view/:id", to: "sau_requests#view"

  scope "/sau_requests/:id" do
    resources :information_requests, only: %i[new create]
  end

  get "sau_requests/:id/report" => "report#edit"
  patch "sau_requests/:id/report_upload" => "report#report_upload"
  get "sau_requests/:id/report_confirm" => "report#report_confirm"
  post "sau_requests/:id/report_confirm_submit" => "report#report_confirm_submit"
  patch "sau_requests/:id/report_remove" => "report#remove"

  resources :call_in, only: %i[edit update], path_names: { edit: "" } do
    member do
      get "confirm"
      patch "remove"
      post "submit"
    end
  end

  resources :call_in_direction, only: %i[edit update], path_names: { edit: "" } do
    member do
      get "confirm"
      patch "remove"
      post "submit"
    end
  end

  resources :set_decision, only: %i[edit update], path_names: { edit: "" } do
    member do
      get "confirm"
      patch "remove"
      post "submit"
    end
  end

  scope "/request" do
    resources :request_steps, only: %i[edit update], path_names: { edit: "" }
  end

  resources :information_requests, only: %i[edit update], path_names: { edit: "" } do
    member do
      get "confirm"
      post "submit"
      patch "remove"
    end
  end

  resources :information_responses, only: %i[edit update], path_names: { edit: "" } do
    member do
      get "confirm"
      post "submit"
      patch "remove"
      get "summary"
    end
  end

  resource :account, only: %i[show edit update] do
    member do
      get "confirm"
      post "submit"
    end
  end

  resources :sau_dashboard, only: %i[index]

  get "/pages/:page", to: "pages#show"

  resource :cookies,
           path: "/about/cookies",
           path_names: { edit: "/" },
           only: %i[edit update create]

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all
end
