class Task
  class Stat < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'
  end
end
