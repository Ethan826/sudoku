# frozen_string_literal: true

require 'pry'
require 'set'

class SudokuRules # rubocop:disable Style/Documentation
  def initialize(game = Array.new(81))
    @game = game
    @buffer = Set.new
  end

  def valid?
    [row_iterator, col_iterator, square_iterator].all? do |iterators|
      iterators.all? { |iterator| valid_group?(iterator) }
    end
  end

  def complete?
    game.all?
  end

  private

  attr_reader :game

  def valid_group?(iterator)
    @buffer.clear
    iterator.all? do |index|
      value = game[index]
      next true unless value

      @buffer.add?(value)
    end
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

test_game = Array.new(81)
test_game[0] = 0
test_game[7] = 1
puts Sudoku.new(test_game).valid?
