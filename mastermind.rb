require 'colorize'
require 'set'

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
    puts "\n"
    puts "\n"
    puts "\n"
    puts "\n"
    puts "\n"
    puts "\n"
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

  def update_hint_arr(round, hint)
    hint.each do |colour|
      @peg_board[round].unshift(colour)
    end
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

  def check_guess(guess, board)
    if guess.size != 4
      false
    elsif guess.all? { |colour| board.allowable_moves.any?(colour) } == false
      false
    end
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
  def set_code(board, code)
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

class ComputerCodemaker < Codemaker
  def generate_code(board)
    char_code = []
    4.times do
      random_int = rand(0..5)
      colour = board.allowable_moves[random_int]
      char_code.push(colour)
    end
    board.translate_input(char_code)
  end
end

class HumanCodemaker < Codemaker
  def human_secret_code(board)
    puts "\n"
    puts 'Enter a secret code for the CPU to guess'
    puts "\n"
    puts 'Valid colours are red, green, blue, yellow, orange and purple.'
    puts "\n"
    puts "An example input would be 'rgby' for red, green, blue, yellow"
    puts "\n"
    puts 'Enter 4 characters that correspond to a colour (r for red, b for blue etc.)'
    puts "\n"
    code_string = gets.chomp
    code = code_string.upcase.delete(' ').split('')
    if board.check_guess(code, board) != false
      board.translate_input(code)
    else
      puts 'Invalid entry. Please only enter allowed colours.'.colorize(:red)
      human_secret_code(board)
    end
  end
end

# We need a class for the codebreaker that inherits from player
class HumanCodebreaker
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
    if board.check_guess(guess, board) != false
      new_guess = board.translate_input(guess)
      board.update_board(round, new_guess)
    else
      puts 'Invalid entry. Please only enter allowed colours.'.colorize(:red)
      make_guess(board, round)
    end
  end
end

# Our class to keep track of the game instance
class ComputerCodemakerGame
  attr_accessor :round

  def initialize
    @round = 0
    board = Board.new
    human = HumanCodebreaker.new
    cpu = ComputerCodemaker.new
    start_game(cpu, board, human)
  end

  def start_game(cpu, board, human)
    code = cpu.generate_code(board)
    cpu.set_code(board, code)
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

class ComputerCodebreaker
  def initialize
    puts " \u{1f9e0} CPU training algorithm..."
    colors = "123456".chars
    @all_answers = colors.product(*[colors] * 3).map(&:join)
    @all_scores = Hash.new { |h, k| h[k] = {} }
    @board = Board.new
    @all_answers.product(@all_answers).each do |guess, answer|
      @all_scores[guess][answer] = calculate_score(guess, answer)
    end
    @all_answers = @all_answers.to_set
    play
  end

  def translate_input_to_num(code)
    num_arr = []
    code.each do |colour|
      if colour == 'R'
        num_arr.push("1")
      elsif colour == 'O'
        num_arr.push("2")
      elsif colour == 'Y'
        num_arr.push("3")
      elsif colour == 'G'
        num_arr.push("4")
      elsif colour == 'B'
        num_arr.push("5")
      elsif colour == 'P'
        num_arr.push("6")
      end
    end
    num_arr.join('')
  end

  def human_secret_code(board)
    sleep(1.5)
    puts "\n"
    puts 'Enter a secret code for the CPU to guess'
    puts "\n"
    sleep(1.5)
    puts "Valid colours are red, green, blue, yellow, orange and purple."
    puts "\n"
    sleep(1.5)
    puts "An example input would be 'rgby' for red, green, blue, yellow"
    puts "\n"
    sleep(1.5)
    puts 'Enter 4 characters that correspond to a colour (r for red, b for blue etc.)'
    puts "\n"
    code_string = gets.chomp
    code = code_string.upcase.delete(' ').split('')
    if board.check_guess(code, board) != false
      translate_input_to_num(code)
    else
      puts 'Invalid entry. Please only enter allowed colours.'.colorize(:red)
      human_secret_code(board)
    end
  end

  def make_guess
    if @guesses > 0
      @possible_answers.keep_if { |answer|
        @all_scores[@guess][answer] == @score 
      }
      guesses = @possible_scores.map do |guess, scores_by_answer|
        scores_by_answer = scores_by_answer.select { |answer, score| 
          @possible_answers.include?(answer)
        }
        @possible_scores[guess] = scores_by_answer
        score_groups = scores_by_answer.values.group_by(&:itself)
        possibility_counts = score_groups.values.map(&:length)
        worst_case_possibilities = possibility_counts.max
        impossible_guess = @possible_answers.include?(guess) ? 0 : 1
        [worst_case_possibilities, impossible_guess, guess]
      end

      guesses.min.last
    else
      "1122"
    end
  end

  def calculate_score(guess, answer)
    score = ""
    wrong_guess_pegs, wrong_answer_pegs = [], []
    peg_pairs = guess.chars.zip(answer.chars)

    peg_pairs.each do |guess_peg, answer_peg|
      if guess_peg == answer_peg
        score << "B"
      else
        wrong_guess_pegs << guess_peg
        wrong_answer_pegs << answer_peg
      end
    end
    wrong_guess_pegs.each do |peg|
      if wrong_answer_pegs.include?(peg)
        wrong_answer_pegs.delete(peg)
        score << "W"
      end
    end
    score
  end

  def transform_guess(guess)
    transformed = []
    guess = guess.split('')
    guess.each do |colour|
      if colour == '1'
        transformed.push("\u{1f534}")
      elsif colour == '2'
        transformed.push("\u{1f7e0}")
      elsif colour == '3'
        transformed.push("\u{1f7e1}")
      elsif colour == '4'
        transformed.push("\u{1f7e2}")
      elsif colour == '5'
        transformed.push("\u{1f535}")
      elsif colour == '6'
        transformed.push("\u{1f7e3}")
      end
    end
    transformed
  end

  def transform_score(score)
    transformed = []
    score_arr = score.split('')
    score_arr.each do |colour|
      if colour == "B"
        transformed.push("\u{1f534}")
      elsif colour == "W"
        transformed.push("\u{26aa}")
      end
    end
    transformed
  end

  def play
    @guesses=0
    @answer = human_secret_code(@board)
    @possible_scores = @all_scores.dup
    @possible_answers = @all_answers.dup
    puts "Let's play Mastermind!"
    sleep(1.5)
    puts 'Human is the codemaker'
    sleep(1.5)
    puts 'CPU is the codebreaker'
    sleep(1.5)
    puts "The CPU has 12 rounds to guess the human's code"
    sleep(1.5)
    puts 'The CPU will recieve feedback after each guess'
    sleep(1.5)
    while @guesses < 12
      @guess = make_guess
      if @all_answers.include?(@guess)
        @score = calculate_score(@guess, @answer)
        guess_arr_trans = transform_guess(@guess)
        score_arr_trans = transform_score(@score)
        @board.update_board(@guesses, guess_arr_trans)
        @board.update_hint_arr(@guesses, score_arr_trans)
        @board.print_board
        sleep(1.5)
        @guesses += 1
        if @score == 'BBBB'
          puts "CPU guessed your code in #{@guesses} guesses! Better luck next time..."
          break
        end
      end
    end
  end
end

def main
  puts 'Who will be the codebreaker; Computer or Human?'
  desired_codebreaker = gets.chomp
  cleaned_codebreaker = desired_codebreaker.upcase.delete(' ')
  if cleaned_codebreaker == 'HUMAN'
    ComputerCodemakerGame.new
  elsif cleaned_codebreaker == 'COMPUTER'
    ComputerCodebreaker.new
  else
    puts "Please enter either 'human' or 'computer'"
    main
  end
end

main
