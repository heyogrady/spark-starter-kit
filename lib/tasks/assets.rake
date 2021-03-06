# lib/tasks/assets.rake
# The webpack task must run before assets:environment task.
# Otherwise Sprockets cannot find the files that webpack produces.
Rake::Task['assets:precompile']
  .clear_prerequisites
  .enhance(['assets:compile_environment'])

namespace :assets do
  # In this task, set prerequisites for the assets:precompile task
  task compile_environment: :webpack do
    Rake::Task['assets:environment'].invoke
  end

  desc 'Compile assets with webpack'
  task :webpack do
    sh 'cd client && npm run build:client'
    sh 'cd client && npm run build:server'
    sh 'mkdir -p public/assets'

    # Critical to manually copy non js/css assets to public/assets as we don't want to fingerprint them
    sh 'cp -rf app/assets/webpack/*.woff* app/assets/webpack/*.svg app/assets/webpack/*.ttf '\
       'app/assets/webpack/*.eot* app/assets/webpack/*.png public/assets'

    # TODO: We should be gzipping these
  end

  task :clobber do
    rm_rf '#{Rails.application.config.root}/app/assets/webpack'
  end
end
