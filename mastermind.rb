# frozen_string_literal: true
require 'colorize'

class Board
  @@guess_board = [
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  '],
                    ['  ','  ','  ','  ']
                  ]
  @@code_board = ['','','','']
  @@peg_board = [
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  '],
                  ['  ','  ','  ','  ']
                  ]

  attr_accessor :guess_board, :peg_board
  
  public
  attr_reader :code_board, :allowable_moves

  def initialize
    @code_board = @@code_board
    @guess_board = @@guess_board
    @peg_board = @@peg_board
    @allowable_moves = ['R','G','B','P','Y','O']
  end

  public
  def print_board
    puts "-----+-GUESSES-+----++----+--HINTS--+----+"
    for i in (0..11)
      puts "| #{@guess_board[i][0]} | #{@guess_board[i][1]} | #{@guess_board[i][2]} | #{@guess_board[i][3]} || #{@peg_board[i][0]} : #{@peg_board[i][1]} : #{@peg_board[i][2]} : #{@peg_board[i][3]} :"
      puts "-----+----+----+----++----+----+----+----+"
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

  def update_hint(round, hint)
    @peg_board[round].unshift(hint)

  end

  def get_current_round(round)
    @guess_board[round]
  end

  def get_code
    @code_board
  end

  def translate_input(guess)
    translated = []
    guess.each do |colour|
      if colour == "R"
        translated.push("\u{1f534}")
      elsif colour == "O"
        translated.push("\u{1f7e0}")
      elsif colour == "Y"
        translated.push("\u{1f7e1}")
      elsif colour == "G"
        translated.push("\u{1f7e2}")
      elsif colour == "B"
        translated.push("\u{1f535}")
      elsif colour == "P"
        translated.push("\u{1f7e3}")
      end
    end
    translated
  end

end

class Player 
  attr_accessor :score

  def initialize(score=0)
    @score = score
  end
end

class Codemaker < Player

  def generate_code(board)
    char_code = []
    for i in (0..3)
      random_int = rand(0..5)
      colour = board.allowable_moves[random_int]
      char_code.push(colour)
      i += 1
    end
    code = board.translate_input(char_code)
    code
  end

  def set_code(board)
    code = generate_code(board)
    # puts code
    board.update_code(code)
  end

  def give_feedback(board, round)
    puts "\n"
    dummy_code = []
    board.code_board.each {|colour| dummy_code.push(colour)}
    dummy_guess = []
    current_guess = board.get_current_round(round)
    current_guess.each { |colour| dummy_guess.push(colour) }
    # puts "DUMMY CODE BEFORE: #{dummy_code}"
    # puts "DUMMY GUESS BEFORE: #{dummy_guess}"
    current_guess.each_with_index do |val, i|
      # puts "RED GUESS: #{val}"
      # puts "RED I: #{i}"
      if val == dummy_code[i]
        # puts "RED".colorize(:red)
        board.update_hint(round, "\u{1f534}")
        dummy_code[i] = ""
        dummy_guess[i] = "."
        # puts "DUMMY CODE AFTER RED: #{dummy_code}".colorize(:red)
        # puts "DUMMY GUESS AFTER RED: #{dummy_guess}".colorize(:red)
      end
    end
    dummy_guess.each_with_index do |val, i|
      # puts "WHITE GUESS: #{val}"
      # puts "WHITE I: #{i}"
      if dummy_code.any?(val)
        # puts "WHITE".colorize(:green)
        board.update_hint(round, "\u{26aa}")
        dummy_code[dummy_code.index(val)] = ""
        # puts "DUMMY CODE AFTER WHITE: #{dummy_code}".colorize(:green)
        # puts "DUMMY GUESS AFTER WHITE: #{dummy_guess}".colorize(:green)

      end
    end
    # puts "DUMMY CODE AFTER: #{dummy_code}"
  end
end

class Codebreaker < Player
  
  def make_guess(board, round)
    puts "\n"
    puts "Valid colours are red, green, blue, yellow, orange and purple."
    puts "\n"
    puts "An example input would be 'rgby' for red, green, blue, yellow"
    puts "\n"
    puts "Enter 4 characters that correspond to a colour (r for red, b for blue etc.)"
    puts "\n"
    guess_string = gets.chomp
    guess = guess_string.upcase.delete(' ').split('')
    if check_guess(guess, board) != false
      new_guess = board.translate_input(guess)
      board.update_board(round, new_guess)
    else
      puts "Invalid entry. Please only enter allowed colours."
      make_guess(board, round)
    end
  end

  def check_guess(guess, board)
    if guess.size != 4
      false
    elsif guess.all? { |colour| board.allowable_moves.any?(colour) } == false
      false
    end
  end

end

class Game
  attr_accessor :round
  def initialize
    @round = 0
    board = Board.new
    human = Codebreaker.new
    cpu = Codemaker.new
    start_game(cpu, board, human, @round)
  end

  def start_game(cpu, board, human, round)
    cpu.set_code(board)
    puts "Let's play Mastermind!"
    # sleep(1)
    puts "Human is the codebreaker"
    # sleep(1)
    puts "CPU is the codemaker"
    # sleep(1)
    puts "You have 12 rounds to guess the CPU's code"
    # sleep(1)
    puts "You'll recieve feedback after each guess"
    # sleep(1)
    while @round < 12
      play_round(human, cpu, board, @round)
      @round += 1
    end
    board.print_board
    puts "The code was #{board.code_board}"
    puts "You couldn't crack the code, machine wins!".colorize(:red)
  end

  def game_won?(board, round)
    board.guess_board[round] == board.code_board
  end

  def play_round(human, cpu, board, round)
    # puts "CODE: #{board.code_board}"
    puts "\n"
    puts "Round: #{@round + 1}"
    puts "\n"
    puts "Current Board: "
    puts "\n"
    board.print_board
    human.make_guess(board, round)
    cpu.give_feedback(board, round)
    if game_won?(board, round)
      board.print_board
      puts "You cracked the code, human wins!".colorize(:green)
      exit
    end
  end
end

Game.new


# current_guess.each_with_index do |guess, i|
#   if dummy_code.any?(guess)
#     if guess == dummy_code[i]
#       # puts "Red Peg".colorize(:red)
#       board.update_hint(round, "\u{1f534}")
#       # p board.peg_board[round]
#     else
#       # puts "White Peg"
#       board.update_hint(round, "\u{26aa}")
#     end
#     dummy_code[dummy_code.index(guess)] = ""
#   end
# end