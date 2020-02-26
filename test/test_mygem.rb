require 'minitest/autorun'  # 引进minitest
require 'cocoathin'

class Mygemtest < Minitest::Test

  def test_find_class
    path = ''
    puts Cocoathin::GemImp.find_class_imp(path)
  end

  def test_find_sel
    path = ''
    puts Cocoathin::GemImp.find_sel_imp(path)
  end

end
