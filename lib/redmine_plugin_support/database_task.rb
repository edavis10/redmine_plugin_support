module RedminePluginSupport
  class DatabaseTask < GeneralTask
    def define
      # Adding Rails's database rake tasks, we need the db:test:reset one in
      # order to clear the test database.
      namespace :db do
        desc "Raises an error if there are pending migrations"
        task :abort_if_pending_migrations => :environment do
          if defined? ActiveRecord
            pending_migrations = ActiveRecord::Migrator.new(:up, 'db/migrate').pending_migrations

            if pending_migrations.any?
              puts "You have #{pending_migrations.size} pending migrations:"
              pending_migrations.each do |pending_migration|
                puts '  %4d %s' % [pending_migration.version, pending_migration.name]
              end
              abort %{Run "rake db:migrate" to update your database then try again.}
            end
          end
        end

        namespace :schema do
          desc "Create a db/schema.rb file that can be portably used against any DB supported by AR"
          task :dump => :environment do
            require 'active_record/schema_dumper'
            File.open(ENV['SCHEMA'] || "#{RAILS_ROOT}/db/schema.rb", "w") do |file|
              ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
            end
            Rake::Task["db:schema:dump"].reenable
          end

          desc "Load a schema.rb file into the database"
          task :load => :environment do
            file = ENV['SCHEMA'] || "#{RAILS_ROOT}/db/schema.rb"
            if File.exists?(file)
              load(file)
            else
              abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again. If you do not intend to use a database, you should instead alter #{RAILS_ROOT}/config/environment.rb to prevent active_record from loading: config.frameworks -= [ :active_record ]}
            end
          end
        end

        namespace :structure do
          desc "Dump the database structure to a SQL file"
          task :dump => :environment do
            abcs = ActiveRecord::Base.configurations
            case abcs[RAILS_ENV]["adapter"]
            when "mysql", "oci", "oracle"
              ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
              File.open("#{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql", "w+") { |f| f << ActiveRecord::Base.connection.structure_dump }
            when "postgresql"
              ENV['PGHOST']     = abcs[RAILS_ENV]["host"] if abcs[RAILS_ENV]["host"]
              ENV['PGPORT']     = abcs[RAILS_ENV]["port"].to_s if abcs[RAILS_ENV]["port"]
              ENV['PGPASSWORD'] = abcs[RAILS_ENV]["password"].to_s if abcs[RAILS_ENV]["password"]
              search_path = abcs[RAILS_ENV]["schema_search_path"]
              search_path = "--schema=#{search_path}" if search_path
              `pg_dump -i -U "#{abcs[RAILS_ENV]["username"]}" -s -x -O -f db/#{RAILS_ENV}_structure.sql #{search_path} #{abcs[RAILS_ENV]["database"]}`
              raise "Error dumping database" if $?.exitstatus == 1
            when "sqlite", "sqlite3"
              dbfile = abcs[RAILS_ENV]["database"] || abcs[RAILS_ENV]["dbfile"]
              `#{abcs[RAILS_ENV]["adapter"]} #{dbfile} .schema > db/#{RAILS_ENV}_structure.sql`
            when "sqlserver"
              `scptxfr /s #{abcs[RAILS_ENV]["host"]} /d #{abcs[RAILS_ENV]["database"]} /I /f db\\#{RAILS_ENV}_structure.sql /q /A /r`
              `scptxfr /s #{abcs[RAILS_ENV]["host"]} /d #{abcs[RAILS_ENV]["database"]} /I /F db\ /q /A /r`
            when "firebird"
              set_firebird_env(abcs[RAILS_ENV])
              db_string = firebird_db_string(abcs[RAILS_ENV])
              sh "isql -a #{db_string} > #{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql"
            else
              raise "Task not supported by '#{abcs["test"]["adapter"]}'"
            end

            if ActiveRecord::Base.connection.supports_migrations?
              File.open("#{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql", "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
            end
          end
        end

        namespace :test do
          desc "Recreate the test database from the current schema.rb"
          task :load => 'db:test:purge' do
            ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
            ActiveRecord::Schema.verbose = false
            Rake::Task["db:schema:load"].invoke
          end

          desc "Recreate the test database from the current environment's database schema"
          task :clone => %w(db:schema:dump db:test:load)

          desc "Recreate the test databases from the development structure"
          task :clone_structure => [ "db:structure:dump", "db:test:purge" ] do
            abcs = ActiveRecord::Base.configurations
            case abcs["test"]["adapter"]
            when "mysql"
              ActiveRecord::Base.establish_connection(:test)
              ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
              IO.readlines("#{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql").join.split("\n\n").each do |table|
                ActiveRecord::Base.connection.execute(table)
              end
            when "postgresql"
              ENV['PGHOST']     = abcs["test"]["host"] if abcs["test"]["host"]
              ENV['PGPORT']     = abcs["test"]["port"].to_s if abcs["test"]["port"]
              ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"]
              `psql -U "#{abcs["test"]["username"]}" -f #{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql #{abcs["test"]["database"]}`
            when "sqlite", "sqlite3"
              dbfile = abcs["test"]["database"] || abcs["test"]["dbfile"]
              `#{abcs["test"]["adapter"]} #{dbfile} < #{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql`
            when "sqlserver"
              `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
            when "oci", "oracle"
              ActiveRecord::Base.establish_connection(:test)
              IO.readlines("#{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql").join.split(";\n\n").each do |ddl|
                ActiveRecord::Base.connection.execute(ddl)
              end
            when "firebird"
              set_firebird_env(abcs["test"])
              db_string = firebird_db_string(abcs["test"])
              sh "isql -i #{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql #{db_string}"
            else
              raise "Task not supported by '#{abcs["test"]["adapter"]}'"
            end
          end

          desc "Empty the test database"
          task :purge => :environment do
            abcs = ActiveRecord::Base.configurations
            case abcs["test"]["adapter"]
            when "mysql"
              ActiveRecord::Base.establish_connection(:test)
              ActiveRecord::Base.connection.recreate_database(abcs["test"]["database"], abcs["test"])
            when "postgresql"
              ActiveRecord::Base.clear_active_connections!
              drop_database(abcs['test'])
              create_database(abcs['test'])
            when "sqlite","sqlite3"
              dbfile = abcs["test"]["database"] || abcs["test"]["dbfile"]
              File.delete(dbfile) if File.exist?(dbfile)
            when "sqlserver"
              dropfkscript = "#{abcs["test"]["host"]}.#{abcs["test"]["database"]}.DP1".gsub(/\\/,'-')
              `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{dropfkscript}`
              `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
            when "oci", "oracle"
              ActiveRecord::Base.establish_connection(:test)
              ActiveRecord::Base.connection.structure_drop.split(";\n\n").each do |ddl|
                ActiveRecord::Base.connection.execute(ddl)
              end
            when "firebird"
              ActiveRecord::Base.establish_connection(:test)
              ActiveRecord::Base.connection.recreate_database!
            else
              raise "Task not supported by '#{abcs["test"]["adapter"]}'"
            end
          end

          desc 'Check for pending migrations and load the test schema'
          task :prepare => 'db:abort_if_pending_migrations' do
            if defined?(ActiveRecord) && !ActiveRecord::Base.configurations.blank?
              Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:load" }[ActiveRecord::Base.schema_format]].invoke
            end
          end
        end
      end

      def drop_database(config)
        case config['adapter']
        when 'mysql'
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Base.connection.drop_database config['database']
        when /^sqlite/
          FileUtils.rm(File.join(RAILS_ROOT, config['database']))
        when 'postgresql'
          ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
          ActiveRecord::Base.connection.drop_database config['database']
        end
      end

      def set_firebird_env(config)
        ENV["ISC_USER"]     = config["username"].to_s if config["username"]
        ENV["ISC_PASSWORD"] = config["password"].to_s if config["password"]
      end

      def firebird_db_string(config)
        FireRuby::Database.db_string_for(config.symbolize_keys)
      end
    end
  end
end
