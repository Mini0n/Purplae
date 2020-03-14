require 'httparty'
require 'awesome_print'
require 'nokogiri'
require 'byebug'

# https://onlineradiobox.com DKFM Shoegaze radio playlist scrapper
class DKFMScrapper
  attr_reader :errors

  DKFM_URL = 'https://onlineradiobox.com/ca/dkfmshoegazeradio/playlist/'.freeze
  LIST_NUM = 9 # Max number of past days playlists stored at onlineradiobox
  DAY_SECS = 86_400 # 60 * 60 * 24

  def initialize
    @conn = HTTParty.get(DKFM_URL) if @conn.nil?
    @errors = []
    check_conn_error(@conn)
  end

  # Creates an array of hashes for existing playlists
  # max number of playlist at any moment in the server is 10 [22.01.2020]
  # LAST_DAY of past days playlists + the current day playlist
  #
  # @param [days] number of playlists to retrieve
  # @return [Array<Hash>] array of available playlists w/ date & link
  def get_playlists(days = 0)
    result = []
    tday = Time.now
    begin
      days -= 1
      days = 0 if days > LIST_NUM || days.negative?
      days.downto(0).each { |day| result << playlist_item(tday, day) }
    rescue StandardError => e
      push_error(e)
    end
    result
  end

  # generates a playlist item for get_playlists
  def playlist_item(now = Time.now, day = 0)
    {
      date: (now - DAY_SECS * day).strftime('%d.%m.%Y'),
      link: "#{DKFM_URL}#{(day.zero? ? '' : day)}"
    }
  end

  # REDO ---------------------------------------------------------------------
  # def get_playlist_element(scheduled)
  #   href = scheduled.last[:href]
  #   url = DKFM_URL + href
  #   puts "Getting #{url}..."
  #   res = HTTParty.get(url)
  #   Nokogiri::HTML(read_playlist_text(res.body))
  # end

  # def get_playlist(scheduled)
  #   get_playlist_element(scheduled).css('tr').map do |song|
  #     # song.text.strip.gsub(/\n\t/,' - ')
  #     {
  #       date: '',
  #       hour: '',
  #       band: '',
  #       song: '',
  #       disc: '',
  #       link: ''

  #     }
  #   end
  # end

  private

  def push_error(error)
    @errors.push(
      time: Time.now.strftime('%d.%m.%Y-%H:%M:%S:%L'),
      code: '000',
      message: error.message
    )
  rescue StandardError => e
    push_error(e)
  end

  # Extracts the HTML section for the currently available playlists list
  #
  # @return: [String] HTML for the currently available playlists
  def extract_available_playlists_html(body)
    init = body.index("<ul class=\"playlist__schedule\"")
    stop = body[init..(init + 555)].index('</ul>') # 555: aprox. length
    body.slice(init, stop)
  end

  # Check if there were connection errors
  #
  # @return: [Boolean]
  def conn_errors?
    !@errors.empty?
  end

  # Checks and logs if there was an HTTParty error
  #
  # @return: [Array<Hash> || nil] returns @errors or nil if no error
  def check_conn_error(conn)
    return nil if conn.code == 200

    @errors.push(
      time: Time.now.strftime('%d.%m.%Y-%H:%M:%S:%L'),
      code: conn.code,
      message: conn.msg,
      request: conn.request.path.to_s
    )
  end

  # Gets full day name from abbreviated
  #
  # @return: [String] full day name
  # def day_name(day)
  #   index = DAYS.index(day)
  #   return '' if index.nil?

  #   DAYS[index + 1]
end



def line
  '-'*30
end

puts line + line
puts 'DKFMScrapper test '
puts line + line

dkfm = DKFMScrapper.new
puts "- creating scrapper... #{dkfm}"
puts '- getting available playlists...'
# playlists = dkfm.available_playlists


byebug

# read_playlist
# lists = schedule_days(@res.body)

# puts "Response CODE: #{@res.code}"
# puts "Saved playlists: #{lists.length}"
# puts "Getting 1st playlist: #{lists.first.first} ..."

# playlists = []
# lists.each do |list|
#   playlists << get_playlist(list)
# end

# byebug

puts 'END'