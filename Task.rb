require "rubygems"
require "activerecord"
class Task < ActiveRecord::Base
  def say_something
    puts "hallo?"
  end
end
