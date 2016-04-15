class Calculate
    attr_reader :score
    attr_reader :non_scoring_dice

    private
    def analyze_data(dice)
        score = 0;
        hash = Hash.new(0)
        dice.each do |n|
            sym = ("dice_" + n.to_s).to_sym
            hash[sym] += 1
            if hash[sym] == 3 && n == 1
                @score += 1000
                hash[sym] = 0
            elsif hash[sym] == 3 && n != 1
                @score += 100 * n
                hash[sym] = 0
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