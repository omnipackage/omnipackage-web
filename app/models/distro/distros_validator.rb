class Distro
  class DistrosValidator < ::ActiveModel::Validator
    def validate(record)
      attributes.each do |attribute|
        validate_distro_ids(record.public_send(attribute)) do |error_message|
          record.errors.add(attribute, error_message)
        end
      end
    end

    private

    def attributes
      options[:attributes] || %i[distro_ids]
    end

    def validate_distro_ids(distro_ids)
      yield("must be combination of #{::Distro.ids}") if distro_ids && (distro_ids - ::Distro.ids).any?
    end
  end
end
