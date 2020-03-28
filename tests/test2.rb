require 'httparty'
require 'awesome_print'
require 'nokogiri'
require 'byebug'

class DKFMRadio
  attr_reader :status

  DKFM_URL = 'https://onlineradiobox.com/ca/dkfmshoegazeradio/playlist/'.freeze
  MAX_PLST = 7 # max number of playlist to get
  DAY_SECS = 86_400 # 1 day = 60 * 60 * 24

  def initialize
    @conn = HTTPParty.get(DKFM_URL) if @conn.nil?
    @status = nil
  end


  def playlist_urls(days_ago = 0)
    result = { Time.now.strftime('%d/%m/%Y') => DKFM_URL }

    result
  end

end


# - get max num playlists into the past: 16
# - build hash of date: playlist
#
#
#
#
#
#
#
#
#
#
#
#
