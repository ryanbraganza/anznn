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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120221030613) do

  create_table "answers", :force => true do |t|
    t.integer "response_id"
    t.integer "question_id"
    t.text    "text_answer"
    t.date    "date_answer"
    t.time    "time_answer"
    t.float   "decimal_answer"
    t.integer "integer_answer"
    t.string  "choice_answer"
    t.string  "raw_answer"
  end

  create_table "batch_files", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "status"
  end

  add_index "batch_files", ["survey_id"], :name => "index_batch_files_on_survey_id"

  create_table "cross_question_validations", :force => true do |t|
    t.integer "question_id"
    t.integer "related_question_id"
    t.string  "rule"
    t.string  "error_message"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "hospitals", :force => true do |t|
    t.string   "state"
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_options", :force => true do |t|
    t.integer  "question_id"
    t.string   "option_value"
    t.string   "label"
    t.string   "hint_text"
    t.integer  "option_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_options", ["question_id"], :name => "index_question_options_on_question_id"

  create_table "questions", :force => true do |t|
    t.integer "section_id"
    t.string  "question"
    t.string  "question_type"
    t.integer "order"
    t.string  "code"
    t.text    "description"
    t.text    "guide_for_use"
    t.decimal "number_min"
    t.decimal "number_max"
    t.integer "number_unknown"
    t.integer "string_min"
    t.integer "string_max"
    t.text    "data_domain"
    t.boolean "mandatory"
  end

  create_table "responses", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "user_id"
    t.string   "baby_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hospital_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.integer "survey_id"
    t.integer "order"
    t.string  "name"
  end

  create_table "surveys", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                       :default => 0
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hospital_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
