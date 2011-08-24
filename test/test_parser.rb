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
    assert_evaluate "��"[0], <<-end_of_code
      �w�����������x�́A2�ԖځB
    end_of_code
    
    assert_evaluate "��������������������", <<-end_of_code
      �w�����������x�ɁA�w�����������x���q���B
    end_of_code
    
    assert_evaluate true, <<-end_of_code
      �w�����������x�́A�w�����x���܂ށH�B
    end_of_code
    
    assert_evaluate false, <<-end_of_code
      �w�����������x�́A�w�ق��x���܂ށH�B
    end_of_code
    
    assert_evaluate "���z�Q��������", <<-end_of_code
      �w�����������x�́A2�ԖڂɁA�w�z�Q�x��}������B
    end_of_code
    
    assert_evaluate "�v�f�R", <<-end_of_code
      [�w�v�f�P�x�E�w�v�f�Q�x�E�w�v�f�R�x] �́A2�ԖځB
    end_of_code
  end
  
  def test_it_that
    assert_evaluate "���z�Q������������������", <<-end_of_code
      �w�����������x�́A2�ԖڂɁA�w�z�Q�x��}������B���� �ɁA�w�����������x���q���B
    end_of_code
    
    assert_evaluate "���z�Q���������������������z�Q��������", <<-end_of_code
      �w�����������x�́A2�ԖڂɁA�w�z�Q�x��}������B
      ���� �ɁA�w�����������x���q���B
      ���� �ɁA���� ���q���B
    end_of_code
    
    assert_evaluate 38, <<-end_of_code
      �w�����������x�́A2�ԖڂɁA�w�z�Q�x��}������B
      ���� �ɁA�w�����������x���q���B
      ���� �ɁA���� ���q���B
      ���� �̕������B
    end_of_code
    
    assert_evaluate 138, <<-end_of_code
      �w�����������x�́A2�ԖڂɁA�w�z�Q�x��}������B
      ���� �ɁA�w�����������x���q���B
      ���� �ɁA���� ���q���B
      ���� �̕������B
      ���� �ɁA100�𑫂��B
    end_of_code
    
  end
  
  def test_refer
    assert_evaluate "�ق��΁[", <<-end_of_code
      hoge �� �w�ق��x�B
      hoge �ɁA�w�΁[�x���q���B
    end_of_code
    
    assert_evaluate "�ق��΁[", <<-end_of_code
      hoge �� �w�ق��x�B
      hoge �ɁA�w�΁[�x���q���B
    end_of_code
    
    assert_evaluate "��"[0], <<-end_of_code
      hoge �� �w�ق��x�B
      hoge �ɁA�w�΁[�x���q���B
      hoge �́A2�ԖځB
    end_of_code
    
    assert_evaluate "��"[0], <<-end_of_code
      hoge �� �w�ق��x�B
      hoge �ɁA�w�΁[�x���q���B
      hoge �́A2�ԖځB
    end_of_code
  end
  
  def test_complex
    assert_evaluate 110, <<-end_of_code
      �w�����������x �̕����� �ɁA100 �𑫂��B
    end_of_code
  end
  
  def test_ignore_conjunction
    assert_evaluate 138, <<-end_of_code
      �w�����������x�́A2�ԖڂɁA�w�z�Q�x��}������B
      �����āA���� �ɁA�w�����������x���q���B
      ����ɁA���� �ɁA���� ���q���B
      �Ō�ɁA���� �̕����� �ɁA100�𑫂��B
    end_of_code
  end
  
  def test_def_class
    evaluate(<<-end_of_code)
      <<����>> �̈���Ƃ��āA <�A�J�E���g> �����A
      �w���[�U�[�ԍ� ���z�x�����̌̂̐����A
      �w�A�J�E���g���x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
    end_of_code
    
    new_class = Kobanashi::Binding::TopLevelConstantBinding.evaluate("�A�J�E���g")
    assert_not_nil new_class
    assert_instance_of KobanashiClass, new_class
    assert_equal "�A�J�E���g".to_sym, new_class.class_name
    assert_equal "����".to_sym, new_class.super_class.class_name
    assert_equal 2, new_class.instance_variable_names.size
    assert(new_class.instance_variable_names.include?("���[�U�[�ԍ�"))
    assert(new_class.instance_variable_names.include?("���z"))
    assert_equal 1, new_class.class_variable_names.size
    assert(new_class.class_variable_names.include?("�A�J�E���g��"))
    assert_equal "��s�A�v���P�[�V����".to_sym, new_class.category
    
    evaluate(<<-end_of_code)
      <<�A�J�E���g>> �̈���Ƃ��āA <�}�C�A�J�E���g> �����A
      �w�x�����̌̂̐����A
      �w�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
    end_of_code
    
    new_class = Kobanashi::Binding::TopLevelConstantBinding.evaluate("�}�C�A�J�E���g")
    assert_not_nil new_class
    assert_instance_of KobanashiClass, new_class
    assert_equal "�}�C�A�J�E���g".to_sym, new_class.class_name
    assert_equal "�A�J�E���g".to_sym, new_class.super_class.class_name
    assert_equal 0, new_class.instance_variable_names.size
    assert_equal 0, new_class.class_variable_names.size
    assert_equal "��s�A�v���P�[�V����".to_sym, new_class.category
    
    assert_evaluate "�A�J�E���g".to_sym ,<<-end_of_code
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̎햼�B
    end_of_code
  end
  
  def test_def_method
    assert_evaluate 110 ,<<-end_of_code
      <<����>> �̈���Ƃ��āA <�A�J�E���g> �����A
      �w���[�U�[�ԍ� ���z�x�����̌̂̐����A
      �w�A�J�E���g���x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�ŁA(�����P)�ƁA(�����Q)�𑫂��x ���`���A
      �u�����P �ɁA �����Q �𑫂��B�v����������B
      
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �ŁA10 �ƁA 100 �𑫂��B
    end_of_code
    
    # ���\�b�h�̈����̓u���b�N���ł��n����
    assert_evaluate 90 ,<<-end_of_code
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�ŁA����A�������x ���`���A
      �u(�����P�E�����Q) �����P ����A�����Q �������B�v����������B
    
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �ŁA100 ����A 10 �������B
    end_of_code
    
    assert_evaluate 9999, <<-end_of_code
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z�x ���`���A
      �u���z�B�v����������B
      
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���A9999�~�ɐݒ肷��B
      �}�C�A�J�E���g �̋��z�B
    end_of_code
  end
  
  def test_inherite
    assert_evaluate 10000 ,<<-end_of_code
      <<����>> �̈���Ƃ��āA <�A�J�E���g> �����A
      �w���z�x�����̌̂̐����A
      �w�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z�x ���`���A
      �u���z�B�v����������B
      
      <<�A�J�E���g>> �̈���Ƃ��āA <�}�C�A�J�E���g> �����A
      �w�}�C���z�x�����̌̂̐����A
      �w�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�}�C�A�J�E���g>> �Ƀ��\�b�h�A�w�̃}�C���z���A(���l) �~�ɐݒ肷��x ���`���A
      �u�}�C���z �� ���l�B�v����������B
      
      <<�}�C�A�J�E���g>> �Ƀ��\�b�h�A�w�̃}�C���z�x ���`���A
      �u�}�C���z�B�v����������B
      
      <<�}�C�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���v�x ���`���A
      �u�}�C���z �ƁA���z �𑫂��B�v����������B
      
      �}�C�A�J�E���g �� <<�}�C�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���A9999�~�ɐݒ肷��B  (^_^) �� �e�N���X�̃��\�b�h���Ăяo���Đe�N���X�̃C���X�^���X�ϐ���ݒ�
      �}�C�A�J�E���g �̃}�C���z���A1�~�ɐݒ肷��B (^_^) �� �����̃��\�b�h���Ăяo���Ď����̃C���X�^���X�ϐ���ݒ�
      �}�C�A�J�E���g �̋��z���v�B                  (^_^) �� �e�N���X�̃C���X�^���X�ϐ��Ǝ����̃C���X�^���X�ϐ����g�p���郁�\�b�h�����s
    end_of_code
  end
  
  def test_self
    assert_evaluate 0 ,<<-end_of_code
      <<����>> �̈���Ƃ��āA <�A�J�E���g> �����A
      �w���z�x�����̌̂̐����A
      �w�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���~�ɐݒ肷��x ���`���A
      �u�� �̋��z���A 0 �~�ɐݒ肷��B�v����������B
      
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���~�ɐݒ肷��B
    end_of_code
      
    assert_evaluate 0 ,<<-end_of_code
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���[���~�ɐݒ肷��x ���`���A
      �u�킽�� �̋��z���~�ɐݒ肷��B�v����������B
      
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���[���~�ɐݒ肷��B
    end_of_code
      
    assert_evaluate 0 ,<<-end_of_code
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���O�~�ɐݒ肷��x ���`���A
      �u�{�N �̋��z���[���~�ɐݒ肷��B�v����������B
      
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���O�~�ɐݒ肷��B
    end_of_code
  end
  
  def test_super
    assert_evaluate 100 ,<<-end_of_code
      <<����>> �̈���Ƃ��āA <�A�J�E���g> �����A
      �w���z�x�����̌̂̐����A
      �w�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z�x ���`���A
      �u���z�B�v����������B
      
      <<�A�J�E���g>> �̈���Ƃ��āA <�}�C�A�J�E���g> �����A
      �w�}�C���z�x�����̌̂̐����A
      �w�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�}�C�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�}�C�A�J�E���g>> �Ƀ��\�b�h�A�w�̐e�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u�e �̋��z���A ���l �~�ɐݒ肷��B�v����������B
      
      �}�C�A�J�E���g �� <<�}�C�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���A100 �~�ɐݒ肷��B
      �}�C�A�J�E���g �̐e�̋��z���A1000 �~�ɐݒ肷��B
      �}�C�A�J�E���g �̋��z�B
    end_of_code
  end
  
  def test_def_class_method
    assert_evaluate 100 ,<<-end_of_code
      <<����>> �̈���Ƃ��āA <�A�J�E���g> �����A
      �w���z�x�����̌̂̐����A
      �w���z�x�����̎�̐����A
      �w��s�A�v���P�[�V�����x�����̃J�e�S���Ƃ���B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�A�J�E���g>> �Ƀ��\�b�h�A�w�̋��z�x ���`���A
      �u���z�B�v����������B

      <<�A�J�E���g>> �̎�Ƀ��\�b�h�A�w�̋��z���A(���l) �~�ɐݒ肷��x ���`���A
      �u���z �� ���l�B�v����������B
      
      <<�A�J�E���g>> �̎�Ƀ��\�b�h�A�w�̋��z�x ���`���A
      �u���z�B�v����������B
      
      �}�C�A�J�E���g �� <<�A�J�E���g>> �𐶐�����B
      �}�C�A�J�E���g �̋��z���A1 �~�ɐݒ肷��B
      �}�C�A�J�E���g �̎� �̋��z���A100 �~�ɐݒ肷��B
      �}�C�A�J�E���g �̎� �̋��z�B
    end_of_code
    assert_evaluate 10 ,<<-end_of_code
      �}�C�A�J�E���g �̋��z���A10 �~�ɐݒ肷��B
      �}�C�A�J�E���g �̋��z�B
    end_of_code
    assert_evaluate 100 ,<<-end_of_code
      �}�C�A�J�E���g �̎� �̋��z�B
    end_of_code
  end
  
  def test_block
    block = evaluate("�u10 �ɁA 1 �𑫂��B�v�B")
    assert_equal 11, block.call
    
    block = evaluate("�u() 10 �ɁA 1 �𑫂��B�v�B")
    assert_equal 11, block.call
    
    block = evaluate("�u(���l�P�E���l�Q) ���l�P �ɁA ���l�Q �𑫂��B�v�B")
    assert_equal 11, block.call(10, 1)
    
    block = evaluate <<-end_of_code
    �u(���l�P�E���l�Q) 
       val1 �� ���l�P�B
       val2 �� ���l�Q�B
       val1 �ɁA val2 �𑫂��B
       ���� �ɁA 100 �𑫂��B
     �v�B
    end_of_code
    
    assert_equal 111, block.call(10, 1)
    
    assert_evaluate 110, <<-end_of_code
      ������10���|����u���b�N �� �u(���l�P�E���l�Q) ���l�P �ɁA ���l�Q �𑫂��B���� �ɁA10 ���|����B�v�B
      ������10���|����u���b�N ���A10 �ƁA 1 �Ŏ��s����B
    end_of_code
  end
  
  def test_condition
    assert_evaluate 10, <<-end_of_code
      <<�{��>> ���{���Ȃ�A�u10�B�v�����s����B
    end_of_code
    
    assert_evaluate 10, <<-end_of_code
      <<�{��>> ���{���Ȃ�A�u10�B�v�����s���Č��Ȃ�A�u-10�B�v�����s����B
    end_of_code
    
    assert_evaluate nil, <<-end_of_code
      <<���>> ���{���Ȃ�A�u10�B�v�����s����B
    end_of_code
    
    assert_evaluate -10, <<-end_of_code
      <<���>> ���{���Ȃ�A�u10�B�v�����s���Č��Ȃ�A�u-10�B�v�����s����B
    end_of_code
    
    assert_evaluate 10, <<-end_of_code
      ���� �� <<�{��>>�B
      ���� ���{���Ȃ�A�u10�B�v�����s����B
    end_of_code
  end
  
  def test_condition
    assert_evaluate "10�����ł���", <<-end_of_code
      �u<<�{��>>�B�v ���{���Ȃ�A�u�w10�����ł��ˁx�B�v�����s����B
    end_of_code
    
    assert_evaluate "10�����ł���", <<-end_of_code
      �u�w�����������x�̕����� ���A10 �ɓ������B�v ���{���Ȃ�A�u�w10�����ł��ˁx�B�v�����s����B
    end_of_code
  end
  
  def test_loop
    assert_evaluate "��������������������", <<-end_of_code
      ������ �� �w�x�B
      10 ��A�u������ �� ������ �ƁA�w���x�̘A���B�v���J��Ԃ��B
      ������B
    end_of_code
    
    assert_evaluate "0123456789", <<-end_of_code
      ������ �� �w�x�B
      10 ��A�u(���l) ���� �� ���l �̕�����\���B������ �� ������ �ƁA���� �̘A���B�v���J��Ԃ��B
      ������B
    end_of_code
    
    assert_evaluate "0123456789", <<-end_of_code
      ������ �� �w�x�B
      10 ��A�u(���l) ������ �� ������ �ƁA( ���l �̕�����\�� ) �̘A���B�v���J��Ԃ��B
      ������B
    end_of_code
    
    assert_evaluate "����������", <<-end_of_code
      ������ �� �w�x�B
      �u������ �̕����� ���A10 ��菬�����B�v���{���̊ԁA�u������ �� ������ �ƁA�w���x�̘A���B�v���J��Ԃ��B
      ������B
    end_of_code
    
    assert_evaluate "����������", <<-end_of_code
      ������ �� �w�x�B
      �u������ �̕����� ���A10 �ɓ������B�v�����̊ԁA�u������ �� ������ �ƁA�w���x�̘A���B�v���J��Ԃ��B
      ������B
    end_of_code
    
    assert_evaluate "����������", <<-end_of_code
      ������ �� �w�x�B
      �u������ �̕����� ���A10 �ȏ�B�v�����̊ԁA�u������ �� ������ �ƁA�w���x�̘A���B�v���J��Ԃ��B
      ������B
    end_of_code
  end
  
  def test_examples
    result = evaluate <<-end_of_code
<<����>> �̈���Ƃ��āA <����񂯂�> �����B
<<����񂯂�>> �Ƀ��\�b�h�A�w�ق����A(���Ȃ��̎�) �Ɓx ���`���A
�u���̎� �� [0�E1�E2] �̂����ꂩ�B
  ���� �� ���Ȃ��̎� �ƁA���̎� �̍��B
  �u���� ���A 0 �Ɠ������B�v
  �Ȃ�A
    �u�w���������x�B�v
  ��������Ȃ��Ȃ�A
    �u�u���� ���A 1 �Ɠ����� �܂��́A(���� ���A -2 �Ɠ�����) �����藧�B�v
      �Ȃ�A
        �u�w���Ȃ��̏����x�B�v
      ��������Ȃ��Ȃ�A
        �u�u���� ���A -1 �Ɠ����� �܂��́A(���� ���A 2 �Ɠ�����) �����藧�B�v
          �Ȃ�A
           �u�w���Ȃ��̕����x�B�v
          �����s����B
         �v
      �����s����B
    �v
  �����s����B
�v����������B

����񂯂� �� <<����񂯂�>> �𐶐�����B
����񂯂� �ق����A 1 �ƁB
    end_of_code
    assert ['��������', '���Ȃ��̏���', '���Ȃ��̕���'].include? result
  end
end
