AJAX_ROOT = File.dirname(__FILE__)

%w[
  config/initializers/ajax.rb 
  public/javascripts/ajax.js
  public/javascripts/jquery.address-1.2rc.js
  public/javascripts/jquery.address-1.2rc.min.js
  public/javascripts/jquery.json-2.2.min.js
  public/images/loading-icon-small.gif
].each do |file|
  if File.exist?(File.join(RAILS_ROOT, file))
    puts "already exists: #{file}, file not copied"
  else
    FileUtils.cp(File.join(AJAX_ROOT, file), File.join(RAILS_ROOT, file))
    puts "created: #{file}"
  end
end