# need watir cus page data is added dynamically
require 'watir'
require 'watir-nokogiri'
require 'webdrivers'

require 'pry'
require 'csv'

vid_hash = {}
url = 'http://www.skateboardingis.com/whenitrains/list.html'
existing_vids = CSV.readlines("videos.csv").map {|vid| vid.first }

browser = Watir::Browser.new
browser.goto(url)
noko = Nokogiri::HTML.parse(browser.html)

# absolute hackery to get titles and years
noko.css("tbody").children.each do |tr|
  vid_data = tr.children.last
  next unless vid_data.respond_to?(:children)

  title = vid_data.children.select {|td| td.name == "b"}
  title = title.first.text unless title.empty?
  next if existing_vids.include?(title)

  year = vid_data.children.select {|td| td.text.match?(/[0-9]{4}/) }
  year = year unless year.empty?

  vid_hash[title] = year.first unless title.empty?

  vid_hash.transform_values! do |year|
    if year.nil?
      "Year unknown"
    else
      year
    end
  end
end

CSV.open("videos.csv", "ab") {|csv| vid_hash.to_a.each {|elem| csv << elem } }
