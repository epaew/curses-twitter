# -*- coding:utf-8 -*-

require 'twitter'
require 'singleton'
require_relative '../config/config'

class Core
  include Singleton

  def initialize
    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key = AppConfig::CONSUMER_KEY
      config.consumer_secret = AppConfig::CONSUMER_KEY_SECRET
      config.access_token = AppConfig::ACCESS_TOKEN
      config.access_token_secret = AppConfig::ACCESS_TOKEN_SECRET
    end
    @stream_client = Twitter::Streaming::Client.new do |config|
      config.consumer_key = AppConfig::CONSUMER_KEY
      config.consumer_secret = AppConfig::CONSUMER_KEY_SECRET
      config.access_token = AppConfig::ACCESS_TOKEN
      config.access_token_secret = AppConfig::ACCESS_TOKEN_SECRET
    end

    @lists = Hash.new
    self.fetch_timeline()
    self.fetch_mention()
  end

  def streaming_start(wins)
    core_thread = Thread.new {
      @stream_client.user do |obj|
        case obj
        when Twitter::Tweet then
          if @lists[:timeline] != nil && @lists[:timeline].class == Array
            @lists[:timeline].push(obj)
          end
          wins[:display].display()
        when Twitter::Streaming::Event then
        when Twitter::DirectMessage then
        when Twitter::Streaming::FriendList then
        when Twitter::Streaming::DeletedTweet then
        when Twitter::Streaming::StallWarning then
        end
      end
    }
    return core_thread
  end

  def send_tweet(str, in_reply_to)
    begin
      if in_reply_to
        @rest_client.update(str, :in_reply_to_status_id => in_reply_to)
      else
        @rest_client.update(str)
      end
    rescue => e
      puts e.backtrace
      return "sending tweet failed."
    end
    return "sent tweet."
  end

  def retweet(mode, tweet_num)
    if @lists[mode][tweet_num].user.attrs[:protected] == true
      return "Failed to Retweet. (protected tweet)"
    end

    begin
      @rest_client.retweet!(@lists[mode][tweet_num].id)
    rescue => e
      str = "Failed to Retweet."
      case e
      when Twitter::Error::AlreadyRetweeted then
        str += "(already retweeted)"
      when Twitter::Error::NotFound then
        str += "(tweet does not exist)"
      end
      return str
    end
    return "Retweeted."
  end

  def favorite(mode, tweet_num)
    begin
      @lists[mode][tweet_num] =
        @rest_client.favorite!(@lists[mode][tweet_num].id)[0]
    rescue => e
      str = "failed to favorite."
      case e
      when Twitter::Error::AlreadyFavorited then
        str += "(already favorited)"
      when Twitter::Error::NotFound then
        str += "(tweet does not exist)"
      end
      return str
    end
    return "favorited."
  end

  def unfavorite(mode, tweet_num)
    begin
      @lists[mode][tweet_num] =
        @rest_client.unfavorite(@lists[mode][tweet_num].id)[0]
    rescue => e
      e.backtrace
      return "failed to unfavorite."
    end
    return "unfavorited."
  end

  def update(mode)
    case mode
    when :timeline then
      self.fetch_timeline()
    when :mention then
      self.fetch_mention()
    else
      self.fetch_usertimeline(mode)
    end
  end

  def fetch_timeline
    begin
      if @lists[:timeline] == nil
        @lists[:timeline] =
          @rest_client.home_timeline(:count => 100).reverse
      else
        new_tl = @rest_client.home_timeline(:count => 100,
          :since_id => @lists[:timeline][@lists[:timeline].length - 1].id
        ).reverse
        if new_tl.length < 100
          @lists[:timeline] += new_tl
        else
          @lists[:timeline] = new_tl
        end
      end
    rescue => e
      puts e.backtrace
      return "fetching timeline failed."
    end
    return "fetched timeline."
  end

  def fetch_mention
    begin
      if @lists[:mention] == nil
        @lists[:mention] = @rest_client.mentions(:count => 100).reverse
      else
        new_mention = @rest_client.mentions(:count => 100,
          :since_id => @lists[:mention][@lists[:mention].length - 1].id
        ).reverse
        if new_mention.length < 100
          @lists[:mention] += new_mention.
        else
          @lists[:mention] = new_mention
        end
      end
    rescue => e
      e.backtrace
      return "fetching mentions failed."
    end
    return "fetched mentions."
  end

  def fetch_usertimeline(user)
    begin
      @lists[user.to_sym] =
        @rest_client.user_timeline(user, :count => 100).reverse
    rescue => e
      e.backtrace
      return "fetching #{user} failed."
    end
    return "fetched #{user}"
  end

  def get_in_reply_to(mode, tweet_num)
    return @lists[mode][tweet_num].id,
      @lists[mode][tweet_num].user.screen_name
  end

  def get_str_array(mode)
    str_array = Array.new
    @lists[mode].each.with_index do |t, idx|
      str_array.push(
        "#{"%4d" % idx}:--- #{t.user.name}(@#{t.user.screen_name})" +
        " --- #{t.user.protected? ? "" : ""}\n#{t.text}\n" +
        " --- via:#{t.source.match(/>(?<name>.*)</)[:name]}" +
        " --- RT: #{t.retweet_count}" +
        " #{t.favorited? ? "★" : "☆"}: #{t.favorite_count}".chomp
      )
    end unless @lists[mode] == nil
    return str_array
  end
end
