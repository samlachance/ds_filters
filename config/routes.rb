Rails.application.routes.draw do
  # This should probably be namespaced somehow. Maybe a version. But
  # I will need to involve the other devs in this decision.

  get '/asset_filters' => 'ds_filters/filters#assets'
  # get '/auction_filters' => 'ds_filters/filters#auctions'
end
