# Run migrations - called from startup script
# This uses the same pattern as migrations_controller.rb that we know works

Dir.chdir(Rails.root) do
  Rails.application.load_tasks
  Rake::Task['db:migrate'].invoke
  Rake::Task['db:migrate'].reenable
end

