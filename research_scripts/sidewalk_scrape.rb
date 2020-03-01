
require 'nokogiri'
require 'mechanize'
require 'pry'

page_count = 1
url = "https://sidewalkmag.com/skateboarding-videos"
links = []

client = Mechanize.new

while page_count < 66 do
  c = client.get(url)
  links << c.links.select {|l| l.text.match(/\([0-9]*\)/) }

  page_count += 1
  url = "https://sidewalkmag.com/skateboarding-videos/page/#{page_count}"
end

binding.pry
