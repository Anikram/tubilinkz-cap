Rails.application.routes.draw do
  # Переопределен контроллер регистраций для функционала проверки капчи
  devise_for :users, controllers: {registrations: 'registrations'}

  # пользователей можно только смотреть (остальное берет на себя Devise)
  resources :users, only: :show

  resources :links
  root to: 'pages#main'

  # В последнюю очередь ловим остальные урлы, как сокращенные ссылки
  get '*short_url', to: 'links#open', as: :shortlink
end
