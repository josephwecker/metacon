# Actually not an extension compilation, but a pseudo-post-install script. One
# day when rubygems has proper support I'll be able to remove this hack.

libdir = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libdir) if File.exists?(File.join(libdir,'metacon.rb'))
require 'metacon'
#require '../lib/metacon/self_install.rb'

MetaCon::SelfInstall.complete_install

# Trick rubygems into thinking we created something. *sigh*
File.open('Makefile', 'w'){|f| f.write "all:\n\ninstall:\n\n"}
File.open('metacon.so', 'w'){}
File.open('make', 'w') do |f|
  f.write '#!/bin/sh'
  f.chmod f.stat.mode | 0111
end

