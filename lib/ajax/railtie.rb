module SitemapGenerator
  class Railtie < Rails::Railtie
    rake_tasks do
      load(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tasks', 'ajax_tasks.rake')))
    end
  end
end