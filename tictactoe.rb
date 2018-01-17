INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                 [1, 4, 7], [2, 5, 8], [3, 6, 9],
                 [1, 5, 9], [3, 5, 7]]

def joinor(array, delimiter=', ', last_delimiter='or')
  delimited_string = ''
  if array.length > 1
    array.each_with_index do |value, index|
      if index <= array.length - 2
        delimited_string << value.to_s << delimiter
      else
        delimited_string << "#{last_delimiter} " << value.to_s
      end
    end
  else
    delimited_string = array.first.to_s
  end

  delimited_string
end

def prompt(msg)
  print "=> #{msg}"
end

# rubocop: disable Metrics/MethodLength, Metrics/AbcSize
def display_board(board)
  system 'clear'
  puts "Player  : #{PLAYER_MARKER}"
  puts "Computer: #{COMPUTER_MARKER}"
  puts ""
  puts "     |     |"
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}"
  puts "     |     |"
  puts ""
end
# rubocop: enable Metrics/MethodLength, Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(board)
  board.keys.select { |num| board[num] == INITIAL_MARKER }
end

def count_markers(board, line, marker)
  board.values_at(*line).count(marker)
end

def winning_line?(board, line)
  count_markers(board, line, COMPUTER_MARKER) == 2 &&
    count_markers(board, line, PLAYER_MARKER) == 0
end

def winning_line_available?(board)
  WINNING_LINES.each do |line|
    return true if winning_line?(board, line)
  end

  false
end

def winning_square(board)
  winning_line = []
  WINNING_LINES.each do |line|
    winning_line = line if winning_line?(board, line)
  end

  winning_line.each do |square|
    return square if board[square] != COMPUTER_MARKER
  end
end

def line_at_risk?(board, line)
  count_markers(board, line, PLAYER_MARKER) == 2 &&
    count_markers(board, line, COMPUTER_MARKER) == 0
end

def need_defense?(board)
  WINNING_LINES.each do |line|
    return true if line_at_risk?(board, line)
  end

  false
end

def defensive_square(board)
  line_at_risk = []
  WINNING_LINES.each do |line|
    line_at_risk = line if line_at_risk?(board, line)
  end

  line_at_risk.each do |square|
    return square if board[square] != PLAYER_MARKER
  end
end

def player_places_piece!(board)
  square = nil
  loop do
    prompt "Choose a square (#{joinor(empty_squares(board))}): "
    square = gets.chomp.to_i

    break if empty_squares(board).include?(square)
    prompt "Sorry, that's not a valid choice.\n"
  end

  board[square] = PLAYER_MARKER
end

def computer_places_piece!(board)
  square = if winning_line_available?(board)
             winning_square(board)
           elsif need_defense?(board)
             defensive_square(board)
           else
             empty_squares(board).sample
           end

  board[square] = COMPUTER_MARKER
end

def place_piece!(board, current_player)
  if current_player == "Player"
    player_places_piece!(board)
  else
    computer_places_piece!(board)
  end
end

def alternate_player!(current_player)
  if current_player == "Player"
    current_player.sub!("Player", "Computer")
  else
    current_player.sub!("Computer", "Player")
  end
end

def someone_won?(board)
  !!detect_winner(board)
end

def board_full?(board)
  empty_squares(board).empty?
end

def detect_winner(board)
  WINNING_LINES.each do |line|
    if count_markers(board, line, PLAYER_MARKER) == 3
      return 'Player'
    elsif count_markers(board, line, COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end

  nil
end

loop do
  score = { 'Player' => 0, 'Computer' => 0 }
  answer = nil

  loop do
    board = initialize_board
    current_player = "Player"

    loop do
      display_board(board)

      place_piece!(board, current_player)
      alternate_player!(current_player)
      break if someone_won?(board) || board_full?(board)
    end

    display_board(board)

    if someone_won?(board)
      prompt "#{detect_winner(board)} won!\n"
      score[detect_winner(board)] += 1
      break if score['Player'] == 5 || score['Computer'] == 5
    else
      prompt "It's a draw!\n"
    end

    prompt "[SCORE] Player: #{score['Player']} | Computer: #{score['Computer']}\n"

    loop do
      prompt "Play again? (Y/N) > "
      answer = gets.chomp

      break if answer.downcase.start_with?('y', 'n')
      prompt "Invalid response.\n"
    end

    break if answer.downcase.start_with?('n')
  end

  break if answer.downcase.start_with?('n')

  prompt "The #{score.key(5)} won the match!\n"

  loop do
    prompt "Another match? (Y/N) > "
    answer = gets.chomp

    break if %w(y n).include?(answer.downcase[0])
    prompt "Invalid response.\n"
  end

  break if answer.downcase.start_with?('n')
end

prompt "See you later!\n"
