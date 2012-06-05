require 'mechanize'
require 'csv'

class Base
   attr_accessor :name
   def initialize(name)
     @name = name
     obj = Technology.new(name)
     obj.find  
   end
end

class Technology
   attr_accessor :name, :category, :counts, :links, :agent, :technology_counts_links
   
   def initialize(name)
       @name = name
       @category = ""
       @counts = []
       @links = []
       @agent = Mechanize.new
   end 

   def find
   	   p "#{name}"
   	   if File.exists?(name)
         CSV.foreach(name) do |row|
         begin
           technology_name = row[1].gsub(/\//,'-').gsub(/\s+/, '-').gsub(/,/, '-')
           
           common(technology_name)
           output_row =[row[0],technology_name,counts,links].flatten
           p output_row
            
           output_file = CSV.open("my.csv","a")
           output_file << output_row
           
           counts.clear
           links.clear
         rescue Exception => e
         p e		
         end  
         end  
   	   
       else
         common(name)
         technology_counts_links = { "name" => name, "counts" => counts, "links" => links }
         p  technology_counts_links
       end
   end

   def common(technology_name)
   
     page = agent.get("http://trends.builtwith.com/topsites/#{technology_name}")
     website_counts = page.search("p.rightPadder/strong")

   	 website_counts.each do |number|
       counts.push(number.text.gsub(",","").match(/[0-9]+/).to_s.to_i)
   	 end
     # p counts   
     top_ten_site_links = page.links_with(:text=> "Original Site")
     
     top_ten_site_links.each do |link|
       links.push(link.uri.to_s)
     end
   end

end

baseobj = Base.new(ARGV.join)
