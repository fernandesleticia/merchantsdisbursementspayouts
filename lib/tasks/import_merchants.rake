# frozen_string_literal: true

namespace :merchants do
  desc "Import Merchants"

  task :import, [:csvfile] => [:environment] do |_task, args|
    merchants_csv_file_path = args[:csvfile]

    validates_csv_file_path(merchants_csv_file_path)

    MerchantCsvImporter.new(input_csv_file: merchants_csv_file_path).run
  end

  private

  def validates_csv_file_path(file_path)
    raise "You must specify the csv file path\n\nSyntax: bin/rake merchants:import[/tmp/merchants.csv]\n\n" if file_path.blank?

    return if File.exist?(file_path)

    raise "\n\nCSV file not found in #{file_path}\n\n\n" 
  end
end
