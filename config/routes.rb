Anznn::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "user_registers", :passwords => "user_passwords"} do
    get "/users/profile", :to => "user_registers#profile" #page which gives options to edit details or change password
    get "/users/edit_password", :to => "user_registers#edit_password" #allow users to edit their own password
    put "/users/update_password", :to => "user_registers#update_password" #allow users to edit their own password
  end

  resources :responses, :only => [:new, :create, :edit, :update, :show] do
    member do
      get :review_answers
      post :submit
    end
    collection do
      get :stats
      get :prepare_download
      get :download
      get :batch_delete
      get :submitted_baby_codes
      put :confirm_batch_delete
      put :perform_batch_delete
    end
  end

  resources :configuration_items, :only => [] do
    collection do
      get :edit_year_of_registration
      put :update_year_of_registration
    end
  end

  resources :batch_files, :only => [:new, :create, :index] do
    member do
      get :summary_report
      get :detail_report
      post :force_submit
    end
  end

  resource :pages do
    get :home
  end

  namespace :admin do
    resources :users, :only => [:show, :index] do

        collection do
          get :access_requests
        end

        member do
          put :reject
          put :reject_as_spam
          put :deactivate
          put :activate
          get :edit_role
          put :update_role
          get :edit_approval
          put :approve

        end
      end

  end

  root :to => "pages#home"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
