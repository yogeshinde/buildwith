require 'mechanize'
require 'csv'


module Enumerable
  def in_parallel
    map{|x| Thread.new{ yield(x) } }.each{|t| t.join}
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
   @output_file = []
 end 



 def find
   p "#{name}"
   if File.exists?(name)
         #CSV.foreach(name) do |row|
         
         ofile = CSV.open(name,"r")
         big_array = ofile.each_slice(2).to_a
         big_array.each do |small_array|
           small_array.in_parallel do |row|  
             begin
               technology_name = row[1].gsub(/\//,'-').gsub(/\s+/, '-').gsub(/,/, '-')

               #common(technology_name)
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
           
               output_row =[row[0],technology_name,counts,links].flatten
               p output_row

               # output_file = CSV.open("my.csv","a")
               # output_file << output_row

               @output_file << output_row

           
               counts.clear
               links.clear
         rescue Exception => e
           p e		
         end  
       end  
     end
      CSV.open("my.csv","w") do |outputfile|
      @output_file.each do |item|
      outputfile << item
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