# frozen_string_literal: true

class BaseCsvImporter
  BATCH_SIZE = 20
  COMMON_DELIMITERS = ['","', '";"', "\"\t\""].freeze

  attr_accessor :input_csv_file, :result_output_stream
  
  def initialize(input_csv_file: nil)
    @input_csv_file = input_csv_file
  end

  def sniff_column_separator(path)
    first_line = File.open(path).first
    return unless first_line
  
    snif = {}
    COMMON_DELIMITERS.each do |delim| 
      snif[delim] = first_line.count(delim)
    end
    snif = snif.sort { |a,b| b[1]<=>a[1] }
  
    snif[0][0][1] if snif.size > 0
  end

  def run
    run_time = Time.current.strftime("%Y-%m-%d_%H%M%S")
    @result_output_stream = File.open("/tmp/result-#{run_time}.csv", "w")
    @batch= []
    result_output_stream.write(result_output_stream_header)

    col_sep = sniff_column_separator(input_csv_file)

    CSV.foreach(input_csv_file, headers: true, encoding: "ISO-8859-1", col_sep: col_sep).with_index do |row|
      next if row.to_hash.keys.count.zero?
      @batch << row
      process_batch if @batch.count == BATCH_SIZE
    end

    process_batch if @batch.any?
  ensure
    @result_output_stream.close
  end

  def write_dot(batch_with_error)
    $stdout.write(batch_with_error ? "E" : ".")
    $stdout.flush
  end

  def validates_data(row)
    return if valid_row?(row)

    raise StandardError, "Data missing"
  end

  def result_output_stream_header
    CSV.generate_line(["error", "batch", "row"])
  end

  def log(error, batch, row: nil)
    result_output_stream.write(
      CSV.generate_line(
        [
          error,
          batch.map(&:to_h),
          row.to_h
        ]
      )
    )
  end
end
