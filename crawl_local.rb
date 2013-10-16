#
# SiteAudit
# A Content Auditing Script written in Ruby
#
# Licensed under MIT license 
# (c)2012 John Nye
#

require 'rubygems'
require 'anemone'
require 'csv'

CRAWL_LIMIT = 5000
 
Encoding.default_internal = "ISO-8859-1"

#puts params
file = DOMAIN.gsub("http://",'')
file = file.gsub(".",'')
file = file.gsub('/','')

path = file+".csv"
CSV.open(path, "w") do |csv|
  csv << ["Content Inventory"]
  csv << ["PageID","Type", "URI", "Title","Description", "Content","ROT", "Notes"]
  counter = 0
  catch :reach_crawl_limit do
    Anemone.crawl(DOMAIN) do | anemone |
      ext = %w(flv swf png jpg gif asx zip rar tar 7z gz jar js css dtd xsd ico raw mp3 mp4 wav wmv ape aac ac3 wma aiff mpg mpeg avi mov ogg mkv mka asx asf mp2 m1v m3u f4v pdf doc xls ppt pps bin exe rss xml)
      anemone.skip_links_like /\.#{ext.join('|')}$/

      anemone.on_every_page do | page |
        counter+=1
        doc = Nokogiri::HTML.parse(page.body)
        doc = doc.xpath("//script").remove
        puts title = doc.xpath("//title").text.to_s().force_encoding('ISO-8859-1')
        description = doc.xpath('/html/head/meta[@name="description"]/@content').text.to_s().force_encoding('ISO-8859-1')
        puts page.url
        text = doc.xpath("//body//text()[not(self::script)]").remove
        text = text.to_s().force_encoding('ISO-8859-1')
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



