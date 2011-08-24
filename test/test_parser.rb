require 'test/unit'
require 'pp'
require 'parser'
require 'core_ext'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = Kobanashi::Parser.new nil
    Kobanashi::Binding::TopLevelVariableBinding.undef_all_references
    Kobanashi::Binding::TopLevelConstantBinding.undef_all_references
    Kobanashi::Binding::TopLevelConstantBinding.bind(Kobanashi::Binding::ROOT_OBJECT_NAME, KobanashiClass.new)
    Kobanashi::Binding::TopLevelConstantBinding.bind(Kobanashi::Binding::TRUE_CONSTANT_NAME, true)
    Kobanashi::Binding::TopLevelConstantBinding.bind(Kobanashi::Binding::FALSE_CONSTANT_NAME, false)
  end
  
  def evaluate(source)
    @parser.parse(source).evaluate
  end
  
  def assert_evaluate(expected, source)
    assert_equal expected, evaluate(source)
  end
  
  def test_simple
    assert_evaluate "い"[0], <<-end_of_code
      『あいうえお』の、2番目。
    end_of_code
    
    assert_evaluate "あいうえおかきくけこ", <<-end_of_code
      『あいうえお』に、『かきくけこ』を繋ぐ。
    end_of_code
    
    assert_evaluate true, <<-end_of_code
      『あいうえお』は、『あい』を含む？。
    end_of_code
    
    assert_evaluate false, <<-end_of_code
      『あいうえお』は、『ほげ』を含む？。
    end_of_code
    
    assert_evaluate "あホゲいうえお", <<-end_of_code
      『あいうえお』の、2番目に、『ホゲ』を挿入する。
    end_of_code
    
    assert_evaluate "要素３", <<-end_of_code
      [『要素１』・『要素２』・『要素３』] の、2番目。
    end_of_code
  end
  
  def test_it_that
    assert_evaluate "あホゲいうえおかきくけこ", <<-end_of_code
      『あいうえお』の、2番目に、『ホゲ』を挿入する。それ に、『かきくけこ』を繋ぐ。
    end_of_code
    
    assert_evaluate "あホゲいうえおかきくけこあホゲいうえお", <<-end_of_code
      『あいうえお』の、2番目に、『ホゲ』を挿入する。
      それ に、『かきくけこ』を繋ぐ。
      それ に、あれ を繋ぐ。
    end_of_code
    
    assert_evaluate 38, <<-end_of_code
      『あいうえお』の、2番目に、『ホゲ』を挿入する。
      それ に、『かきくけこ』を繋ぐ。
      それ に、あれ を繋ぐ。
      それ の文字数。
    end_of_code
    
    assert_evaluate 138, <<-end_of_code
      『あいうえお』の、2番目に、『ホゲ』を挿入する。
      それ に、『かきくけこ』を繋ぐ。
      それ に、あれ を繋ぐ。
      それ の文字数。
      それ に、100を足す。
    end_of_code
    
  end
  
  def test_refer
    assert_evaluate "ほげばー", <<-end_of_code
      hoge ← 『ほげ』。
      hoge に、『ばー』を繋ぐ。
    end_of_code
    
    assert_evaluate "ほげばー", <<-end_of_code
      hoge は 『ほげ』。
      hoge に、『ばー』を繋ぐ。
    end_of_code
    
    assert_evaluate "ば"[0], <<-end_of_code
      hoge ← 『ほげ』。
      hoge に、『ばー』を繋ぐ。
      hoge の、2番目。
    end_of_code
    
    assert_evaluate "ば"[0], <<-end_of_code
      hoge は 『ほげ』。
      hoge に、『ばー』を繋ぐ。
      hoge の、2番目。
    end_of_code
  end
  
  def test_complex
    assert_evaluate 110, <<-end_of_code
      『あいうえお』 の文字数 に、100 を足す。
    end_of_code
  end
  
  def test_ignore_conjunction
    assert_evaluate 138, <<-end_of_code
      『あいうえお』の、2番目に、『ホゲ』を挿入する。
      加えて、それ に、『かきくけこ』を繋ぐ。
      さらに、それ に、あれ を繋ぐ。
      最後に、それ の文字数 に、100を足す。
    end_of_code
  end
  
  def test_def_class
    evaluate(<<-end_of_code)
      <<もの>> の亜種として、 <アカウント> を作り、
      『ユーザー番号 金額』をその個体の性質、
      『アカウント数』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
    end_of_code
    
    new_class = Kobanashi::Binding::TopLevelConstantBinding.evaluate("アカウント")
    assert_not_nil new_class
    assert_instance_of KobanashiClass, new_class
    assert_equal "アカウント".to_sym, new_class.class_name
    assert_equal "もの".to_sym, new_class.super_class.class_name
    assert_equal 2, new_class.instance_variable_names.size
    assert(new_class.instance_variable_names.include?("ユーザー番号"))
    assert(new_class.instance_variable_names.include?("金額"))
    assert_equal 1, new_class.class_variable_names.size
    assert(new_class.class_variable_names.include?("アカウント数"))
    assert_equal "銀行アプリケーション".to_sym, new_class.category
    
    evaluate(<<-end_of_code)
      <<アカウント>> の亜種として、 <マイアカウント> を作り、
      『』をその個体の性質、
      『』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
    end_of_code
    
    new_class = Kobanashi::Binding::TopLevelConstantBinding.evaluate("マイアカウント")
    assert_not_nil new_class
    assert_instance_of KobanashiClass, new_class
    assert_equal "マイアカウント".to_sym, new_class.class_name
    assert_equal "アカウント".to_sym, new_class.super_class.class_name
    assert_equal 0, new_class.instance_variable_names.size
    assert_equal 0, new_class.class_variable_names.size
    assert_equal "銀行アプリケーション".to_sym, new_class.category
    
    assert_evaluate "アカウント".to_sym ,<<-end_of_code
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント の種名。
    end_of_code
  end
  
  def test_def_method
    assert_evaluate 110 ,<<-end_of_code
      <<もの>> の亜種として、 <アカウント> を作り、
      『ユーザー番号 金額』をその個体の性質、
      『アカウント数』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<アカウント>> にメソッド、『で、(引数１)と、(引数２)を足す』 を定義し、
      「引数１ に、 引数２ を足す。」を処理する。
      
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント で、10 と、 100 を足す。
    end_of_code
    
    # メソッドの引数はブロック内でも渡せる
    assert_evaluate 90 ,<<-end_of_code
      <<アカウント>> にメソッド、『で、から、を引く』 を定義し、
      「(引数１・引数２) 引数１ から、引数２ を引く。」を処理する。
    
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント で、100 から、 10 を引く。
    end_of_code
    
    assert_evaluate 9999, <<-end_of_code
      <<アカウント>> にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<アカウント>> にメソッド、『の金額』 を定義し、
      「金額。」を処理する。
      
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント の金額を、9999円に設定する。
      マイアカウント の金額。
    end_of_code
  end
  
  def test_inherite
    assert_evaluate 10000 ,<<-end_of_code
      <<もの>> の亜種として、 <アカウント> を作り、
      『金額』をその個体の性質、
      『』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<アカウント>> にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<アカウント>> にメソッド、『の金額』 を定義し、
      「金額。」を処理する。
      
      <<アカウント>> の亜種として、 <マイアカウント> を作り、
      『マイ金額』をその個体の性質、
      『』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<マイアカウント>> にメソッド、『のマイ金額を、(数値) 円に設定する』 を定義し、
      「マイ金額 ← 数値。」を処理する。
      
      <<マイアカウント>> にメソッド、『のマイ金額』 を定義し、
      「マイ金額。」を処理する。
      
      <<マイアカウント>> にメソッド、『の金額合計』 を定義し、
      「マイ金額 と、金額 を足す。」を処理する。
      
      マイアカウント ← <<マイアカウント>> を生成する。
      マイアカウント の金額を、9999円に設定する。  (^_^) ＜ 親クラスのメソッドを呼び出して親クラスのインスタンス変数を設定
      マイアカウント のマイ金額を、1円に設定する。 (^_^) ＜ 自分のメソッドを呼び出して自分のインスタンス変数を設定
      マイアカウント の金額合計。                  (^_^) ＜ 親クラスのインスタンス変数と自分のインスタンス変数を使用するメソッドを実行
    end_of_code
  end
  
  def test_self
    assert_evaluate 0 ,<<-end_of_code
      <<もの>> の亜種として、 <アカウント> を作り、
      『金額』をその個体の性質、
      『』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<アカウント>> にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<アカウント>> にメソッド、『の金額を零円に設定する』 を定義し、
      「私 の金額を、 0 円に設定する。」を処理する。
      
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント の金額を零円に設定する。
    end_of_code
      
    assert_evaluate 0 ,<<-end_of_code
      <<アカウント>> にメソッド、『の金額をゼロ円に設定する』 を定義し、
      「わたし の金額を零円に設定する。」を処理する。
      
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント の金額をゼロ円に設定する。
    end_of_code
      
    assert_evaluate 0 ,<<-end_of_code
      <<アカウント>> にメソッド、『の金額を０円に設定する』 を定義し、
      「ボク の金額をゼロ円に設定する。」を処理する。
      
      マイアカウント ← <<アカウント>> を生成する。
      マイアカウント の金額を０円に設定する。
    end_of_code
  end
  
  def test_super
    assert_evaluate 100 ,<<-end_of_code
      <<もの>> の亜種として、 <アカウント> を作り、
      『金額』をその個体の性質、
      『』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<アカウント>> にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<アカウント>> にメソッド、『の金額』 を定義し、
      「金額。」を処理する。
      
      <<アカウント>> の亜種として、 <マイアカウント> を作り、
      『マイ金額』をその個体の性質、
      『』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<マイアカウント>> にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<マイアカウント>> にメソッド、『の親の金額を、(数値) 円に設定する』 を定義し、
      「親 の金額を、 数値 円に設定する。」を処理する。
      
      マイアカウント ← <<マイアカウント>> を生成する。
      マイアカウント の金額を、100 円に設定する。
      マイアカウント の親の金額を、1000 円に設定する。
      マイアカウント の金額。
    end_of_code
  end
  
  def test_def_class_method
    assert_evaluate 100 ,<<-end_of_code
      <<もの>> の亜種として、 <アカウント> を作り、
      『金額』をその個体の性質、
      『金額』をその種の性質、
      『銀行アプリケーション』をそのカテゴリとする。
      
      <<アカウント>> にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<アカウント>> にメソッド、『の金額』 を定義し、
      「金額。」を処理する。

      <<アカウント>> の種にメソッド、『の金額を、(数値) 円に設定する』 を定義し、
      「金額 ← 数値。」を処理する。
      
      <<アカウント>> の種にメソッド、『の金額』 を定義し、
      「金額。」を処理する。
      
      マイアカウント は <<アカウント>> を生成する。
      マイアカウント の金額を、1 円に設定する。
      マイアカウント の種 の金額を、100 円に設定する。
      マイアカウント の種 の金額。
    end_of_code
    assert_evaluate 10 ,<<-end_of_code
      マイアカウント の金額を、10 円に設定する。
      マイアカウント の金額。
    end_of_code
    assert_evaluate 100 ,<<-end_of_code
      マイアカウント の種 の金額。
    end_of_code
  end
  
  def test_block
    block = evaluate("「10 に、 1 を足す。」。")
    assert_equal 11, block.call
    
    block = evaluate("「() 10 に、 1 を足す。」。")
    assert_equal 11, block.call
    
    block = evaluate("「(数値１・数値２) 数値１ に、 数値２ を足す。」。")
    assert_equal 11, block.call(10, 1)
    
    block = evaluate <<-end_of_code
    「(数値１・数値２) 
       val1 ← 数値１。
       val2 ← 数値２。
       val1 に、 val2 を足す。
       それ に、 100 を足す。
     」。
    end_of_code
    
    assert_equal 111, block.call(10, 1)
    
    assert_evaluate 110, <<-end_of_code
      足して10を掛けるブロック ← 「(数値１・数値２) 数値１ に、 数値２ を足す。それ に、10 を掛ける。」。
      足して10を掛けるブロック を、10 と、 1 で実行する。
    end_of_code
  end
  
  def test_condition
    assert_evaluate 10, <<-end_of_code
      <<本当>> が本当なら、「10。」を実行する。
    end_of_code
    
    assert_evaluate 10, <<-end_of_code
      <<本当>> が本当なら、「10。」を実行して誤りなら、「-10。」を実行する。
    end_of_code
    
    assert_evaluate nil, <<-end_of_code
      <<誤り>> が本当なら、「10。」を実行する。
    end_of_code
    
    assert_evaluate -10, <<-end_of_code
      <<誤り>> が本当なら、「10。」を実行して誤りなら、「-10。」を実行する。
    end_of_code
    
    assert_evaluate 10, <<-end_of_code
      結果 は <<本当>>。
      結果 が本当なら、「10。」を実行する。
    end_of_code
  end
  
  def test_condition
    assert_evaluate "10文字ですね", <<-end_of_code
      「<<本当>>。」 が本当なら、「『10文字ですね』。」を実行する。
    end_of_code
    
    assert_evaluate "10文字ですね", <<-end_of_code
      「『あいうえお』の文字数 が、10 に等しい。」 が本当なら、「『10文字ですね』。」を実行する。
    end_of_code
  end
  
  def test_loop
    assert_evaluate "ああああああああああ", <<-end_of_code
      文字列 は 『』。
      10 回、「文字列 は 文字列 と、『あ』の連結。」を繰り返す。
      文字列。
    end_of_code
    
    assert_evaluate "0123456789", <<-end_of_code
      文字列 は 『』。
      10 回、「(数値) 数字 は 数値 の文字列表現。文字列 は 文字列 と、数字 の連結。」を繰り返す。
      文字列。
    end_of_code
    
    assert_evaluate "0123456789", <<-end_of_code
      文字列 は 『』。
      10 回、「(数値) 文字列 は 文字列 と、( 数値 の文字列表現 ) の連結。」を繰り返す。
      文字列。
    end_of_code
    
    assert_evaluate "あああああ", <<-end_of_code
      文字列 は 『』。
      「文字列 の文字数 が、10 より小さい。」が本当の間、「文字列 は 文字列 と、『あ』の連結。」を繰り返す。
      文字列。
    end_of_code
    
    assert_evaluate "あああああ", <<-end_of_code
      文字列 は 『』。
      「文字列 の文字数 が、10 に等しい。」が誤りの間、「文字列 は 文字列 と、『あ』の連結。」を繰り返す。
      文字列。
    end_of_code
    
    assert_evaluate "あああああ", <<-end_of_code
      文字列 は 『』。
      「文字列 の文字数 が、10 以上。」が誤りの間、「文字列 は 文字列 と、『あ』の連結。」を繰り返す。
      文字列。
    end_of_code
  end
  
  def test_examples
    result = evaluate <<-end_of_code
<<もの>> の亜種として、 <じゃんけん> を作る。
<<じゃんけん>> にメソッド、『ほいっ、(あなたの手) と』 を定義し、
「私の手 は [0・1・2] のいずれか。
  結果 は あなたの手 と、私の手 の差。
  「結果 が、 0 と等しい。」
  なら、
    「『引き分け』。」
  そうじゃないなら、
    「「結果 が、 1 と等しい または、(結果 が、 -2 と等しい) が成り立つ。」
      なら、
        「『あなたの勝ち』。」
      そうじゃないなら、
        「「結果 が、 -1 と等しい または、(結果 が、 2 と等しい) が成り立つ。」
          なら、
           「『あなたの負け』。」
          を実行する。
         」
      を実行する。
    」
  を実行する。
」を処理する。

じゃんけん は <<じゃんけん>> を生成する。
じゃんけん ほいっ、 1 と。
    end_of_code
    assert ['引き分け', 'あなたの勝ち', 'あなたの負け'].include? result
  end
end
