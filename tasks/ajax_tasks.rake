require 'ajax'

namespace :ajax
  desc "Install required Ajax files."
  task :install do
    load(File.join(File.dirname(__FILE__), '..', 'rails', 'install.rb'))
  end

  namespace :install  
    desc "Install Ajax integration spec tests into spec/integration."
    task :install do
      load(File.join(File.dirname(__FILE__), '..', 'rails', 'install.rb'))
    end  
  end
end