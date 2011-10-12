# encoding: utf-8
$KCODE='U' if RUBY_VERSION < '1.9.0'

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Going to run `bundle install` to install missing gems"
  sh 'bundle install'
  begin
    Bundler.setup(:default, :development)
  rescue Bundler::BundlerError => e
    $stderr.puts e.message
    $stderr.puts "Run `bundle install` to install missing gems"
    exit e.status_code
  end
end

#require 'rake'
require 'yaml'

#include Rake::DSL

ROOTDIR        = File.expand_path(File.join(File.dirname(__FILE__),'..'))
CONTEXT_OS = `uname -s`.strip.downcase.to_sym
def mac?()    CONTEXT_OS == :darwin end
def darwin?() CONTEXT_OS == :darwin end
def linux?()  CONTEXT_OS == :linux  end

ESCS = {:normal    =>"\e[0m",    :black     =>"\e[0;30m", :blue         =>"\e[0;34m",
        :green     =>"\e[0;32m", :cyan      =>"\e[0;36m", :red          =>"\e[0;31m",
        :purple    =>"\e[0;35m", :brown     =>"\e[0;33m", :gray         =>"\e[0;37m",
        :dark_gray =>"\e[1;30m", :light_blue=>"\e[1;34m", :light_green  =>"\e[1;32m",
        :light_cyan=>"\e[1;36m", :light_red =>"\e[1;31m", :light_purple =>"\e[1;35m",
        :yellow    =>"\e[1;33m", :white     =>"\e[1;37m", :bg_black     =>"\e[40m",
        :bg_red    =>"\e[41m",   :bg_green  =>"\e[42m",   :bg_yellow    =>"\e[43m",
        :bg_blue   => "\e[44m",  :bg_magenta=>"\e[45m",   :bg_cyan      =>"\e[46m",
        :bg_white  => "\e[47m",  :"="       =>"\e[44;1;37m", :"=="      =>"\e[4;1;37m",
        :"==="     => "\e[1;34m"}

def color_puts(str, emit=true)
  begin
    r = false
    str.gsub!(/\|\{([^ \|]+ )([^\}\|]*)\}/){r=true; "#{ESCS[$1.strip.to_sym]}#{$2}#{ESCS[:normal]}"}
  end while r
  puts str if emit
  return str
end

def cwarn(str) color_puts("---|{red Warning:} #{str}") end
def cfail(str) color_fail("---|{red Fail:} #{str}") end
def color_fail(str) fail color_puts(str, false) end

def status(str) color_puts("\n---|{== #{str}}") end
def result(str) color_puts("   |{green #{str}}\n") end

def f(*args) File.expand_path(File.join(args)) end # Shortcut for File.join

def chd(*args)
  dir = f(args)
  color_puts "|{gray cd #{dir}}"
  Dir.chdir(dir)
end

def command_exists?(cmd)
  `( command -v #{cmd} )`.length > 0
end

def vew(cmd)
  sh "#{ROOTDIR}/vew #{cmd}"
  #sh "/bin/bash -c '. /usr/local/bin/virtualenvwrapper.sh ; #{cmd}'"
end

# From http://svn.ruby-lang.org/repos/ruby/trunk/lib/shellwords.rb
def shellescape(str)
  return "''" if str.empty?
  str = str.dup
  str.strip!
  str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
  str.gsub!(/\n/, "'\n'")
  return str
end

def ensure_profile_has(cmd, also_run=true)
    prof = Dir[ENV['HOME']+'/.bash_profile']
    prof = Dir[ENV['HOME']+'/.profile'] if prof.size == 0
    prof = Dir[ENV['HOME']+'/.bashrc'] if prof.size == 0
    if prof.size == 0
      color_puts("\n|{red IMPORTANT: Please put the following in your .bash_profile equivalent: #{cmd}}\n")
    else
      there = `grep -F #{shellescape(cmd)} '#{prof[0]}'`.length > 0
      unless there
        color_puts "|{brown ADDING >>> |{yellow #{cmd.strip}}} |{brown <<< to your #{prof[0]}!}"
        sh "echo #{shellescape(cmd)} >> '#{prof[0]}'"
      end
    end
    sh cmd if also_run
end
