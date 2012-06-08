require File.join(File.dirname(__FILE__), 'technology')

class Base
   attr_accessor :name
   def initialize(name)
     @name = name
     obj = Technology.new(name)
     obj.find  
   end
end



baseobj = Base.new(ARGV.join)
