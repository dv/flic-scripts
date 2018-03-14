#!/usr/bin/env ruby
require "httparty"

# This is run using system ruby, not with rbenv etc
# So to make sure it works, you need to:
#
# - disable rbenv temporarily by commenting out the `eval "$(rbenv init -)"` line in `rbenv.zsh`
# - then in a new terminal run `sudo gem install httparty`
# - chmod +x this script

# Go here to get a token:
# https://api.slack.com/custom-integrations/legacy-tokens

BASE = "https://slack.com/api/"
TOKEN = "<ENTER YOUR TOKEN HERE>"
DURATION = 240 # snooze in minutes
STATUS_TEXT = "In a meeting"
STATUS_EMOJI = ":call_me_hand:"

def get_slack(endpoint, query = {})
  url = BASE + endpoint
  query[:token] = TOKEN

  HTTParty.get(url, query: query)
end

def post_slack(endpoint, body = {})
  url = BASE + endpoint
  body[:token] = TOKEN

  HTTParty.post(url, body: body)
end

def snoozed?
  get_slack("dnd.info")["snooze_enabled"]
end

def set_snooze!(duration = DURATION)
  get_slack("dnd.setSnooze", num_minutes: duration)
end

def set_status!(status_text:, status_emoji:)
  profile = {status_text: status_text, status_emoji: status_emoji}.to_json

  post_slack("users.profile.set", profile: profile)
end

# Now do it!
if snoozed?
  set_snooze!(0)
  set_status!(status_text: "", status_emoji: "")
else
  set_snooze!
  set_status!(status_text: STATUS_TEXT, status_emoji: STATUS_EMOJI)
end
