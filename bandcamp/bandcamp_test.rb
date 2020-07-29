# frozen_string_literal: true

require 'awesome_print'
require 'colorize'
require 'byebug'

#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#
# Bandcamp Info Retriever v0.1
#
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

require 'httparty'
require 'nokogiri'

class Bandcamper
  SEARCH_URL = 'https://bandcamp.com/search?q='

  attr_reader :errors

  # initialization
  def initialize
    @conn = nil
    @errors = []
  end

  def search_track(track)
    puts 'searching for ' + track
    @conn = HTTParty.get(SEARCH_URL + CGI.escape(track + ' shoegaze'))
    if @conn.ok?
      track = track_url(Nokogiri::HTML(@conn.body))

      return nil if track.nil?

      track
    else
      push_error(0, 'search_track')
    end
  end

  def track_url(search_noko)
    return nil if search_noko.nil?

    search_noko.search('.result-items > li').search('a')[0]['href']
  end

  def track_info(track)
    puts 'track_info for ' + track
    track_url = search_track(track).split('?').first

    parse_track(track_url)
  end

  def parse_track(track_url)
    puts 'parsing ' + track_url + ' ...'
    track_body = Nokogiri::HTML(HTTParty.get(track_url).body)

    return {} if track_body.nil?

    {
      track: read_track(track_body),
      artist: read_artist(track_body),
      album: read_album(track_body),
      tags: read_tags(track_body)
    }
  rescue StandardError => e
    ap 'failed'.red
    push_error(0, e.message)
    {}
  end

  def read_track(track_body)
    track_body.search('.trackTitle').first.text.strip
  rescue StandardError => e
    push_error(0, 'read_track')
    nil
  end

  def read_artist(track_body)
    track_body.search('.albumTitle > span').last.text.strip
  rescue StandardError => e
    push_error(0, 'read_track')
    nil
  end

  def read_album(track_body)
    track_body.search('.albumTitle > span').first.text.strip
  rescue StandardError => e
    push_error(e, 'read_album')
    nil
  end

  def read_tags(track_body)
    track_body.search('.tralbumData.tralbum-tags.tralbum-tags-nu > a').map(&:text)
  rescue StandardError => e
    push_error(0, 'read_tags')
    nil
  end

  private

  def push_error(code, message)
    @errors.push(
      time: Time.now.strftime('%d.%m.%Y-%H:%M:%S:%L'),
      code: code || '000',
      message: message || 'error'
    )
  rescue StandardError => e
    push_error(e)
  end
end

#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#
# Program
#
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

puts '-' * 43
puts 'Testing Bandcamper'.magenta
puts "\n"
test = Bandcamper.new
ap test.track_info('Whirlpool 渦 // demo II')
ap test.track_info('Geowulf')
ap test.track_info('Volume 3: Our Lady of Postdiction
')

puts 'end'
