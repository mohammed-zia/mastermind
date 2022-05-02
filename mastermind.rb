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

  attr_reader :code_board
  attr_accessor :guess_board

  def initialize
    puts "Let's play mastermind!"
    @code_board = @@code_board
    @guess_board = @@guess_board
    @allowable_moves = ['R','G','B','P','Y','O']
  end

  def print_board
    puts "CURRENT BOARD"
    for i in (0..11)
      p @guess_board[i]
      puts "----------------"
    end
  end

  private
  def update_code(code)
    @code_board = code
  end

  public
  def update_board(round, guess)
    @guess_board[round] = guess
  end
end

board = Board.new
# board.print_board
board.update_board(1, ['B', 'R', 'G', 'Y'])
board.print_board
