# A program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
# 
# EXTRA CREDIT: http://rubykoans.com/

class Dice
    private
    def roll(num)
        @roll = [] 
        num.times { |n|
            @roll.push(rand(1..6))
        }
    end

    public
    def initialize(num)
        roll(num)
    end

    def values
        @roll
    end
end

class Calculate
    attr_reader :score
    attr_reader :non_scoring_dice

    private
    def analyze_data(dice)
        score = 0;
        hash = Hash.new(0)
        dice.each do |n|
            s = n.to_s
            hash[s] += 1
            if hash[s] == 3 && n == 1
                @score += 1000
                hash[s] = 0
            elsif hash[s] == 3 && n != 1
                @score += 100 * n
                hash[s] = 0
            elsif n != 1 && n != 5
                @non_scoring_dice.push(n)
            end
        end
        @score += hash["1"] * 100
        @score += hash["5"] * 50
    end

    public
    def initialize(dice)
        @score = 0 
        @non_scoring_dice = []
        analyze_data(dice)
    end
end

class Player
    attr_accessor :score
    attr_accessor :id

    public
    def initialize(id)
        @score = 0
        @id = id
    end

    def wants_to_pass
        [true, false].sample
    end
end

class Game
    @@current_player_id = 0
    @@accumulated_score = 0
    @@last_round_decider

    def initialize(num_players)
        @num_players = num_players
        @players = {}
        num_players.times do |n|
            @players[("player_" + n.to_s).to_sym] = Player.new(n)
            puts "created player_#{n.to_s} with id: #{n}, score 0"
        end
    end

    private
    def player_from_player_id(player_id)
        @players[("player_" + player_id.to_s).to_sym]
    end

    def set_next_player
        @@accumulated_score = 0
        @@current_player_id = (@@current_player_id + 1) % 4
    end

    def throw_dice_once(player, num_of_dice = 5)
        puts "last-round >> player-#{player.id.to_s} is throwing #{num_of_dice.to_s} dice"
        dice = Dice.new(num_of_dice).values
        calculation = Calculate.new(dice)
        puts "last-round >> player-#{player.id.to_s} score was #{calculation.score.to_s} with #{dice.to_s}"
        if calculation.score == 0 || player.wants_to_pass
            if calculation.score == 0 # remove accumulated score
                @@accumulated_score = 0
                puts "last-round >> player-#{player.id.to_s} looses turn as accumulated-score was 0"
            else # update accumulated scores
                @@accumulated_score += calculation.score if calculation.score >= 300
                puts "last-round >> player-#{player.id.to_s} passes"
            end
            player.score += @@accumulated_score # update actual score
            puts "last-round >> player-#{player.id.to_s} | num_of_dice: #{num_of_dice.to_s} | accumulated_score: #{@@accumulated_score.to_s} | score: #{player.score.to_s}"
        else
            @@accumulated_score += calculation.score if calculation.score >= 300
            num_of_dice = calculation.non_scoring_dice.size
            puts "last-round >> player-#{player.id.to_s} accumulated-score was #{@@accumulated_score.to_s}, non scoring dice are #{num_of_dice.to_s}"
            puts "last-round >> player-#{player.id.to_s} wants to continue"
            num_of_dice = 5 if num_of_dice == 0
            throw_dice_once(player, num_of_dice)
        end
    end

    def last_round
        puts "Entered last round"
        @players.each do |player_symbol, player_obj|
            if player_obj == @@last_round_decider
                next
            else 
                @@accumulated_score = 0
                throw_dice_once(player_obj)
            end
        end
    end

    def throw_dice(player_id, num_of_dice = 5)
        player = player_from_player_id(player_id)

        # check for winner
        if player && player.score >= 3000
            puts "player-#{player_id.to_s} score was #{player.score.to_s}, therefore entered last round"
            @@last_round_decider = player
            last_round
            return
        end

        puts "player-#{player_id.to_s} is throwing #{num_of_dice.to_s} dice"
        dice = Dice.new(num_of_dice).values
        calculation = Calculate.new(dice)
        puts "player-#{player_id.to_s} score was #{calculation.score.to_s} with #{dice.to_s}"
        if calculation.score == 0 || player.wants_to_pass
            if calculation.score == 0 # remove accumulated score
                @@accumulated_score = 0
                puts "player-#{player_id.to_s} looses turn as accumulated-score was 0"
            else # update accumulated scores
                @@accumulated_score += calculation.score if calculation.score >= 300
                puts "player-#{player_id.to_s} passes"
            end
            player.score += @@accumulated_score # update actual score
            puts "player-#{player_id.to_s} | num_of_dice: #{num_of_dice.to_s} | accumulated_score: #{@@accumulated_score.to_s} | score: #{player.score.to_s}"
            set_next_player # over to next player
            throw_dice(@@current_player_id)
        else
            @@accumulated_score += calculation.score if calculation.score >= 300
            num_of_dice = calculation.non_scoring_dice.size
            puts "player-#{player_id.to_s} accumulated-score was #{@@accumulated_score.to_s}, non scoring dice are #{num_of_dice.to_s}"
            puts "player-#{player_id.to_s} wants to continue"
            num_of_dice = 5 if num_of_dice == 0
            throw_dice(@@current_player_id, num_of_dice)
        end
    end

    public
    def start
        puts "Game is on".upcase
        throw_dice(0)
    end

    def winner
        winner = nil
        max_score = 0
        @players.each do |pl, player_obj|
            if player_obj.score >= max_score
                max_score = player_obj.score
                winner = player_obj
            end
        end
        return player_from_player_id(winner.id)
    end
end

print "Enter number of players "
num = gets.chomp
game = Game.new(num.to_i)
game.start()
winner = game.winner
puts "Winner is player-#{winner.id.to_s} with #{winner.score.to_s}".upcase
