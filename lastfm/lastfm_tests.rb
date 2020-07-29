# frozen_string_literal: true

require 'awesome_print'
require 'colorize'
require 'byebug'

#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#
# LastFM Info Retriever v0.1
#
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

require 'lastfm'

class LastFMReader
  def initialize(key, secret)
    return false if key.empty? || secret.empty?

    @lastfm = Lastfm.new(key, secret)
  end

  def get_info(track, artist)
    track_info = @lastfm.track.get_info({ artist: artist, track: track })

    {
      track: track_info.dig('name'),
      artist: track_info.dig('artist', 'name'),
      album: track_info.dig('album', 'name'),
      tags: get_tags(track_info)
    }
  rescue StandardError
    {}
  end

  def get_tags(track_info)
    tags = track_info.dig('toptags', 'tag')

    return ['shoegaze'] if tags.nil?

    tags.map { |tag| tag['name'] }
  end
end

#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
#
# Program
#
#==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

puts ENV['LASTFM_KEY']
puts ENV['LASTFM_SEC']

last = LastFMReader.new(ENV['LASTFM_KEY'], ENV['LASTFM_SEC'])<

ap last.get_info('kaleidoscope', 'ringo deathstarr')
ap last.get_info('in your room', 'airiel')
ap last.get_info('wavetemple', 'Whirlpool 渦 // demo II')
ap last.get_info('devastate me', 'She Makes War')

puts 'end'
