# frozen_string_literal: true

%w[tar gpg xz].each do |b|
  raise "please install #{b}" unless system("#{b} --version &> /dev/null")
end
