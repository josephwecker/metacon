# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name =           'metacon'
  gem.homepage =       'http://github.com/josephwecker/metacon'
  gem.license =        'MIT'
  gem.summary =        %Q{Metacontroller for organizing aggregate projects}
  gem.description =    %Q{Tool with some similarities to puppet but specializing in fast development iteration and continuous deployment. For use with justin.tv / twitch.tv project clusters.}
  gem.email =          'jwecker@justin.tv'
  gem.authors =        ['Joseph Wecker']
  gem.requirements <<  'git, v1.7.4.1 or greater'
  gem.requirements <<  'rvm, v1.8.2 or greater'
  gem.requirements <<  'pythonbrew, v1.1 or greater'

  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
