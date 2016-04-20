class Game
    def initialize(num_players)
        @num_players = num_players
        @players = {}
        num_players.times do |n|
            @players[("player_" + n.to_s).to_sym] = Player.new(n)
        end
        @current_player_id = 0
        @accumulated_score_of_current_user = 0
        @current_turn = 1
    end

    private
    def player_from_player_id(player_id)
        @players[("player_" + player_id.to_s).to_sym]
    end

    def set_next_player
        @accumulated_score_of_current_user = 0
        if @current_player_id == @num_players - 1
            @current_turn += 1
            Log.info("\n")
            Log.info("Turn #{@current_turn}") 
            Log.info("----------")
        else
            Log.info("\n");
        end
        @current_player_id = (@current_player_id + 1) % @num_players
    end

    def store_score(player, is_last_round = false)
        player.score += @accumulated_score_of_current_user # update actual score
        if !is_last_round
            Log.info("Player #{@current_player_id + 1}'s score: #{player.score}")
            set_next_player # over to next player
            throw_dice(@current_player_id) 
        end
    end

    def last_round(last_round_decider)
        Log.info("Final round")
        Log.info("--------------")
        @players.each do |player_symbol, player_obj|
            if player_obj == last_round_decider
                next
            else 
                @accumulated_score_of_current_user = 0
                throw_dice(player_obj.id, 5, true)
                Log.info("\n");
            end
        end
    end

    def throw_dice(player_id, num_of_dice = 5, is_last_round = false)
        player = player_from_player_id(player_id)

        # check for winner
        if player && player.score >= 3000 && !is_last_round
            last_round(player)
            return
        end

        dice = Dice.new(num_of_dice).values
        calculation = Calculate.new(dice)
        Log.info("Player #{player.id + 1} rolls: #{dice.join(', ')}")
        Log.info("Score in this round: #{calculation.score}")
        
        @accumulated_score_of_current_user += calculation.score if calculation.score >= 300
        Log.info("Total accumulated score: #{@accumulated_score_of_current_user}")
        Log.debug("Score is not counted towards total-accumulated-score if it's less than 300") if calculation.score < 300
        
        if calculation.score == 0
            @accumulated_score_of_current_user = 0
            Log.debug("Looses all total-accumulated-score as the score was 0")
            store_score(player, is_last_round)
        elsif player.wants_to_pass?(calculation.non_scoring_dice.size)
            store_score(player, is_last_round)
        else
            num_of_dice = calculation.non_scoring_dice.size
            num_of_dice = 5 if num_of_dice == 0
            throw_dice(@current_player_id, num_of_dice)
        end
    end

    public
    def start
        Log.info("Turn #{@current_turn}") 
        Log.info("----------")
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