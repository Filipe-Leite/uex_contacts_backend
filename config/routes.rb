Rails.application.routes.draw do
  

  mount_devise_token_auth_for 'User', at: 'auth', controllers: {  
    registrations: 'overrides/registrations',
    confirmations: 'overrides/confirmations',
    passwords: 'overrides/passwords',
    token_validations: 'overrides/token_validations',
    sessions: 'overrides/sessions'
  }

  get '/contacts',                                           to: 'contacts#index'
  get '/search',                           to: 'search#index'
end
