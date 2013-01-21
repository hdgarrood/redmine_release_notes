# for validating the plugin's settings only
class ReleaseNotesSettings
  include ActiveModel::Validations

  validate do
    %w(not_required todo done).each do |val|
    end

    errors.add(:base, t('release_notes.config.format_not_exist')) \
      unless true # todo
  end

  # public constructor method is +find+ instead of +new+
  class << self
    private :new
    def find
      instance = new
      instance.update(Setting.plugin_redmine_release_notes)
      instance
    end

    # used in init.rb; if no record in settings table exists. Obviously this
    # won't work but that doesn't matter -- we just prompt admins to configure
    # it.
    def defaults
      {
        :custom_field_id => 0,
        :field_value_done => '',
        :field_value_todo => '',
        :field_value_not_required => '',
        :default_generation_format => 'HTML'
      }
    end
  end

  # the settings which we allow people to configure
  KEYS = %w(custom_field_id field_value_done field_value_todo
    field_value_not_required default_generation_format).map(&:to_sym)

  attr_accessor(*KEYS)

  # allows updating the object; designed to be used with the params object in
  # controllers
  def update(attrs = {})
    attrs.each {|k, v| send(:"#{k}=", v) }
  end

  def save
    if valid?
      Setting.plugin_redmine_release_notes = to_h
      true
    else
      false
    end
  end

  private
  # converts this instance to a hash; needed so that we can save
  def to_h
    # i love ruby
    Hash[self.class::KEYS.map { |k| [k, send(k)] } ]
  end
end
