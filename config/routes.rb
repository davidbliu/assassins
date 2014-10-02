Dockernotes::Application.routes.draw do
  resources :notes
  resources :games
  root 'game#index'
  get "/complete_assignment/:assignment_id", to: "game#complete_assignment"
  get "/complete_reverse_assignment/:assignment_id", to: "game#complete_reverse_assignment"

  get '/game_settings', to: 'game#game_settings'
  post '/re_ring', to: 'game#re_ring' # params ring?
  get '/do_storm', to: 'game#do_storm'

  # wtf does confirm do?
  get "/confirm_kill", to: "game#confirm_kill"
  get "/confirm_reverse_kill", to: "game#confirm_reverse_kill"
  get "/view_assignment/:player_id", to: "game#view_assignment"

  get "/assignments", to: 'game#assignments'

  get "/generate_assignments", to: "game#generate_assignments"

  get "/convert_reverse_kills", to: "game#convert_reverse_kills"
  get "/testing", to: "game#testing"

  get "/remove_player_from_game", to:"game#remove_player_from_game"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
