require "rubygems"
require "daemons"



Daemons.run_proc("RenderFerret.rb") do
  i = 0
  loop do
    puts "round: " + i.to_s
    i = i + 1
    sleep(5)
  end
end
