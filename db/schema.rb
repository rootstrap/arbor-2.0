# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150821121912) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "canvas", force: :cascade do |t|
    t.text     "problems"
    t.text     "solutions"
    t.text     "alternative"
    t.text     "advantage"
    t.text     "segment"
    t.text     "channel"
    t.text     "value_proposition"
    t.text     "revenue_streams"
    t.text     "cost_structure"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "canvas", ["project_id"], name: "index_canvas_on_project_id", using: :btree
  add_index "canvas", ["value_proposition"], name: "index_canvas_on_value_proposition", using: :btree

  create_table "goals", force: :cascade do |t|
    t.text     "title",         null: false
    t.integer  "hypothesis_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "goals", ["hypothesis_id"], name: "index_goals_on_hypothesis_id", using: :btree

  create_table "hypotheses", force: :cascade do |t|
    t.string   "description"
    t.integer  "project_id"
    t.integer  "hypothesis_type_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hypotheses", ["hypothesis_type_id"], name: "index_hypotheses_on_hypothesis_type_id", using: :btree
  add_index "hypotheses", ["project_id"], name: "index_hypotheses_on_project_id", using: :btree

  create_table "hypothesis_types", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members_projects", force: :cascade do |t|
    t.integer "member_id",  null: false
    t.integer "project_id", null: false
  end

  add_index "members_projects", ["member_id"], name: "index_members_projects_on_member_id", using: :btree
  add_index "members_projects", ["project_id"], name: "index_members_projects_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "owner_id",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["name"], name: "index_projects_on_name", using: :btree
  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree

  create_table "user_stories", force: :cascade do |t|
    t.string   "role",             limit: 100,               null: false
    t.string   "action",           limit: 255,               null: false
    t.string   "result",           limit: 255,               null: false
    t.integer  "estimated_points", limit: 2
    t.string   "priority",         limit: 1,   default: "s"
    t.integer  "project_id"
    t.integer  "hypothesis_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_stories", ["hypothesis_id"], name: "index_user_stories_on_hypothesis_id", using: :btree
  add_index "user_stories", ["project_id"], name: "index_user_stories_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "full_name"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end