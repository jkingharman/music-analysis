require "csv"
require "pry"
require "fuzzy_match"

require 'watir'
require 'watir-nokogiri'
require 'webdrivers'

module Scrapers
  class YoutubeSearch
    BASE_URL = "https://www.youtube.com/results?search_query="
    UK_PREFIX = "UK skateboard video"

    VIDEO_ID_POS = 3
    VIDEO_TITLE_POS = 0
    BATCH_SIZE = 10

    def initialize
      @browser = Watir::Browser.new
      @last_scraped_id = CSV.readlines("../tmp/youtube_scrape.csv")[0].first
      @videos = CSV.readlines("../data/videos.csv")
    end

    def call
      unprocessed_vids.each_with_index do |video, i|
        @current_video = video
        @current_video_id = @current_video[VIDEO_ID_POS]
        @current_video_title = @current_video[VIDEO_TITLE_POS]

        @browser.goto(BASE_URL + UK_PREFIX + "%2B" + "#{@current_video_title}")
        candidate_links = scrape_candidate_links

        if candidate_links.empty?
          puts "\n NO candidate links found for: #{@current_video_title} "
        else
          puts "\n Candidate links found for: #{@current_video_title}"
          # take positive snapshot and call visit link class
        end

        if i == BATCH_SIZE
          puts "\n Writing out last processed video id..."
          CSV.open("../tmp/youtube_scrape.csv", "wb") {|csv| csv << [@current_video_id] }
          break
        else
          puts "Waiting before next search.."
          sleep 2
        end
      end
    end

    private

    def unprocessed_vids
      last_scraped_video_pos = @videos.find_index(@videos.select {|vids| vids[VIDEO_ID_POS] == @last_scraped_id }.first)
      @videos[last_scraped_video_pos..-1]
    end

    def scrape_candidate_links
      links = Nokogiri::HTML.parse(@browser.html).css("#video-title")
      link_titles = links.map {|video_links| video_links.attributes["title"] }
      link_titles_and_scores = FuzzyMatch.new(link_titles).find_all_with_score(@current_video_title)

      # candidate links are those that have titles at least weakly related to the current video's
      candidate_link_texts = link_titles_and_scores.select {|ls| ls[1] > 0.3 }

      links.select {|link| candidate_link_texts.map {|cl| cl[0].value }.include?(link.attributes["title"].value) }
    end
  end
end

Scrapers::YoutubeSearch.new.call
