# Copyright (c) 2009-2015 Tim Serong <tserong@suse.com>
# See COPYING for license.

class Profile < Tableless
  class << self
    def available_languages
      @available_languages ||= begin
        languages = YAML.load_file(
          Rails.root.join(
            'config',
            'languages.yml'
          ).to_s
        )

        result = FastGettext.available_locales.map do |locale|
          [
            locale.to_s.dasherize,
            languages[locale]
          ]
        end.sort_by { |v| v.first.to_s }

        ActiveSupport::OrderedHash[result]
      end
    end

    def current_language
      cur = I18n.locale.to_s.dasherize
      available_languages.each do |lang, name|
        return name if lang == cur
      end
      I18n.locale
    end
  end

  attribute :language, String, default: I18n.locale.to_s.dasherize

  attribute :stonithwarning, Boolean, default: true

  validates :language,
    presence: {
      message: _('is required')
    },
    inclusion: {
      in: available_languages.keys,
      message: "not a valid language"
    }

  def new_record?
    false
  end

  def persisted?
    true
  end

  protected

  def persist!
    true
  end
end
