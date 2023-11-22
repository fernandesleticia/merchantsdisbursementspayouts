# frozen_string_literal: true

require "rails_helper"

module Tasks
  RSpec.describe "Import Merchants" do
    Timecop.freeze do
      let(:result_file) { "/tmp/result-#{Time.current.strftime("%Y-%m-%d_%H%M%S")}.csv" }

      before do
        Rake.application.rake_require "tasks/import_merchants"
        Rake::Task.define_task(:environment)
      end

      before(:each) do
        Rake::Task["merchants:import"].reenable
        Timecop.freeze(2022, 1, 1, 0, 0, 0)
      end

      after(:each) do
        File.delete(result_file) if File.exist?(result_file)
        Timecop.return
      end

      describe "create merchants" do
        subject { Rake.application.invoke_task "merchants:import[spec/fixtures/files/merchants.csv]" }

        context "when CSV file is not found" do
          it "should raise an error" do
            expect {
              Rake.application.invoke_task "merchants:import[tmp/non_existent_file.csv]"
            }.to raise_error(RuntimeError) { |error|
              expect(error.message).to eq("\n\nCSV file not found in tmp/non_existent_file.csv\n\n\n")
            }
          end
        end

        context "when csv file path is not provided" do
          it "should raise an error" do
            expect {
              Rake.application.invoke_task "merchants:import"
            }.to raise_error(RuntimeError, "You must specify the csv file path\n\nSyntax: bin/rake merchants:import[/tmp/merchants.csv]\n\n")
          end
        end

        context "when data is missing" do
          before do
            CSV.open("spec/fixtures/files/merchants.csv", "w") do |merchants|
              merchants << %w[id reference email live_on disbursement_frequency minimum_monthly_fee]
              merchants << %w[86312006-4d7e-45c4-9c28-788f4aa68a62 padberg_group info@padberg-group.com 2023-02-01 DAILY 0.0]
              merchants << %w[d1649242-a612-46ba-82d8-225542bb9576 deckow_gibson info@deckow-gibson.com 2022-12-14 WEEKLY]
            end
          end

          it "should not raise an error" do
            expect { subject }.not_to raise_error
          end

          it "should log an error" do
            subject

            error_csv = CSV.open(result_file, "r")

            batch = [
              { "id"=> "86312006-4d7e-45c4-9c28-788f4aa68a62", "reference"=> "padberg_group", "email"=> "info@padberg-group.com", "live_on"=> "2023-02-01", "disbursement_frequency"=> "DAILY", "minimum_monthly_fee"=> "0.0" },
              { "id"=> "d1649242-a612-46ba-82d8-225542bb9576", "reference"=> "deckow_gibson", "email"=> "info@deckow-gibson.com", "live_on"=> "2022-12-14",  "disbursement_frequency"=> "WEEKLY", "minimum_monthly_fee"=> nil },
            ]

            row = { "id"=> "d1649242-a612-46ba-82d8-225542bb9576", "reference"=> "deckow_gibson", "email"=> "info@deckow-gibson.com", "live_on"=> "2022-12-14",  "disbursement_frequency"=> "WEEKLY", "minimum_monthly_fee"=> nil }

            expect(error_csv.first).to eq(%w[error batch row])
            expect(error_csv.first).to eq(["Data missing", "#{batch}", "#{row}"])
          end

          it "should create the other merchants correctly" do
            subject

            expect(Merchant.count).to eq(1)
            expect(Merchant.last).to have_attributes(
              uid: "86312006-4d7e-45c4-9c28-788f4aa68a62",
              reference: "padberg_group",
              email: "info@padberg-group.com",
              live_on: Date.parse("2023-02-01"),
              disbursement_frequency: "DAILY",
              minimum_monthly_fee: 0.0,
            )
          end
        end

        context "when merchant creation fails" do
          before do
            allow(Merchant).to receive(:import).and_raise(StandardError.new("Error creating"))
  
            CSV.open("spec/fixtures/files/merchants.csv", "w") do |merchants|
              merchants << %w[id reference email live_on disbursement_frequency minimum_monthly_fee]
              merchants << %w[86312006-4d7e-45c4-9c28-788f4aa68a62 padberg_group info@padberg-group.com 2010-02-03 DAILY 0.0]
            end
          end

          it "should not raise an error" do
            expect { subject }.not_to raise_error
          end

          it "should log an error" do
            subject

            error_csv = CSV.open(result_file, "r")

            batch = [
              { "id"=> "86312006-4d7e-45c4-9c28-788f4aa68a62", "reference"=> "padberg_group", "email"=> "info@padberg-group.com", "live_on"=> "2010-02-03", "disbursement_frequency"=> "DAILY", "minimum_monthly_fee"=> "0.0" }
            ]

            expect(error_csv.first).to eq(%w[error batch row])
            expect(error_csv.first).to eq(["Error creating", "#{batch}", "{}"])
          end
        end
      end
    end
  end
end
