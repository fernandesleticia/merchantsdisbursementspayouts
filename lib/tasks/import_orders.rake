# frozen_string_literal: true

namespace :orders do
  desc "Import Orders"

  task :import, [:csvfile] => [:environment] do |_task, args|
    orders_csv_file_path = args[:csvfile]

    validates_csv_file_path(orders_csv_file_path)

    OrderCsvImporter.new(input_csv_file: orders_csv_file_path).run
  end

  private

  def validates_csv_file_path(file_path)
    raise "You must specify the csv file path\n\nSyntax: bin/rake orders:import[/tmp/orders.csv]\n\n" if file_path.blank?

    return if File.exist?(file_path)

    raise "\n\nCSV file not found in #{file_path}\n\n\n" 
  end
end
