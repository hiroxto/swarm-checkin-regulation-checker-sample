require 'bundler'

Bundler.require

require 'uri'
require 'net/http'
require 'openssl'
require 'json'

Dotenv.load

OAUTH_TOKEN = ENV['OAUTH_TOKEN']

MIN2_LIMIT = 5
MIN15_LIMIT = 8
DAY1_LIMIT = 50
DAY3_LIMIT = 90
DAY3_AND_DAY1_LIMIT = 30

def fetch_checkins(oauth_token:)
  params = {
    oauth_token: oauth_token,
    limit: 100,
    lang: 'ja',
    v: '20221016'
  }
  url = URI("https://api.foursquare.com/v2/users/self/checkins")
  url.query = URI.encode_www_form(params)

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)

  response = http.request(request)
  JSON.parse(response.read_body)
end

def pick_checkin_times(response)
  response['response']['checkins']['items'].map { |checkin| Time.at(checkin['createdAt']) }
end

def check_2min_limit(checkin_times, now)
  min2 = now - 2.minute
  min2_checkins = checkin_times.select { |checkin_time| checkin_time >= min2 }
  min2_checkins.count >= MIN2_LIMIT
end

def check_15min_limit(checkin_times, now)
  min15 = now - 15.minute
  min15_checkins = checkin_times.select { |checkin_time| checkin_time > min15 }
  min15_checkins.count >= MIN15_LIMIT
end

def check_1day_limit(checkin_times, now)
  day1 = now - 1.days
  day1_checkins = checkin_times.select { |checkin_time| checkin_time >= day1 }
  day1_checkins.count >= DAY1_LIMIT
end

def check_3day_limit(checkin_times, now)
  day3 = now - 3.days
  day1 = now - 1.days

  day3_checkins = checkin_times.select { |checkin_time| checkin_time >= day3 }
  day1_checkins = checkin_times.select { |checkin_time| checkin_time >= day1 }
  day3_checkins.count >= DAY3_LIMIT && day1_checkins.count >= DAY3_AND_DAY1_LIMIT
end

checkins_responsee = fetch_checkins(oauth_token: OAUTH_TOKEN)
checkin_times = pick_checkin_times(checkins_responsee)
now = Time.now

result = [
  check_2min_limit(checkin_times, now),
  check_15min_limit(checkin_times, now),
  check_1day_limit(checkin_times, now),
  check_3day_limit(checkin_times, now),
]

pp result

puts result.any?(true) ? "規制されています" : "規制されていません"
