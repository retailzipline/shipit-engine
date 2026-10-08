# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  LOCAL_HOSTS = %w[localhost 127.0.0.1 ::1].freeze
  LOCAL_PATTERNS = [/\A10\./, /\A172\.(1[6-9]|2\d|3[01])\./, /\A192\.168\./].freeze

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    begin
      uri = URI.parse(value.to_s)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        record.errors.add(attribute, :invalid, **options.except(:no_local, :allow_blank))
        return
      end

      if options[:no_local] && local_host?(uri.host)
        record.errors.add(attribute, :invalid, **options.except(:no_local, :allow_blank))
      end
    rescue URI::InvalidURIError
      record.errors.add(attribute, :invalid, **options.except(:no_local, :allow_blank))
    end
  end

  private

  def local_host?(host)
    return true if host.nil?
    LOCAL_HOSTS.include?(host) || LOCAL_PATTERNS.any? { |pat| pat.match?(host) }
  end
end
