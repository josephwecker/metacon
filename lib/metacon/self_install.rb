module MetaCon
   class SelfInstall
     def self.complete_install
       system 'ls -al'
     end
   end
end
