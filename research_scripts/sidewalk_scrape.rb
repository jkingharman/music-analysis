# quick and dirty script for scraping sidewalk's vid pages and persisting to csv file
require 'nokogiri'
require 'mechanize'
require 'pry'
require 'csv'

total_page_count = 66
page_count = 1
url = "https://sidewalkmag.com/skateboarding-videos"
links = []

client = Mechanize.new

# scrape links that have a year and/or video title
total_page_count.times do
  c = client.get(url)
  links << c.links.select {|l| l.text.match(/\([0-9]*\)/) }
  links << c.links.select {|l| l.text.match(/'[a-zA-Z0-9]+'/) }
  page_count += 1
  url = "https://sidewalkmag.com/skateboarding-videos/page/#{page_count}"
end

# get video link text and dedup
links = links.flatten.map(&:text).uniq

vid_hash = {}

links.each do |l|
  # Link had a title and year
  if l.match?(/('.*').*(\([0-9]+\))/)
    title_and_year = l.match(/('.*').*(\([0-9]+\))/).captures
    vid_hash[title_and_year.first] = title_and_year.last

  # Link had just the title
  elsif l.match?(/'.*'/) && !l.match?(/\([0-9]+\)/)
    title = l.match(/('.*')/).captures
    vid_hash[title.first] = "Year unknown"
  end
end

CSV.open("videos.csv", "ab") {|csv| vid_hash.to_a.each {|elem| csv << elem } }
