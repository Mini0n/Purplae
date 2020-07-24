# frozen_string_literal: true

require 'awesome_print'
require 'colorize'
require 'byebug'

#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#
# DKFM Scrapper v0.1
# Scrape DKFM Playlist(s) from onlineradiobox.com
#
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

require 'httparty'
require 'nokogiri'
require 'json'

# https://onlineradiobox.com DKFM Shoegaze radio playlist scrapper
class DKFMScrapper
  attr_reader :errors, :conn

  DKFM_URL = 'https://onlineradiobox.com/ca/dkfmshoegazeradio/playlist/'
  MAX_DAYS = 8      # Max num of past days playlists available
  DAY_SECS = 86_400 # 60 * 60 * 24

  # Initialization
  def initialize
    @conn = nil
    @errors = []
  end

  # Generates an array of playlists
  # @param [integer] past_days how many past days playlists to generate
  # @return [Array<Hash>] [{:date, :url}]
  #
  def playlists_list(past_days = 0)
    (past_days > MAX_DAYS ? MAX_DAYS : past_days).downto(0).map do |d|
      {
        date: (Time.now - d * DAY_SECS).strftime('%d.%m.%Y'),
        url: "#{DKFM_URL}#{d}"
      }
    end
  end

  def playlist_read(playlist_url)
    @conn = HTTParty.get(playlist_url)
    if @conn.ok?
      playlist_fragment = playlist_fragment(@conn.body)
      playlist_nokogiri = Nokogiri::HTML(playlist_fragment)
      playlist_songs(playlist_nokogiri)
    else
      push_error(@conn.code, 'read_playlist')
    end
  end

  def playlist_songs(noko_html)
    res = []
    noko_html.search('tr').each do |song|
      song_info = song.text.gsub("\n", '').split("\t")
      break if song_info[1].nil?

      res << { time: song_info[1], song: song_info[2] }
    end
    res
  end

  def playlist_fragment(body)
    init = body.index('<tbody>')
    stop = body.index('</tbody>')
    body[init, stop + 9] # "</tbody>".length + 1 = 9
  end

  def playlists(past_days = 0)
    playlists = playlists_list(past_days)
    playlists.each do |pl|
      pl[:playlist] = playlist_read(pl[:url])
    end
    playlists
  end

  private

  def push_error(_code, _message)
    @errors.push(
      time: Time.now.strftime('%d.%m.%Y-%H:%M:%S:%L'),
      code: '000',
      message: error.message
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
puts "DKFMScrapper test\n".magenta
puts "\n"

puts '- Crearing dkfm object...'
dkfm = DKFMScrapper.new
puts ('  ' + dkfm.to_s).green

puts '- Reading playlist for the last 8 days...'
lists = dkfm.playlists(8)
puts '  lists object created'.green

puts '- Entering byebug mode....'

byebug

puts '- Closing...'
puts '  BYE!'.green
