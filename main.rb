# frozen_string_literal: true

require 'pry'
require 'set'

class Sudoku
  protected

  DIMENSION = 9

  TOP_THICK = '━'
  TOP_THIN = '─'
  SIDE_THICK = '┃'
  SIDE_THIN = '│'
  CORNER_BOTTOM_LEFT = '┗'
  CORNER_BOTTOM_RIGHT = '┛'
  CORNER_TOP_LEFT = '┏'
  CORNER_TOP_RIGHT = '┓'
  QUAD = '┼'
  INNER_BOTTOM = '┷'
  INNER_LEFT = '┠'
  INNER_TOP = '┯'
  INNER_RIGHT = '┨'
  TOP_ROW =    '┏━━━━━┯━━━━━┯━━━━━┓'
              # ┃1 1 1 1 1 1 1 1 1┃
  INNER_ROW =  '┠─────┼─────┼─────┨'
  BOTTOM_ROW = '┗━━━━━┷━━━━━┷━━━━━┛'

  # TOP_ROW = CORNER_TOP_LEFT + TOP_THICK * 17 + CORNER_TOP_RIGHT
  # BOTTOM_ROW = CORNER_BOTTOM_LEFT + BOTTOM_THICK * 17 + CORNER_BOTTOM_RIGHT

  def print_game(game)
    puts TOP_ROW

    game.each_slice(9).each_with_index do |row, index|
      print SIDE_THICK
      interior = row.each_slice(3).map do |chunk|
        chunk.map { |e| e || "·" }.join(" ")
      end.to_a.join(SIDE_THIN)
      print interior
      puts SIDE_THICK
      puts INNER_ROW if index == 2 || index == 5
    end

    puts BOTTOM_ROW
  end

  def row_iterator
    @row_iterator ||= (0..8).map { |row| (0..8).map { |col| row * 9 + col } }
  end

  def col_iterator
    @col_iterator ||= (0..8).map { |col| (0..8).map { |row| row * 9 + col } }
  end

  def square_iterator # rubocop:disable Metrics/MethodLength
    @square_iterator ||= (0..2).flat_map do |big_row_counter|
      big_row_start = big_row_counter * 27
      (0..2).map do |big_col_counter|
        big_square_start = big_col_counter * 3 + big_row_start
        (0..2).flat_map do |little_row_counter|
          little_row_start = little_row_counter * 9 + big_square_start
          (0..2).flat_map do |little_col_counter|
            little_row_start + little_col_counter
          end
        end
      end
    end
  end
end

class SudokuRules < Sudoku
  def initialize
    @buffer = Set.new
  end

  def win?(game)
    complete?(game) && valid?(game)
  end

  def valid?(game)
    [row_iterator, col_iterator, square_iterator].all? do |iterators|
      iterators.all? { |iterator| valid_group?(game, iterator) }
    end
  end

  def complete?(game)
    game.all?
  end

  private

  def valid_group?(game, iterator)
    @buffer.clear
    iterator.all? do |index|
      value = game[index]
      next true unless value

      @buffer.add?(value)
    end
  end
end

class SudokuSolver < Sudoku
  def initialize(rules = SudokuRules.new)
    @rules = rules
  end

  def solve(game)
    puts print_game(game)
    return [game] if rules.win?(game)
    return [] if rules.complete?(game)

    binding.pry
    next_frontier(game).flat_map { |g| solve(g) }
  end

  private

  attr_reader :rules

  def valid_next_states(chunk, game, iter)
    chunk_candidates(chunk).each_with_object([]) do |chunk, games|
      candidate = game.dup
      chunk.zip(iter).each { |(val, index)| candidate[index] = val }
      games << candidate if rules.valid?(candidate)
    end
  end

	def next_frontier(game)
    iter_kind, chunk_index = choose_chunk(game)
    iter = send(iter_kind)[chunk_index]
    chunk = iter.map { |i| game[i] }
    valid_next_states(chunk, game, iter)
	end

  def choose_chunk(game)
    iter_kind = :square_iterator
    chunk_index = send(iter_kind)
                  .each_with_index
                  .reduce([0, nil]) do |(best_count, best_index), (iter, index)|
      unfilled_count = DIMENSION - iter.map { |i| game[i] }.compact.length

      if unfilled_count &&
         unfilled_count < DIMENSION &&
         unfilled_count < best_count
        [unfilled_count, index]
      else
        [best_count, best_index]
      end
    end.first

    [iter_kind, chunk_index] if chunk_index
  end

  def unused_permutations(chunk)
    all_values = (1..9).to_set
    (all_values - chunk.compact.to_set).to_a.permutation
  end

  def chunk_candidates(chunk)
    unused_permutations(chunk).map do |to_add|
      chunk.each_with_object([]) do |existing_value, result|
        result << (existing_value || to_add.pop)
      end
    end
  end
end

GAME = [nil, nil, 5, nil, 1, nil, nil, nil, nil,
        nil, 2, 1, nil, nil, nil, nil, 8, nil,
        nil, nil, nil, 8, nil, 4, nil, 1, 6,
        nil, nil, 9, nil, 2, nil, 1, nil, nil,
        2, nil, nil, 1, nil, 7, nil, nil, nil,
        nil, nil, 7, nil, 6, nil, 8, nil, nil,
        9, 8, nil, 4, nil, 2, nil, nil, nil,
        nil, 3, nil, nil, nil, nil, 4, 7, nil,
        nil, nil, nil, nil, 9, nil, 6, nil, nil].freeze

SudokuSolver.new.solve(GAME)

__END__

SOLVED_GAME = [8, 4, 5, 2, 1, 6, 7, 9, 3,
               6, 2, 1, 7, 3, 9, 5, 8, 4,
               7, 9, 3, 8, 5, 4, 2, 1, 6,
               4, 5, 9, 3, 2, 8, 1, 6, 7,
               2, 6, 8, 1, 4, 7, 9, 3, 5,
               3, 1, 7, 9, 6, 5, 8, 4, 2,
               9, 8, 6, 4, 7, 2, 3, 5, 1,
               5, 3, 2, 6, 8, 1, 4, 7, 9,
               1, 7, 4, 5, 9, 3, 6, 2, 8].freeze
