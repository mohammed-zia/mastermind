# frozen_string_literal: true

require 'colorize'

# We'll make a class from which we'll create our board object
class Board
  @@guess_board =
                  [
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  '],
                    ['  ', '  ', '  ', '  ']
                  ]
  @@code_board = ['', '', '', '']
  @@peg_board =
                [
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  '],
                  ['  ', '  ', '  ', '  ']
                ]

  attr_accessor :guess_board, :peg_board

  attr_reader :code_board, :allowable_moves

  def initialize
    @code_board = @@code_board
    @guess_board = @@guess_board
    @peg_board = @@peg_board
    @allowable_moves = %w[R G B P Y O]
  end

  def print_board
    puts '-----+-GUESSES-+----++----+--HINTS--+----+'
    (0..11).each do |i|
      puts "| #{@guess_board[i][0]} | #{@guess_board[i][1]} | #{@guess_board[i][2]} | #{@guess_board[i][3]} || #{@peg_board[i][0]} : #{@peg_board[i][1]} : #{@peg_board[i][2]} : #{@peg_board[i][3]} :"
      puts '-----+----+----+----++----+----+----+----+'
    end
  end

  def update_code(code)
    @code_board = code
  end

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
      elsif colour == 'O'
        translated.push("\u{1f7e0}")
      elsif colour == 'Y'
        translated.push("\u{1f7e1}")
      elsif colour == 'G'
        translated.push("\u{1f7e2}")
      elsif colour == 'B'
        translated.push("\u{1f535}")
      elsif colour == 'P'
        translated.push("\u{1f7e3}")
      end
    end
    translated
  end
end

# Our player class to keep track of score
class Player
  attr_accessor :score

  def initialize(score = 0)
    @score = score
  end
end

# We need a codemaker class that inherits from player
class Codemaker < Player
  def generate_code(board)
    char_code = []
    4.times do
      random_int = rand(0..5)
      colour = board.allowable_moves[random_int]
      char_code.push(colour)
    end
    board.translate_input(char_code)
  end

  def set_code(board)
    code = generate_code(board)
    board.update_code(code)
  end

  def give_feedback(board, round)
    puts "\n"
    dummy_code = []
    board.code_board.each {|colour| dummy_code.push(colour)}
    dummy_guess = []
    current_guess = board.get_current_round(round)
    current_guess.each { |colour| dummy_guess.push(colour) }
    current_guess.each_with_index do |val, i|
      if val == dummy_code[i]
        board.update_hint(round, "\u{1f534}")
        dummy_code[i] = ''
        dummy_guess[i] = '.'
      end
    end
    dummy_guess.each do |val|
      if dummy_code.any?(val)
        board.update_hint(round, "\u{26aa}")
        dummy_code[dummy_code.index(val)] = ''
      end
    end
  end
end

# We need a class for the codebreaker that inherits from player
class Codebreaker < Player
  def make_guess(board, round)
    puts "\n"
    puts 'Valid colours are red, green, blue, yellow, orange and purple.'
    puts "\n"
    puts "An example input would be 'rgby' for red, green, blue, yellow"
    puts "\n"
    puts 'Enter 4 characters that correspond to a colour (r for red, b for blue etc.)'
    puts "\n"
    guess_string = gets.chomp
    guess = guess_string.upcase.delete(' ').split('')
    if check_guess(guess, board) != false
      new_guess = board.translate_input(guess)
      board.update_board(round, new_guess)
    else
      puts 'Invalid entry. Please only enter allowed colours.'.colorize(:red)
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

# Our class to keep track of the game instance
class Game
  attr_accessor :round

  def initialize
    @round = 0
    board = Board.new
    human = Codebreaker.new
    cpu = Codemaker.new
    start_game(cpu, board, human)
  end

  def start_game(cpu, board, human)
    cpu.set_code(board)
    puts "Let's play Mastermind!"
    sleep(1)
    puts 'Human is the codebreaker'
    sleep(1)
    puts 'CPU is the codemaker'
    sleep(1)
    puts "You have 12 rounds to guess the CPU's code"
    sleep(1)
    puts "You'll recieve feedback after each guess"
    sleep(1)
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
    puts "\n"
    puts "Round: #{@round + 1}"
    puts "\n"
    puts 'Current Board: '
    puts "\n"
    board.print_board
    human.make_guess(board, round)
    cpu.give_feedback(board, round)
    if game_won?(board, round)
      board.print_board
      puts 'You cracked the code, human wins!'.colorize(:green)
      exit
    end
  end
end

Game.new
