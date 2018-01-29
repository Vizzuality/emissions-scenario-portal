class TimeSeriesValue < ApplicationRecord
  belongs_to :scenario, counter_cache: true
  belongs_to :indicator, counter_cache: true
  belongs_to :location

  validates(
    :year,
    presence: true,
    numericality: {only_integer: true, allow_nil: true},
    inclusion: {in: 1900..3000, allow_nil: true},
    uniqueness: {scope: %i[scenario_id indicator_id location_id]}
  )
  validates(
    :value,
    presence: true,
    numericality: {allow_nil: true}
  )
  validates(
    :unit,
    inclusion: {in: ->(tsv) { [tsv.indicator&.unit, tsv.note&.unit_of_entry].compact }}
  )
  before_save :convert_units

  attr_writer :unit

  def note
    return unless scenario.present? && indicator.present?
    Note.find_by(model_id: scenario.model_id, indicator_id: indicator.id)
  end

  def unit
    @unit || indicator&.unit || note&.unit_of_entry
  end

  private

  def convert_units
    if @unit.present? && @unit != indicator&.unit && @unit == note&.unit_of_entry
      # don't touch value and unit if invalid value given to ensure
      # that validations messages are intact
      value = read_attribute_before_type_cast(:value).to_d
      self.value = value * note.conversion_factor
      @unit = nil
    end
  rescue ArgumentError
  end
end
