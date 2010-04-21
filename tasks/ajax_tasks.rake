require 'ajax'

namespace :ajax do
  desc "Install required Ajax files."
  task :install do
    load(File.join(File.dirname(__FILE__), '..', 'rails', 'install.rb'))
  end

  namespace :install do
    desc "Install Ajax integration spec tests into spec/integration."
    task :specs do
      puts "Coming soon..."
    end
  end
end