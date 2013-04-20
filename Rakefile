require 'rubygems'
require 'rake'
require 'rake/testtask'



task :default => :test
task :test => [:test_lib, :test_rails]



Rake::TestTask.new(:test_lib) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/test_session_countdown.rb'
  test.verbose = true
end


 
desc 'Run rails tests' 
task :test_rails do |t|
  chdir "test/rails_root" do
    system "rake"
  end
end

