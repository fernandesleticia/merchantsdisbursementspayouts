#frozen_string_literal: true

namespace :disbursements do
  desc "Export Disbursements"

  task :export do
    DisbursementCsvExporter.new.run
  end
end
