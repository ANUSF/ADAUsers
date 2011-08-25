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

ActiveRecord::Schema.define(:version => 20110525002614) do

  create_table "ProjectEJB", :id => false, :force => true do |t|
    t.text     "comment"
    t.datetime "creationDate"
    t.string   "id",           :limit => 100, :default => "", :null => false
    t.text     "label"
    t.text     "scope"
    t.text     "sponsor"
    t.text     "title"
    t.text     "type"
  end

  create_table "PurposeEJB", :id => false, :force => true do |t|
    t.text     "comment"
    t.datetime "creationDate"
    t.string   "id",           :limit => 100, :default => "", :null => false
    t.text     "label"
  end

  create_table "RoleEJB", :id => false, :force => true do |t|
    t.text     "comment"
    t.datetime "creationDate"
    t.string   "id",           :limit => 100, :default => "", :null => false
    t.text     "label"
  end

  create_table "UserEJB", :id => false, :force => true do |t|
    t.text     "comment"
    t.datetime "creationDate"
    t.string   "id",               :limit => 100, :default => "", :null => false
    t.text     "label"
    t.date     "modificationDate"
    t.integer  "admin",                           :default => 0
    t.string   "password",         :limit => 20
    t.integer  "active"
  end

  create_table "access_levels_undertakings", :id => false, :force => true do |t|
    t.string  "datasetID"
    t.integer "undertaking_id"
  end

  create_table "accesslevel", :id => false, :force => true do |t|
    t.string "datasetID",   :limit => 100, :default => "", :null => false
    t.string "fileID",      :limit => 100
    t.string "datasetname", :limit => 100
    t.text   "fileContent"
    t.string "accessLevel", :limit => 1
  end

  add_index "accesslevel", ["accessLevel"], :name => "accesslevel_accesslevel"
  add_index "accesslevel", ["datasetID"], :name => "accesslevel_datasetID"
  add_index "accesslevel", ["fileID"], :name => "accesslevel_fileID"

  create_table "agenciesdept", :id => false, :force => true do |t|
    t.integer "id",                                          :null => false
    t.string  "value",        :limit => 150, :default => "", :null => false
    t.string  "name",         :limit => 150, :default => "", :null => false
    t.integer "acsprimember",                :default => 1,  :null => false
    t.string  "type",         :limit => 100
  end

  create_table "countries", :id => false, :force => true do |t|
    t.integer "id",                                         :null => false
    t.string  "Countryname", :limit => 100, :default => "", :null => false
    t.string  "Sym",         :limit => 10,  :default => ""
  end

  create_table "otherinstitutions", :id => false, :force => true do |t|
    t.integer "id",                                          :null => false
    t.string  "name",         :limit => 150, :default => "", :null => false
    t.integer "acsprimember",                :default => 1,  :null => false
    t.string  "type",         :limit => 100
  end

  create_table "searches", :id => false, :force => true do |t|
    t.string   "userId", :limit => 100, :default => "", :null => false
    t.string   "name",   :limit => 100
    t.text     "query",                                 :null => false
    t.datetime "date"
  end

  create_table "searchstats", :id => false, :force => true do |t|
    t.string  "date",     :limit => 6, :default => "", :null => false
    t.integer "sessions",              :default => 0,  :null => false
    t.integer "searches",              :default => 0,  :null => false
  end

  create_table "templates", :force => true do |t|
    t.string   "doc_type"
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "undertakings", :force => true do |t|
    t.string   "user_user"
    t.boolean  "is_restricted"
    t.string   "intended_use_type"
    t.string   "intended_use_other"
    t.text     "intended_use_description"
    t.string   "email_supervisor"
    t.text     "funding_sources"
    t.boolean  "agreed"
    t.boolean  "processed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uniaustralia", :id => false, :force => true do |t|
    t.integer "id",                                          :null => false
    t.string  "Longuniname",  :limit => 100, :default => "", :null => false
    t.string  "Shortuniname", :limit => 30,  :default => ""
    t.integer "acsprimember",                :default => 1,  :null => false
    t.integer "g8"
  end

  create_table "usage", :id => false, :force => true do |t|
    t.string  "server",    :limit => 100, :default => "", :null => false
    t.string  "datasetId", :limit => 100, :default => "", :null => false
    t.integer "accesses",                 :default => 0,  :null => false
  end

  create_table "userAgreement", :id => false, :force => true do |t|
    t.string "agreementID", :limit => 100, :default => "", :null => false
    t.string "userID",      :limit => 100, :default => "", :null => false
  end

  create_table "userGroups", :id => false, :force => true do |t|
    t.string "userId", :limit => 100, :default => "", :null => false
    t.string "group",  :limit => 100, :default => "", :null => false
  end

  create_table "userProject", :id => false, :force => true do |t|
    t.string "projectID", :limit => 100, :default => "", :null => false
    t.string "userID",    :limit => 100, :default => "", :null => false
  end

  create_table "userPurposes", :id => false, :force => true do |t|
    t.string "purposeID", :limit => 100, :default => "", :null => false
    t.string "userID",    :limit => 100, :default => "", :null => false
  end

  create_table "userRole", :id => false, :force => true do |t|
    t.string "id",        :limit => 100, :default => "", :null => false
    t.string "roleID",    :limit => 100, :default => "", :null => false
    t.text   "rolegroup"
  end

  create_table "userdetails", :id => false, :force => true do |t|
    t.string  "user",                 :limit => 100,                 :null => false
    t.string  "password",             :limit => 100
    t.string  "email",                :limit => 100
    t.string  "institution",          :limit => 100
    t.string  "action",               :limit => 100
    t.string  "position",             :limit => 100
    t.string  "dateregistered",       :limit => 100, :default => ""
    t.integer "acsprimember"
    t.integer "countryid"
    t.integer "uniid"
    t.integer "departmentid"
    t.string  "institutiontype",      :limit => 100
    t.string  "fname",                :limit => 50
    t.string  "sname",                :limit => 50
    t.string  "title",                :limit => 10
    t.string  "austinstitution",      :limit => 10
    t.string  "otherpd",              :limit => 100
    t.string  "otherwt",              :limit => 100
    t.string  "role_cms"
    t.string  "token_reset_password"
  end

  create_table "userpermissiona", :id => false, :force => true do |t|
    t.string  "userID",          :limit => 100
    t.string  "datasetID",       :limit => 100
    t.string  "fileID",          :limit => 100
    t.integer "permissionvalue",                :default => 0
  end

  create_table "userpermissionb", :id => false, :force => true do |t|
    t.string  "userID",          :limit => 100
    t.string  "datasetID",       :limit => 100
    t.string  "fileID",          :limit => 100
    t.integer "permissionvalue"
  end

end
