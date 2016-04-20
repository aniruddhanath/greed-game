# A program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
# 
# EXTRA CREDIT: http://rubykoans.com/

require "./log.rb"
require "./dice.rb"
require "./calculate.rb"
require "./player.rb"
require "./game.rb"

print "Enter number of players: "
num = gets.chomp
if num.to_i < 1
  abort("You must have atleat 1 player to play the game")
end
game = Game.new(num.to_i)
game.start()
winner = game.winner
Log.info("Winner is player-#{winner.id + 1} with #{winner.score}".upcase)
