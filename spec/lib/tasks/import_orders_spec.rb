# frozen_string_literal: true

require "rails_helper"

module Tasks
  RSpec.describe "Import Orders" do
    Timecop.freeze do
      let(:result_file) { "/tmp/result-#{Time.current.strftime("%Y-%m-%d_%H%M%S")}.csv" }

      before do
        Rake.application.rake_require "tasks/import_orders"
        Rake::Task.define_task(:environment)
      end

      before(:each) do
        Rake::Task["orders:import"].reenable
        Timecop.freeze(2022, 1, 1, 0, 0, 0)
      end

      after(:each) do
        File.delete(result_file) if File.exist?(result_file)
        Timecop.return
      end

      describe "create orders" do
        subject { Rake.application.invoke_task "orders:import[spec/fixtures/files/orders.csv]" }

        context "when CSV file is not found" do
          it "should raise an error" do
            expect {
              Rake.application.invoke_task "orders:import[tmp/non_existent_file.csv]"
            }.to raise_error(RuntimeError) { |error|
              expect(error.message).to eq("\n\nCSV file not found in tmp/non_existent_file.csv\n\n\n")
            }
          end
        end

        context "when csv file path is not provided" do
          it "should raise an error" do
            expect {
              Rake.application.invoke_task "orders:import"
            }.to raise_error(RuntimeError, "You must specify the csv file path\n\nSyntax: bin/rake orders:import[/tmp/orders.csv]\n\n")
          end
        end

        context "when data is missing" do
          let(:merchant1) { create(:merchant) }
          let(:merchant2) { create(:merchant) }

          before do
            CSV.open("spec/fixtures/files/orders.csv", "w") do |orders|
              orders << %w[id merchant_reference amount created_at]
              orders << ["e653f3e14bc4", "#{merchant1.reference}", 50.0, "2023-02-01"]
              orders << ["20b674c93ea6", "#{merchant2.reference}", 80.0]
            end
          end

          it "should not raise an error" do
            expect { subject }.not_to raise_error
          end

          it "should log an error" do
            subject

            error_csv = CSV.open(result_file, "r")

            batch = [
              { "id"=> "e653f3e14bc4", "merchant_reference"=> "#{merchant1.reference}", "amount"=> "50.0", "created_at"=> "2023-02-01" },
              { "id"=> "20b674c93ea6", "merchant_reference"=> "#{merchant2.reference}", "amount"=> "80.0", "created_at"=> nil },
            ]

            row = { "id"=> "20b674c93ea6", "merchant_reference"=> "#{merchant2.reference}", "amount"=> "80.0", "created_at"=> nil }

            expect(error_csv.first).to eq(%w[error batch row])
            expect(error_csv.first).to eq(["Data missing", "#{batch}", "#{row}"])
          end

          it "should create the other orders correctly" do
            subject

            expect(Order.count).to eq(1)
            expect(Order.last).to have_attributes(
              uid: "e653f3e14bc4",
              merchant_id: merchant1.id,
              amount: 50.0,
              creation_date: Date.parse("2023-02-01"),
            )
          end
        end

        context "when merchant is not found" do
          before do
            CSV.open("spec/fixtures/files/orders.csv", "w") do |orders|
              orders << %w[id merchant_reference amount created_at]
              orders << %w[e653f3e14bc4 padberg_group 50.0 2022-01-01]
            end
          end

          it "should not raise an error" do
            expect { subject }.not_to raise_error
          end

          it "should log an error" do
            subject

            error_csv = CSV.open(result_file, "r")

            row = { "id"=> "e653f3e14bc4", "merchant_reference"=> "padberg_group", "amount"=> "50.0", "created_at"=> "2022-01-01" }
            batch = [row]

            expect(error_csv.first).to eq(%w[error batch row])
            expect(error_csv.first).to eq(["Couldn't find Merchant", "#{batch}", "#{row}"])
          end
        end

        context "when an error ocurrs creating orders" do
          let(:merchant) { create(:merchant) }

          before do
            allow(Order).to receive(:import).and_raise(StandardError.new("Error creating"))

            CSV.open("spec/fixtures/files/orders.csv", "w") do |orders|
              orders << %w[id merchant_reference amount created_at]
              orders << ["e653f3e14bc4", "#{merchant.reference}", "50.0", "2022-01-01"]
              orders << ["e653f3e14bc4", "#{merchant.reference}", "60.0", "2022-01-06"]
            end
          end

          it "should not raise an error" do
            expect { subject }.not_to raise_error
          end

          it "should log an error" do
            subject

            error_csv = CSV.open(result_file, "r")

            batch = [
              { "id"=> "e653f3e14bc4", "merchant_reference"=> "#{merchant.reference}", "amount"=> "50.0", "created_at"=> "2022-01-01" },
              { "id"=> "e653f3e14bc4", "merchant_reference"=> "#{merchant.reference}", "amount"=> "60.0", "created_at"=> "2022-01-06" }
            ]

            expect(error_csv.first).to eq(%w[error batch row])
            expect(error_csv.first).to eq(["Error creating", "#{batch}", "{}"])
          end
        end
      end
    end
  end
end
