require 'test/unit'
require 'scan'

class TestScan < Test::Unit::TestCase
  def assert_segments_equal(array, segments)
    array.each_with_index do |expected, index|
      assert_equal expected[0], segments[index][0]
      assert_equal expected[1], segments[index][1].value
    end
    assert_equal array.size, segments.size
  end

  def parse(str)
    Kobanashi::Scanner.new.scan str
  end
  
  def test_scan_literal
    assert_segments_equal([[:LITERAL, 'abc']], parse('abc'))
    assert_segments_equal([[:LITERAL, 'abc']], parse("abc(^_^) ���R�����g"))
    assert_segments_equal([[:CHAR, '��']], parse('#��'))
    assert_segments_equal([[:CHAR, '\#']], parse('#\#'))
  end
  
  def test_scan_complex
    assert_segments_equal([[:STRING, '����ɂ��͐��E'], [:LITERAL, "��"], [:TO_TEN, "�A"], [:DNUMBER, "�Q"],
              [:LITERAL, "����"], [:TO_TEN, "�A"], [:DNUMBER, "�R"], [:LITERAL, "�܂ŃR�s�[����"]],
             parse("�w����ɂ��͐��E�x���A�Q ����A�R �܂ŃR�s�[����"))
    assert_segments_equal([[:STRING, '����ɂ��͐��E'], [:LITERAL, "��"], [:TO_TEN, "�A"], [:DNUMBER, "�U"],
              [:LITERAL, "����"], [:TO_TEN, "�A"], [:DNUMBER, "�V"], [:LITERAL, "�܂�"], [:TO_TEN, "�A"],
              [:STRING, '�V���E'], [:LITERAL, "�Œu��������"]],
             parse("�w����ɂ��͐��E�x���A�U����A�V�܂ŁA�w�V���E�x�Œu��������"))

    assert_segments_equal([[:CHAR, "��"], [:ARRAY_SEPARATOR, "�E"], [:CHAR, "��"], [:ARRAY_SEPARATOR, "�E"], 
              [:CHAR, "��"], [:LITERAL, "��"], [:TO_TEN, "�A"], [:DNUMBER, "�Q"],
              [:LITERAL, "��"], [:KU_TEN, "�B"]],
             parse("#���E#���E#�� �́A�Q�ځB"))

    assert_segments_equal([[:CONSTANT, "����"], [:LITERAL, "�̈���Ƃ���"], [:TO_TEN, "�A"], [:SYMBOL, "�A�J�E���g"], 
              [:LITERAL, "�����"], [:TO_TEN, "�A"], [:STRING, "���[�U�[�ԍ� ���z"], 
              [:LITERAL, "�����̌̂̐���"], [:TO_TEN, "�A"], [:STRING, ""], [:LITERAL, "�����̎�̐���"], 
              [:TO_TEN, "�A"], [:STRING, "��s�A�v���P�[�V����"], [:LITERAL, "�����̃J�e�S���Ƃ���"], 
              [:KU_TEN, "�B"]],
             parse("<<����>> �̈���Ƃ��āA <�A�J�E���g> �����A�w���[�U�[�ԍ� ���z�x�����̌̂̐����A�w�x
                    �����̎�̐����A�w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B"))
    assert_segments_equal([[:CONSTANT, "�l��"], [:LITERAL, "��"], [:TO_TEN, "�A"], [:STRING, '�Ԏq'], 
              [:LITERAL, "�ŏ���������"], [:KU_TEN, "�B"], [:LITERAL, "�����"], [:TO_TEN, "�A"], 
              [:LITERAL, "�Ԏq"], [:LITERAL, "�ƌĂ�"], [:KU_TEN, "�B"]],
             parse('<<�l��>> ���A�w�Ԏq�x�ŏ���������B������A�Ԏq �ƌĂԁB'))
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "�͋����H"]],
             parse('3 �͋����H'))
    assert_segments_equal([[:START_ARRAY, "["], [:DNUMBER, "�P"], [:ARRAY_SEPARATOR, "�E"], [:DNUMBER, "�Q"], [:ARRAY_SEPARATOR, "�E"],
              [:DNUMBER, "�R"], [:END_ARRAY, "]"]],
             parse('[�P�E�Q�E�R]'))
    assert_segments_equal([[:START_HASH, "{"], [:LITERAL, "abc"], [:HASH_SEPARATOR, "��"], [:DNUMBER, "�P"], [:ARRAY_SEPARATOR, "�E"], 
              [:LITERAL, "def"], [:HASH_SEPARATOR, "��"], [:DNUMBER, "�Q"], [:ARRAY_SEPARATOR, "�E"], [:LITERAL, "ghi"], 
              [:HASH_SEPARATOR, "��"], [:DNUMBER, "�R"], [:END_HASH, "}"]],
             parse('{abc���P�Edef���Q�Eghi���R}'))
  end
  
  def test_scan_block
    assert_segments_equal([[:START_BLOCK, "�u"], [:CHAR, "��"], [:KU_TEN, "�B"], [:CHAR, "��"], [:KU_TEN, "�B"], [:END_BLOCK, "�v"]],
             parse('�u#���B#���B�v'))
    assert_segments_equal([[:START_BLOCK, "�u"], [:START_BLOCK_ARGS, "("], [:LITERAL, "�����P"], [:ARRAY_SEPARATOR, "�E"], 
                           [:LITERAL, "�����Q"], [:END_BLOCK_ARGS, ")"], [:CHAR, "��"], [:KU_TEN, "�B"], [:CHAR, "��"], [:KU_TEN, "�B"],
                           [:END_BLOCK, "�v"]],
             parse('�u(�����P�E�����Q) #���B#���B�v'))
  end
  
  def test_scan_regexp
    assert_segments_equal([[:REGEXP, "a{1,2}b+c*"]],
             parse('/a{1,2}b+c*/'))
  end
  
  def test_ignore_comment
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "�͋����H"]],
             parse('3 �͋����H (^_^) ���R�����g'))
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "�͋����H"]],
             parse('3 �͋����H ;;;�R�����g'))
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "�͋����H"]],
             parse('3 �͋����H �c�c�R�����g
                    �R�����g
                    �c�c�B'))
  end
  
  def test_true_false
    assert_segments_equal([[:CONSTANT, "�{��"], [:LITERAL, "���{���Ȃ�"], [:TO_TEN, "�A"],
                           [:NUMBER, "10"], [:LITERAL, "�����s����"], [:KU_TEN, "�B"]],
             parse('<<�{��>> ���{���Ȃ�A10 �����s����B'))

    assert_segments_equal([[:CONSTANT, "���"], [:LITERAL, "���{���Ȃ�"], [:TO_TEN, "�A"],
                           [:NUMBER, "10"], [:LITERAL, "�����s����"], [:KU_TEN, "�B"]],
             parse('<<���>> ���{���Ȃ�A10 �����s����B'))
  end
end
