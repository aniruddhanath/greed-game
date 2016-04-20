class Player
    attr_accessor :score
    attr_accessor :id

    public
    def initialize(id)
        @score = 0
        @id = id
    end

    def wants_to_pass?(num_of_dice)
        # pass = [true, false].sample
        dice = num_of_dice.to_s + (num_of_dice == 1 ? " dice" : " dices")
        print (num_of_dice != 0) ? "Do you want to roll the non-scoring #{dice}?(y/n): " : "Do you want to roll 5 dice again?(y/n): "
        # puts pass ? "n" : "y"
        # return pass
        response = gets.chomp
        if response == "y"
            return false
        end
        true
    end
end