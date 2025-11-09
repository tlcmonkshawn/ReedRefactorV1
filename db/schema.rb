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

ActiveRecord::Schema[8.1].define(version: 2025_01_27_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.string "achievement_type"
    t.boolean "active", default: true, null: false
    t.string "badge_icon_url"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "points_required"
    t.datetime "updated_at", null: false
    t.index ["achievement_type"], name: "index_achievements_on_achievement_type"
    t.index ["active"], name: "index_achievements_on_achievement"
  end

  create_table "booties", force: :cascade do |t|
    t.json "alternate_image_urls", default: []
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.json "edited_image_urls", default: []
    t.decimal "final_bounty", precision: 10, scale: 2
    t.datetime "finalized_at"
    t.bigint "location_id", null: false
    t.string "primary_image_url"
    t.decimal "recommended_bounty", precision: 10, scale: 2
    t.boolean "research_auto_triggered", default: false
    t.datetime "research_completed_at"
    t.text "research_reasoning"
    t.datetime "research_started_at"
    t.text "research_summary"
    t.string "square_product_id"
    t.string "square_variation_id"
    t.string "status", default: "captured", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_booties_on_category"
    t.index ["created_at"], name: "index_booties_on_created_at"
    t.index ["location_id"], name: "index_booties_on_location_id"
    t.index ["square_product_id"], name: "index_booties_on_square_product_id"
    t.index ["status"], name: "index_booties_on_status"
    t.index ["user_id"], name: "index_booties_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.text "context_summary"
    t.string "conversation_type", null: false
    t.datetime "created_at", null: false
    t.datetime "last_message_at"
    t.string "participant_type"
    t.bigint "participant_user_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
    t.index ["participant_user_id"], name: "index_conversations_on_participant_user_id"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "game_type", null: false
    t.integer "items_processed", default: 0, null: false
    t.json "metadata"
    t.integer "score", default: 0, null: false
    t.datetime "started_at", null: false
    t.string "status", default: "active", null: false
    t.integer "time_seconds"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["game_type", "status"], name: "index_game_sessions_on_game_type_and_status"
    t.index ["started_at"], name: "index_game_sessions_on_started_at"
    t.index ["user_id"], name: "index_game_sessions_on_user_id"
  end

  create_table "grounding_sources", force: :cascade do |t|
    t.bigint "bootie_id", null: false
    t.datetime "created_at", null: false
    t.bigint "research_log_id"
    t.text "snippet"
    t.string "source_type"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.text "url", null: false
    t.index ["bootie_id"], name: "index_grounding_sources_on_bootie_id"
    t.index ["research_log_id"], name: "index_grounding_sources_on_research_log_id"
  end

  create_table "leaderboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "period_date"
    t.string "period_type", null: false
    t.integer "points", default: 0, null: false
    t.integer "rank"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["period_type", "period_date", "points"], name: "index_leaderboards_on_period_and_points"
    t.index ["period_type", "period_date", "rank"], name: "index_leaderboards_on_period_and_rank"
    t.index ["user_id"], name: "index_leaderboards_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.text "notes"
    t.string "phone_number"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["active"], name: "index_locations_on_active"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.string "message_type", default: "text", null: false
    t.json "metadata"
    t.boolean "read", default: false, null: false
    t.string "sender_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["conversation_id", "read"], name: "index_messages_on_conversation_id_and_read"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.json "metadata"
    t.string "model", null: false
    t.string "name", null: false
    t.text "prompt_text", null: false
    t.string "prompt_type"
    t.integer "sort_order", default: 0
    t.datetime "updated_at", null: false
    t.string "use_case"
    t.integer "version", default: 1, null: false
    t.index ["active"], name: "index_prompts_on_active"
    t.index ["category", "name"], name: "index_prompts_on_category_and_name", unique: true
    t.index ["category"], name: "index_prompts_on_category"
    t.index ["name"], name: "index_prompts_on_name"
    t.index ["prompt_type"], name: "index_prompts_on_prompt_type"
  end

  create_table "research_logs", force: :cascade do |t|
    t.bigint "bootie_id", null: false
    t.text "query"
    t.text "response"
    t.string "research_method"
    t.text "raw_data"
    t.boolean "success", default: true, null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bootie_id"], name: "index_research_logs_on_bootie_id"
    t.index ["created_at"], name: "index_research_logs_on_created_at"
  end

  create_table "scores", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action_type", null: false
    t.integer "points", null: false
    t.bigint "bootie_id"
    t.bigint "game_session_id"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_scores_on_action_type"
    t.index ["bootie_id"], name: "index_scores_on_bootie_id"
    t.index ["created_at"], name: "index_scores_on_created_at"
    t.index ["game_session_id"], name: "index_scores_on_game_session_id"
    t.index ["user_id"], name: "index_scores_on_user_id"
  end

  create_table "user_achievements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "achievement_id", null: false
    t.datetime "earned_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.string "role", null: false, default: "agent"
    t.string "phone_number"
    t.string "avatar_url"
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.integer "total_points", default: 0, null: false
    t.integer "total_items_scanned", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["total_points"], name: "index_users_on_total_points"
  end

  add_foreign_key "booties", "locations"
  add_foreign_key "booties", "users"
  add_foreign_key "conversations", "users"
  add_foreign_key "game_sessions", "users"
  add_foreign_key "grounding_sources", "booties"
  add_foreign_key "grounding_sources", "research_logs"
  add_foreign_key "leaderboards", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "research_logs", "booties"
  add_foreign_key "scores", "booties"
  add_foreign_key "scores", "game_sessions"
  add_foreign_key "scores", "users"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
end
