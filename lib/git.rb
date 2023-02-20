# frozen_string_literal: true

class Git
  attr_reader :exe

  def initialize(exe: 'git')
    @exe = exe
  end

  def ping(repo)
    
  end
end
