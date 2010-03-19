ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'ajax' do |ajax|
    ajax.framework  ':controller/framework', :action => 'framework'
  end
end