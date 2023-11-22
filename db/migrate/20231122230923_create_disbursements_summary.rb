class CreateDisbursementsSummary < ActiveRecord::Migration[6.1]
  def change
    create_view :disbursements_summary
  end
end
