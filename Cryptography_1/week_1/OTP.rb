require_relative "ciphers"
require 'minitest/autorun'

class String

  def from_hex_number_to_char
    raise "Hex sequence is of length different from 2" unless length == 2
    hex.chr
  end

  def from_hex_string_to_string
    raise "Hex string not even length" unless length.even? 
    scan(/../).map {|hx| hx.from_hex_number_to_char}.join("")
  end

  def xor(hx)
    raise "xoring hexes of different length" unless length = hx.length
    (to_i(16) ^ hx.to_i(16)).to_s(16).rjust(length, "0")
  end

  def to_hex
    split("").map {|c| c.unpack('H*')}.join("")
  end

end

def make_same_lengths(c1, c2)
  c1_len, c2_len = c1.length, c2.length
  c1 = c1[0..c2_len-1] if c1_len >= c2_len
  c2 = c2[0..c1_len-1] if c2_len >= c1_len
  [c1, c2]
end


class TestMeme < MiniTest::Unit::TestCase
  def test_hex_to_char
    assert_equal "63".from_hex_number_to_char, "c"
    assert_equal "53".from_hex_number_to_char, "S"
    assert_equal "2c".from_hex_number_to_char, ","
  end
  def test_hex_to_string
    assert_equal "63727970746f2069732068617264".from_hex_string_to_string, "crypto is hard"
  end
  def test_xoring
    assert_equal "0e0b12150d15", "63727970746f".xor("6d796b65797a")
  end
  def test_length
    c11, c22 = make_same_lengths("1234", "5678910")
    assert_equal c11, "1234"
    assert_equal c22, "5678"
  end
  def test_to_hex
    assert_equal "63727970746f", "crypto".to_hex
  end
end


def crib_drag(cipher1, cipher2, word)
  c1, c2 = make_same_lengths(cipher1, cipher2)
  c1_xor_c2 = c1.xor(c2)

  word_hex = word.to_hex
  j = word_hex.length
  c1_xor_c2.each_char.with_index do |c, i| 
    sub = c1_xor_c2[i..i+j-1]
    if sub.length == j
      sub_xor_word_hex = sub.xor(word_hex)
      result = sub_xor_word_hex.from_hex_string_to_string
      unless result  =~ /[^a-zA-Z0-9 ,\.:;-]/
        p result 
      end
    end
  end
end

crib_drag(TARGET, C7, "the secret message is: When using a stream cipher, never use the key more than once")
