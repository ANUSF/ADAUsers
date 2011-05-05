namespace :db do
  namespace :test do
    desc "Initialise the test database structure"
    task :initialise do
      `sqlite3 db/test.db < db/template_test.sql`
      `sqlite3 db/test_logs.db < db/template_test_logs.sql`
      `sqlite3 db/test_nesstar.db < db/template_test_nesstar.sql`
    end
  end
end
