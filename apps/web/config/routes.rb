# Configure your routes here
# See: https://guides.hanamirb.org/routing/overview
#
# Example:
# get '/hello', to: ->(env) { [200, {}, ['Hello from Hanami!']] }
get '/', to: 'home#index', name: :home
post '/graph', to: 'graph#create', name: :create_graph
post '/feats', to: 'feats#create', name: :create_feats
get '/feat/:id', to: 'feat#show', name: :feat
get '/feats', to: 'feats#index', name: :feats
get '/graph', to: 'graph#show', name: :download_graph
