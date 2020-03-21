require 'nokogiri'
require 'httparty'
require 'pry'
require 'csv'
require "fuzzy_match"

url = "https://www.skatevideosite.com/category/skatevideos/?s="

h = {}
videos = CSV.readlines("test.csv").map {|vid| [vid.first, vid.last] }
videos.map {|vid| h[vid.first] = {id: vid.last, songs: []} }

videos_titles = h.keys

videos_titles.each do |title|
  puts title
  n = Nokogiri::HTML.parse(HTTParty.get(url + "#{title}"))

  if n.css(".no-results").length > 0
    puts "No results for:" + " " + "#{title}"
    next
  else
    raw_links = n.css("article .entry-header a")
    link_texts = n.css("article .entry-header a").map(&:text)
    best_and_score = FuzzyMatch.new(link_texts).find_with_score(title)

    puts "Best match:" + " " + "#{best_and_score}"

    next unless best_and_score && best_and_score[1] > 0.6
    best_match_link = n.css("article .entry-header a").find {|l| l.text == best_and_score[0] }["href"]

    n = Nokogiri::HTML.parse(HTTParty.get(best_match_link))

    if n.css(".videoinfo tr").text.match?(/(Country\n.*\n)/)
      country = n.css(".videoinfo tr").text.match(/(Country\n.*\n)/).captures.first.split(/\n/).last
      match = FuzzyMatch.new(["United Kingdom", "UK", "Britain", "England", "Scotland", "Ireland", "Wales"]).find_with_score(country)
      next unless match[1] > 0.5

      puts "Country got through" + ":" + "#{match[0]}"
    end

    if n.css("#soundtrack p").empty?
      puts "No songs!"
      next
    end

    puts "Adding song..."
    songs = n.css("#soundtrack p").first.text.split(/\n/).map! do |song|
      song.split("–").last
    end

    h[title][:songs] = songs
  end
end
