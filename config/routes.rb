ActionController::Routing::Routes.draw do |map|
  map.resources :release_notes, :collection => {:update => :put}
end
