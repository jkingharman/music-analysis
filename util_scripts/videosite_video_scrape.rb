require 'nokogiri'
require 'httparty'
require 'pry'

page_count = 1
url = "https://www.skatevideosite.com/category/skatevideos/page/1"
videos = []

while page_count < 309 do
  n = Nokogiri::HTML.parse(HTTParty.get(url))
  vids = n.css(".videoinfo tr td:contains('United Kingdom')")
  vids = vids.map {|vid| vid.ancestors("article").css(".entry-title a").text }
  videos << vids

  page_count += 1
  puts "Scraping page #{page_count}"

  url = "https://www.skatevideosite.com/category/skatevideos/page/#{page_count}"
end
