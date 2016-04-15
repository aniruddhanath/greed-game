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