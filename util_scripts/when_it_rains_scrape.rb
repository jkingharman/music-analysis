# need watir cus page data is added dynamically
require 'watir'
require 'watir-nokogiri'
require 'webdrivers'

require 'pry'
require 'csv'

vid_hash = {}
url = 'http://www.skateboardingis.com/whenitrains/list.html'
existing_vids = []
CSV.readlines("../data/videos.csv").map do |vid_arr|
  if vid_arr[2] == "[]"
    existing_vids << {title: vid_arr[0], year: vid_arr[1], id: vid_arr[3] }
  end
end


browser = Watir::Browser.new
browser.goto(url)
noko = Nokogiri::HTML.parse(browser.html)

# absolute hackery to get titles and years
noko.css("tbody").children.each do |tr|
  vid_data = tr.children.last
  next unless vid_data.respond_to?(:children)

  title = vid_data.children.select {|td| td.name == "b"}
  title = title.first.text unless title.empty?


  missing_skater_titles = existing_vids.map {|vid| vid[:title] }

  next unless missing_skater_titles.include?(title)

  # year = vid_data.children.select {|td| td.text.match?(/[0-9]{4}/) }
  # year = year unless year.empty?

  skaters = vid_data.children.select {|td| td.text.match?(/- .+/) }
  next if skaters.empty?

  skaters = skaters.map {|s| s.text }

  puts "skaters found: #{skaters}"
  existing_vids = existing_vids.map do |h|
    if h[:title] == title
      h[:skaters] = skaters
    end
    h
  end
  # vid_hash[title] = [year.first, [skaters]] unless title.empty?
end

binding.pry

# vid_hash.transform_values! do |val|
#   if val.is_a?(Array)
#     val.flatten.compact.map(&:text)
#   else
#     val.text
#   end
# end



# CSV.open("videos.csv", "ab") {|csv| vid_hash.to_a.each {|elem| csv << elem } }
