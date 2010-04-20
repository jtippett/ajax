AJAX_ROOT = File.dirname(__FILE__)

%w[
  app/controllers/ajax_controller.rb
  app/views/ajax/framework.html.erb   
  config/initializers/ajax.rb   
  public/javascripts/ajax.js
  public/javascripts/jquery.address-1.2rc.js
  public/javascripts/jquery.address-1.2rc.min.js
  public/javascripts/jquery.json-2.2.min.js
  public/images/loading-icon-small.gif
].each do |file|
  if File.exist?(File.join(Rails.root, file))
    puts "skipped: #{file} exists!"
  else
    FileUtils.cp(File.join(AJAX_ROOT, file), File.join(Rails.root, file))
    puts "created: #{file}"
  end
end