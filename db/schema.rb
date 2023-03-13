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

ActiveRecord::Schema.define(version: 2023_03_13_082329) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_name"
    t.string "user_email"
    t.string "message"
    t.string "event_type"
    t.uuid "public_authority_id"
    t.string "log_type"
    t.uuid "log_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["log_type", "log_id"], name: "index_audit_logs_on_log"
    t.index ["public_authority_id"], name: "index_audit_logs_on_public_authority_id"
  end

  create_table "information_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "request_id", null: false
    t.index ["request_id"], name: "index_information_requests_on_request_id"
  end

  create_table "public_authorities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "pa_name"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pa_name"], name: "index_public_authorities_on_pa_name", unique: true
  end

  create_table "requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "scheme_subsidy"
    t.string "referral_type"
    t.string "created_by"
    t.string "status"
    t.string "completed_steps"
    t.string "reference_number"
    t.date "direction_date"
    t.uuid "public_authority_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "assess_pa"
    t.text "assess_pb"
    t.text "assess_pc"
    t.text "assess_pd"
    t.text "assess_pe"
    t.text "assess_pf"
    t.text "assess_pg"
    t.string "call_in_type"
    t.text "character_desc"
    t.string "subsidy_form"
    t.string "other_form"
    t.decimal "budget", precision: 20, scale: 2
    t.decimal "full_amt", precision: 20, scale: 2
    t.string "tax_amt"
    t.string "scheme_name"
    t.decimal "max_amt", precision: 20, scale: 2
    t.string "sectors"
    t.text "description"
    t.string "is_nc"
    t.text "nc_description"
    t.text "legal"
    t.text "policy"
    t.string "purposes"
    t.string "other_purpose"
    t.date "start_date"
    t.date "end_date"
    t.date "confirm_date"
    t.text "info_location"
    t.string "beneficiary"
    t.string "ben_id_type"
    t.string "ben_id"
    t.string "ben_size"
    t.string "ben_good_svr"
    t.string "location"
    t.string "internal_state"
    t.text "other_loc"
    t.string "ee_assess_required"
    t.text "assess_ee_pa"
    t.text "assess_ee_pb"
    t.text "assess_ee_pc"
    t.text "assess_ee_pd"
    t.text "assess_ee_pe"
    t.text "assess_ee_pf"
    t.text "assess_ee_pg"
    t.text "assess_ee_ph"
    t.text "assess_ee_pi"
    t.string "par_on_td"
    t.string "par_td_ref_no"
    t.string "par_assessed"
    t.text "par_reason"
    t.date "par_td_date"
    t.uuid "user_id"
    t.uuid "submitted_by_id"
    t.string "previous_refno"
    t.string "previous_status"
    t.uuid "previous_id"
    t.date "sau_call_in"
    t.integer "tax_low"
    t.integer "tax_high"
    t.text "withdraw_reason"
    t.date "report_due_date"
    t.datetime "submitted_date"
    t.datetime "decision_date"
    t.datetime "completed_date"
    t.string "is_c2_relevant"
    t.text "c2_description"
    t.string "is_emergency"
    t.string "max_amt_s"
    t.string "subsidy_forms"
    t.text "emergency_desc"
    t.index ["public_authority_id"], name: "index_requests_on_public_authority_id"
    t.index ["submitted_by_id"], name: "index_requests_on_submitted_by_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_name"
    t.string "email"
    t.string "oid"
    t.string "phone"
    t.uuid "public_authority_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "role"
    t.string "disabled"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["oid"], name: "index_users_on_oid"
    t.index ["public_authority_id"], name: "index_users_on_public_authority_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "information_requests", "requests"
  add_foreign_key "requests", "public_authorities"
  add_foreign_key "requests", "users"
  add_foreign_key "users", "public_authorities"
end
