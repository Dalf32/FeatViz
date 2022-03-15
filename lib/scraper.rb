# frozen_string_literal: true

# Scraper
#
# AUTHOR::  Kyle Mullins

require 'oga'
require 'open-uri'

require_relative 'scraped_feat'

class Scraper
  def self.scrape(url)
    # TODO: This line is very bad definitely change it
    feats_html = open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
    feats_doc = Oga.parse_html(feats_html)

    feats_doc.xpath('//table/tr/td').each_slice(3).map do |row|
      name, prerequisites, description = *row[0..2]
      ScrapedFeat.new(name.text.strip, prereq_text(prerequisites),
                      description.text.strip,
                      row.first.at_xpath('a[@href]').attributes.first.value)
    end
  end

  def self.prereq_text(prerequisites)
    prerequisites.children.
      reject { |e| e.is_a?(Oga::XML::Element) && e.name == 'sup' }.
      map(&:text).join
  end
end
