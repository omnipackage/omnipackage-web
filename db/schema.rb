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

ActiveRecord::Schema[7.1].define(version: 2023_12_07_172049) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.string "apikey", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen_at"
    t.datetime "considered_offline_at"
    t.bigint "user_id"
    t.string "name", default: "", null: false
    t.string "arch", limit: 100, null: false
    t.index ["apikey"], name: "index_agents_on_apikey", unique: true
    t.index ["user_id"], name: "index_agents_on_user_id"
  end

  create_table "email_verification_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "project_sources_tarballs", force: :cascade do |t|
    t.binary "tarball"
    t.json "config"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_sources_tarballs_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sources_location", default: "", null: false
    t.string "sources_kind", default: "", null: false
    t.string "sources_private_ssh_key"
    t.string "sources_public_ssh_key"
    t.string "sources_subdir", default: "", null: false
    t.string "sources_status", default: "", null: false
    t.string "sources_fetch_error", limit: 10000
    t.index ["name"], name: "index_projects_on_name"
    t.index ["sources_kind"], name: "index_projects_on_sources_kind"
    t.index ["sources_status"], name: "index_projects_on_sources_status"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "distro_id", null: false
    t.string "bucket", null: false
    t.string "endpoint"
    t.string "access_key_id"
    t.string "secret_access_key"
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gpg_key_private"
    t.string "gpg_key_public"
    t.datetime "published_at"
    t.string "last_publish_error"
    t.string "publish_status", default: "", null: false
    t.index ["bucket"], name: "index_repositories_on_bucket"
    t.index ["distro_id"], name: "index_repositories_on_distro_id"
    t.index ["endpoint", "bucket"], name: "index_repositories_on_endpoint_and_bucket", unique: true
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "task_artefacts", force: :cascade do |t|
    t.string "distro", null: false
    t.bigint "task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "error", default: false, null: false
    t.index ["task_id"], name: "index_task_artefacts_on_task_id"
  end

  create_table "task_logs", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.text "text", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_logs_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "sources_tarball_id", null: false
    t.string "state", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "agent_id"
    t.string "distro_ids", null: false, array: true
    t.datetime "started_at"
    t.datetime "finished_at"
    t.index ["agent_id"], name: "index_tasks_on_agent_id"
    t.index ["sources_tarball_id"], name: "index_tasks_on_sources_tarball_id"
    t.index ["state"], name: "index_tasks_on_state"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "root", default: false, null: false
    t.string "gpg_key_private"
    t.string "gpg_key_public"
    t.string "name", limit: 2000, default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agents", "users"
  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "project_sources_tarballs", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "repositories", "projects"
  add_foreign_key "sessions", "users"
  add_foreign_key "task_artefacts", "tasks"
  add_foreign_key "task_logs", "tasks"
  add_foreign_key "tasks", "agents"
  add_foreign_key "tasks", "project_sources_tarballs", column: "sources_tarball_id"
end
