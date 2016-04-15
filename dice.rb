class Dice
    private
    def roll(number)
        number.times { |n|
            @roll.push(rand(1..6))
        }
    end

    public
    def initialize(number)
        @roll = []
        roll(number)
    end

    def values
        @roll
    end
end