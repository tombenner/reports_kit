ActiveRecord::Schema.define do
  self.verbose = false

  create_table :issues, :force => :cascade do |t|
    t.integer  :repo_id
    t.string   :title
    t.integer  :source_user_id
    t.string   :state
    t.boolean  :locked
    t.datetime :opened_at
    t.datetime :closed_at
    t.timestamps
  end

  create_table :issues_labels, force: :cascade do |t|
    t.integer  :issue_id
    t.integer  :label_id
    t.timestamps
  end

  create_table :labels, force: :cascade do |t|
    t.integer  :repo_id
    t.string   :name
    t.timestamps
  end

  create_table :repos, :force => :cascade do |t|
    t.string   :full_name
    t.timestamps
  end

  create_table :tags, force: :cascade do |t|
    t.integer  :repo_id
    t.integer  :issue_id
    t.string   :name
    t.timestamps
  end
end