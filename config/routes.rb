Rails.application.routes.draw do
  match '/foo' => 'ds_filters/filters#foo'
end
