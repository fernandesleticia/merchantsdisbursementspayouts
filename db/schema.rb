# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_11_22_230923) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "disbursements", force: :cascade do |t|
    t.bigint "merchant_id"
    t.string "reference", null: false
    t.float "amount"
    t.float "commision_fee"
    t.string "year_month"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["merchant_id"], name: "index_disbursements_on_merchant_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "uid", null: false
    t.string "reference", null: false
    t.string "disbursement_frequency"
    t.string "email"
    t.date "live_on"
    t.float "minimum_monthly_fee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reference"], name: "index_merchants_on_reference", unique: true
  end

  create_table "monthly_fee_debits", force: :cascade do |t|
    t.bigint "merchant_id"
    t.bigint "disbursement_id"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disbursement_id"], name: "index_monthly_fee_debits_on_disbursement_id"
    t.index ["merchant_id"], name: "index_monthly_fee_debits_on_merchant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "merchant_id"
    t.string "uid", null: false
    t.boolean "disbursed", default: false
    t.float "amount"
    t.date "creation_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "disbursement_id"
    t.index ["disbursement_id"], name: "index_orders_on_disbursement_id"
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
  end

  add_foreign_key "disbursements", "merchants"
  add_foreign_key "monthly_fee_debits", "disbursements"
  add_foreign_key "monthly_fee_debits", "merchants"
  add_foreign_key "orders", "disbursements"
  add_foreign_key "orders", "merchants"

  create_view "disbursements_summary", sql_definition: <<-SQL
      SELECT (EXTRACT(year FROM disbursement.created_at))::text AS year,
      count(disbursement.id) AS number_of_disbursements,
      to_char(sum(disbursement.amount), 'FM999G999G999G999G999D00 €'::text) AS amount_disbursed_to_merchants,
      to_char(sum(disbursement.commision_fee), 'FM999G999G999G999G999D00 €'::text) AS amount_of_order_fees,
      count(monthly_fee_debit.id) AS number_of_monthly_fees_charged,
      COALESCE(to_char(sum(monthly_fee_debit.amount), 'FM999G999G999G999G999D00 €'::text), '0.00 €'::text) AS amount_of_monthly_fee_charged
     FROM (disbursements disbursement
       LEFT JOIN monthly_fee_debits monthly_fee_debit ON ((monthly_fee_debit.disbursement_id = disbursement.id)))
    GROUP BY (EXTRACT(year FROM disbursement.created_at))::text
    ORDER BY (EXTRACT(year FROM disbursement.created_at))::text;
  SQL
end
