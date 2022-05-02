# frozen_string_literal: true
class Board
  @@guess_board = [
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' '],
                    [' ',' ',' ',' ']
                  ]
  @@code_board = ['','','','']

  attr_accessor :guess_board
  
  public
  attr_reader :code_board

  def initialize
    puts "Let's play mastermind!"
    @code_board = @@code_board
    @guess_board = @@guess_board
    @allowable_moves = ['R','G','B','P','Y','O']
  end

  public
  def print_board
    puts "CURRENT BOARD"
    for i in (0..11)
      p @guess_board[i]
      puts "----------------"
    end
  end

  public
  def update_code(code)
    @code_board = code
  end

  public
  def update_board(round, guess)
    @guess_board[round] = guess
  end

  def get_current_round(round)
    @guess_board[round]
  end

  def get_code
    @code_board
  end
end

class Player 
  attr_accessor :score

  def initialize(score=0)
    @score = score
  end
end

class Codemaker < Player

  def set_code(board, code)
    board.update_code(code)
  end

  def give_feedback(board, round)
    code = board.code_board
    puts "CODE: "
    p code
    puts "FEEDBACK: "
    current_guess = board.get_current_round(round)

    current_guess.each do |guess|
      if guess == code[round]
        puts "Correct colour in correct place somewhere"
      end
      
      # if guess != code[round] && current_guess.one? {|colour| board.code_board.one?(colour)}
      #   puts "Correct colour somewhere"
      # end
      if guess != code[round] && board.code_board.one?(guess)
        puts "Correct colour in the wrong place somewhere"
      end
    end

    if current_guess.none? {|colour| board.code_board.any?(colour)}
      puts "No correct colours"
    end
    
  end
  

end

class Codebreaker < Player
  
  def make_guess(board, round, guess)
    board.update_board(round, guess)
  end

end


board = Board.new
# board.print_board
# board.update_board(1, ['B', 'R', 'G', 'Y'])
board.print_board

human = Codebreaker.new
human.make_guess(board, 0, ['B', 'P', 'P', 'G'])
board.print_board
cpu = Codemaker.new
cpu.set_code(board, ['B', 'P', 'P', 'G'])
cpu.give_feedback(board, 0)

    # if current_guess.any? {|colour| board.code_board.any?(colour)}
    #   puts "Correct colour somewhere"
    # end
    # if current_guess.none? |colour| board.code_board.any?(colour)
    #   puts "No correct colours or guesses"