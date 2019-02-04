#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'dotenv'
require 'logger'
require 'open-uri'
require 'socket'
require 'twitch-bot'

Dotenv.load
client = TwitchBot.new(:chat_token => ENV['CHAT_TOKEN'], :botname => ENV['BOT_NAME'], :channel => ENV['CHANNEL_NAME'])
