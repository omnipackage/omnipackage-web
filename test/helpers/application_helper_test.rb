require 'test_helper'

class ApplicationHelperTest < ::ActionView::TestCase
  test 'dom_friendly' do
    assert_equal 'ololo', dom_friendly('OlOlo')
    assert_equal '-------123----', dom_friendly('Превед 123 аыв')
    assert_equal '-script-alert--pwned-----script-', dom_friendly('<script>alert("pwned");</script>')
  end
end
