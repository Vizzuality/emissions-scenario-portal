require 'charlock_holmes'

module EncodingDetection
  def encoding(path)
    encoding_detection = CharlockHolmes::EncodingDetector.detect(
      File.read(path)
    )
    encoding_detection[:encoding]
  end
end
