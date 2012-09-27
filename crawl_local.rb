//
// SiteAudit
// A Content Auditing Script written in Ruby
//
// Licensed under MIT license 
// (c)2012 John Nye
//

require 'rubygems'
require 'anemone'
require 'fastercsv'

CRAWL_LIMIT = 500
DOMAIN = 'http://example.com'
 
#puts params
file = DOMAIN.gsub("http://",'')
file = file.gsub(".",'')
file = file.gsub('/','')

path = file+".csv"
FasterCSV.open(path, "w") do |csv|
  csv << ["Content Inventory"]
  csv << ["PageID","Type", "URI", "Title","Description", "Content","ROT", "Notes"]
  counter = 0
  catch :reach_crawl_limit do
    Anemone.crawl(DOMAIN) do | anemone |
      anemone.on_every_page do | page |
        counter+=1
        doc = Nokogiri::HTML.parse(page.body)
        doc = doc.xpath("//script").remove
        puts title = doc.xpath("//title").text.to_s()
        description = doc.xpath('/html/head/meta[@name="description"]/@content').text.to_s()
        puts page.url
        text = doc.xpath("//body//text()[not(self::script)]").remove
        text = text.to_s()
        text.lstrip
        text.rstrip
        text = text.gsub(/\s{3,}/," ")
        csv << [counter,"", page.url, title,description, text,"",""]
        throw :reach_crawl_limit if counter == CRAWL_LIMIT
      end
    end
  end
  GC.start
end



