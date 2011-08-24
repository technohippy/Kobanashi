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
    assert_segments_equal([[:LITERAL, 'abc']], parse("abc(^_^) ＜コメント"))
    assert_segments_equal([[:CHAR, 'あ']], parse('#あ'))
    assert_segments_equal([[:CHAR, '\#']], parse('#\#'))
  end
  
  def test_scan_complex
    assert_segments_equal([[:STRING, 'こんにちは世界'], [:LITERAL, "を"], [:TO_TEN, "、"], [:DNUMBER, "２"],
              [:LITERAL, "から"], [:TO_TEN, "、"], [:DNUMBER, "３"], [:LITERAL, "までコピーする"]],
             parse("『こんにちは世界』を、２ から、３ までコピーする"))
    assert_segments_equal([[:STRING, 'こんにちは世界'], [:LITERAL, "を"], [:TO_TEN, "、"], [:DNUMBER, "６"],
              [:LITERAL, "から"], [:TO_TEN, "、"], [:DNUMBER, "７"], [:LITERAL, "まで"], [:TO_TEN, "、"],
              [:STRING, '新世界'], [:LITERAL, "で置き換える"]],
             parse("『こんにちは世界』を、６から、７まで、『新世界』で置き換える"))

    assert_segments_equal([[:CHAR, "あ"], [:ARRAY_SEPARATOR, "・"], [:CHAR, "い"], [:ARRAY_SEPARATOR, "・"], 
              [:CHAR, "う"], [:LITERAL, "の"], [:TO_TEN, "、"], [:DNUMBER, "２"],
              [:LITERAL, "つ目"], [:KU_TEN, "。"]],
             parse("#あ・#い・#う の、２つ目。"))

    assert_segments_equal([[:CONSTANT, "もの"], [:LITERAL, "の亜種として"], [:TO_TEN, "、"], [:SYMBOL, "アカウント"], 
              [:LITERAL, "を作り"], [:TO_TEN, "、"], [:STRING, "ユーザー番号 金額"], 
              [:LITERAL, "をその個体の性質"], [:TO_TEN, "、"], [:STRING, ""], [:LITERAL, "をその種の性質"], 
              [:TO_TEN, "、"], [:STRING, "銀行アプリケーション"], [:LITERAL, "をそのカテゴリとする"], 
              [:KU_TEN, "。"]],
             parse("<<もの>> の亜種として、 <アカウント> を作り、『ユーザー番号 金額』をその個体の性質、『』
                    をその種の性質、『銀行アプリケーション』をそのカテゴリとする。"))
    assert_segments_equal([[:CONSTANT, "人間"], [:LITERAL, "を"], [:TO_TEN, "、"], [:STRING, '花子'], 
              [:LITERAL, "で初期化する"], [:KU_TEN, "。"], [:LITERAL, "それを"], [:TO_TEN, "、"], 
              [:LITERAL, "花子"], [:LITERAL, "と呼ぶ"], [:KU_TEN, "。"]],
             parse('<<人間>> を、『花子』で初期化する。それを、花子 と呼ぶ。'))
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "は偶数？"]],
             parse('3 は偶数？'))
    assert_segments_equal([[:START_ARRAY, "["], [:DNUMBER, "１"], [:ARRAY_SEPARATOR, "・"], [:DNUMBER, "２"], [:ARRAY_SEPARATOR, "・"],
              [:DNUMBER, "３"], [:END_ARRAY, "]"]],
             parse('[１・２・３]'))
    assert_segments_equal([[:START_HASH, "{"], [:LITERAL, "abc"], [:HASH_SEPARATOR, "→"], [:DNUMBER, "１"], [:ARRAY_SEPARATOR, "・"], 
              [:LITERAL, "def"], [:HASH_SEPARATOR, "→"], [:DNUMBER, "２"], [:ARRAY_SEPARATOR, "・"], [:LITERAL, "ghi"], 
              [:HASH_SEPARATOR, "→"], [:DNUMBER, "３"], [:END_HASH, "}"]],
             parse('{abc→１・def→２・ghi→３}'))
  end
  
  def test_scan_block
    assert_segments_equal([[:START_BLOCK, "「"], [:CHAR, "あ"], [:KU_TEN, "。"], [:CHAR, "い"], [:KU_TEN, "。"], [:END_BLOCK, "」"]],
             parse('「#あ。#い。」'))
    assert_segments_equal([[:START_BLOCK, "「"], [:START_BLOCK_ARGS, "("], [:LITERAL, "引数１"], [:ARRAY_SEPARATOR, "・"], 
                           [:LITERAL, "引数２"], [:END_BLOCK_ARGS, ")"], [:CHAR, "あ"], [:KU_TEN, "。"], [:CHAR, "い"], [:KU_TEN, "。"],
                           [:END_BLOCK, "」"]],
             parse('「(引数１・引数２) #あ。#い。」'))
  end
  
  def test_scan_regexp
    assert_segments_equal([[:REGEXP, "a{1,2}b+c*"]],
             parse('/a{1,2}b+c*/'))
  end
  
  def test_ignore_comment
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "は偶数？"]],
             parse('3 は偶数？ (^_^) ＜コメント'))
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "は偶数？"]],
             parse('3 は偶数？ ;;;コメント'))
    assert_segments_equal([[:NUMBER, "3"], [:LITERAL, "は偶数？"]],
             parse('3 は偶数？ ……コメント
                    コメント
                    ……。'))
  end
  
  def test_true_false
    assert_segments_equal([[:CONSTANT, "本当"], [:LITERAL, "が本当なら"], [:TO_TEN, "、"],
                           [:NUMBER, "10"], [:LITERAL, "を実行する"], [:KU_TEN, "。"]],
             parse('<<本当>> が本当なら、10 を実行する。'))

    assert_segments_equal([[:CONSTANT, "誤り"], [:LITERAL, "が本当なら"], [:TO_TEN, "、"],
                           [:NUMBER, "10"], [:LITERAL, "を実行する"], [:KU_TEN, "。"]],
             parse('<<誤り>> が本当なら、10 を実行する。'))
  end
end
