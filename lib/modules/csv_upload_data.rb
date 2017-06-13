require 'charlock_holmes'
module CsvUploadData
  def initialize_stats
    @number_of_rows = File.foreach(@path).count - 1
    @number_of_rows_failed, @errors =
      if @headers.errors.any?
        [@number_of_rows, @headers.errors.merge(type: :headers)]
      else
        [0, {}]
      end
  end

  def process
    return if @headers.errors.any?
    detection = CharlockHolmes::EncodingDetector.detect(File.read(@path))
    CSV.open(
      @path, 'r', headers: true, encoding: detection[:encoding]
    ).each.with_index(2) do |row, row_no|
      process_row(row, row_no)
    end
  end

  def value_for(row, property_name)
    row[@headers.actual_index_for_property(property_name)]
  end

  def matching_object(object_collection, object_type, identification, errors)
    if object_collection.count > 1
      errors[object_type] = "More than one #{object_type} found \
(#{identification})"
      nil
    elsif object_collection.count.zero?
      errors[object_type] = "#{object_type.capitalize} does not exist \
(#{identification})"
      nil
    else
      object_collection.first
    end
  end
end
