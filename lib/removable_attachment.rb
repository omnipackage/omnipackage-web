# frozen_string_literal: true

module RemovableAttachment
  def removable_attachment(attribute)
    class_exec(attribute) do |attr|
      after_save -> { public_send(attr).purge_later }, if: -> { v = public_send(:"_remove_#{attr}"); v == '1' || v == true }

      attr_accessor :"_remove_#{attr}"
    end
  end
end
