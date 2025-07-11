require 'net/http'
require 'json'
require 'uri'

class PagesController < ApplicationController

  def new
    vowels = Array.new(3) { ['A', 'E', 'I', 'O', 'U'].sample }
    consonants = Array.new(7) { (('A'..'Z').to_a - vowels).sample }
    @generated_letters = (vowels + consonants).shuffle
    # raise
  end

  def score
    @word = params[:word].upcase
    @generated_letter = params[:letters]
    @response = check_work_validity(@word, @generated_letter)
    # raise
  end

  def check_work_validity(word, letters)
    @valid = word.chars.tally.all? { |char, count| letters.count(char) >= count }
    return @valid ? check_word_is_in_api(@word) : work_is_invalid(word, letters)
  end

  def work_is_invalid(word, letters)
    return "Sorry but '#{@word}' can't be built out of #{letters.chars.join().gsub(" ",", ")}"
  end

  def check_word_is_in_api(word)
      url = URI.parse("https://dictionary.lewagon.com/#{word}")
      response = Net::HTTP.get_response(url)
      return nil unless response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      @found = data['found'].to_s
    return @found == "true" ? "Congratulations! #{word} is a valid English word!" : "Sorry but #{word} does not seem to be avalid English word..."
  end
end
