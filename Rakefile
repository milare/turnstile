require 'rubygems'  
require 'rake'  
require 'echoe'  
  
Echoe.new('turnstile', '0.1.1') do |p|  
  p.description     = "Simple authorization for rails"  
  p.url             = "http://github.com/milare/turnstile"  
  p.author          = "Bruno Milare"  
  p.email           = "milare@gmail.com"  
  p.ignore_pattern  = ["demo/**/*","spec/*", "config/initializers/*"]  
  p.development_dependencies = []  
end  
  
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }  
