class Game
    @@current_player_id = 0
    @@accumulated_score = 0 # a temporary variable - resets everytime a new player starts rolling dice

    def initialize(num_players)
        @num_players = num_players
        @players = {}
        num_players.times do |n|
            @players[("player_" + n.to_s).to_sym] = Player.new(n)
            Log.info("created player_#{n.to_s} with id: #{n}, score 0")
        end
    end

    private
    def player_from_player_id(player_id)
        @players[("player_" + player_id.to_s).to_sym]
    end

    def set_next_player
        @@accumulated_score = 0
        @@current_player_id = (@@current_player_id + 1) % @num_players
    end

    def throw_dice_once(player, num_of_dice = 5)
        Log.info("last-round >> player-#{player.id.to_s} is throwing #{num_of_dice.to_s} dice")
        dice = Dice.new(num_of_dice).values
        calculation = Calculate.new(dice)
        Log.info("last-round >> player-#{player.id.to_s} score was #{calculation.score.to_s} with #{dice.to_s}")
        if calculation.score == 0 || player.wants_to_pass
            if calculation.score == 0 # remove accumulated score
                @@accumulated_score = 0
                Log.info("last-round >> player-#{player.id.to_s} looses turn as accumulated-score was 0")
            else # update accumulated scores
                @@accumulated_score += calculation.score if calculation.score >= 300
                Log.info("last-round >> player-#{player.id.to_s} passes")
            end
            player.score += @@accumulated_score # update actual score
            Log.info("last-round >> player-#{player.id.to_s} | num_of_dice: #{num_of_dice.to_s} | accumulated_score: #{@@accumulated_score.to_s} | score: #{player.score.to_s}")
        else
            @@accumulated_score += calculation.score if calculation.score >= 300
            num_of_dice = calculation.non_scoring_dice.size
            Log.info("last-round >> player-#{player.id.to_s} accumulated-score was #{@@accumulated_score.to_s}, non scoring dice are #{num_of_dice.to_s}")
            Log.info("last-round >> player-#{player.id.to_s} wants to continue")
            num_of_dice = 5 if num_of_dice == 0
            throw_dice_once(player, num_of_dice)
        end
    end

    def last_round(last_round_decider)
        Log.info("Entered last round")
        @players.each do |player_symbol, player_obj|
            if player_obj == last_round_decider
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
            Log.info("player-#{player_id.to_s} score was #{player.score.to_s}, therefore entered last round")
            last_round(player)
            return
        end

        Log.info("player-#{player_id.to_s} is throwing #{num_of_dice.to_s} dice")
        dice = Dice.new(num_of_dice).values
        calculation = Calculate.new(dice)
        Log.info("player-#{player_id.to_s} score was #{calculation.score.to_s} with #{dice.to_s}")
        if calculation.score == 0 || player.wants_to_pass
            if calculation.score == 0 # remove accumulated score
                @@accumulated_score = 0
                Log.info("player-#{player_id.to_s} looses turn as accumulated-score was 0")
            else # update accumulated scores
                @@accumulated_score += calculation.score if calculation.score >= 300
                Log.info("player-#{player_id.to_s} passes")
            end
            player.score += @@accumulated_score # update actual score
            Log.info("player-#{player_id.to_s} | num_of_dice: #{num_of_dice.to_s} | accumulated_score: #{@@accumulated_score.to_s} | score: #{player.score.to_s}")
            set_next_player # over to next player
            throw_dice(@@current_player_id)
        else
            @@accumulated_score += calculation.score if calculation.score >= 300
            num_of_dice = calculation.non_scoring_dice.size
            Log.info("player-#{player_id.to_s} accumulated-score was #{@@accumulated_score.to_s}, non scoring dice are #{num_of_dice.to_s}")
            Log.info("player-#{player_id.to_s} wants to continue")
            num_of_dice = 5 if num_of_dice == 0
            throw_dice(@@current_player_id, num_of_dice)
        end
    end

    public
    def start
        Log.info("Game is on".upcase)
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