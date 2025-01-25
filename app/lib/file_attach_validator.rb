class FileAttachValidator < ::ActiveModel::Validator
  include ::ActionView::Helpers::NumberHelper

  def validate(record)
    attributes.each do |attribute, attribute_options|
      perform_validation(attribute_options, record.public_send(attribute)) do |error_message|
        record.errors.add(attribute, error_message)
      end
    end
  end

  private

  def attributes
    options.fetch(:attributes)
  end

  def perform_validation(attribute_options, value)
    return unless value.attached?

    max_size_bytes = attribute_options.fetch(:max_size_bytes)
    mime_type_regex = attribute_options.fetch(:mime_type_regex)

    if value.blob.byte_size > max_size_bytes
      value.purge
      yield("too big, max size is #{number_to_human_size(max_size_bytes)}")
    elsif !value.blob.content_type.match?(mime_type_regex)
      value.purge
      yield("wrong format, must match #{mime_type_regex.inspect}")
    end
  end
end
