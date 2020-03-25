# require "csv"
# require "pry"
# require "fuzzy_match"
#
# require 'watir'
# require 'watir-nokogiri'
# require 'webdrivers'

module Scrapers
  class YoutubeMusicScrape
    BASE_URL = "https://www.youtube.com"

    def initialize
      @browser = Watir::Browser.new(:chrome, options: {extensions: ["../adblocker.crx"]})
    end

    def call(candidate_links)
      candidate_links.each do |link|
        url = BASE_URL + link.attributes["href"].value
        @browser.goto(url)

        vid_duration = @browser.execute_script("return document.getElementsByClassName('html5-main-video')").first.duration

        # skip any video under 8 mins - cuz likely just an individual section
        unless (vid_duration / 60) > 8 && @browser.html.match?("Music in this video")
          @browser.screenshot.save("../tmp/screenshots/search/negative/#{link.attributes["title"].value}.png")
        else
          @browser.screenshot.save("../tmp/screenshots/search/positive/#{link.attributes["title"].value}.png")
        end
      end
    end
  end
end

# Scrapers::YoutubeSearch.new.call
