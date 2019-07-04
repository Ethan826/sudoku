# frozen_string_literal: true

require 'pry'

class Sudoku # rubocop:disable Style/Documentation
  def initialize(game = Array.new(81))
    @game = game
  end

  def valid?
    binding.pry
  end

  def complete?
    game.all?
  end

  private

  attr_reader :game

  def row_iterator
    (0..8).map { |row| (0..8).map { |col| row * 9 + col } }
  end

  def col_iterator
    (0..8).map { |col| (0..8).map { |row| row * 9 + col } }
  end

  def square_iterator # rubocop:disable Metrics/MethodLength
    (0..2).flat_map do |big_row_counter|
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
