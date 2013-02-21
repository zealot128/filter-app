RSpec.configure do |config|

  # Freeze Time using Timecop
  # freeze_time: "2012-09-01 12:12:12"
  config.around(:each) do |example|
    if time = example.metadata[:freeze_time]
      begin
        Timecop.freeze(Time.parse(time)) do
          example.run
        end
      ensure
        Timecop.return
      end
    else
      example.run
    end
  end

  # Skip = pending all examples
  config.around(:each, :skip => true) do |example|
    example.metadata[:pending] = true
    example.metadata[:execution_result][:pending_message] = "Skipped #{example.to_s}"
  end

  # Activate ActionController Caching
  # caching: true
  config.around(:each, :caching => true) do |example|
    caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
    store, ActionController::Base.cache_store = ActionController::Base.cache_store, :memory_store
    silence_warnings { Object.const_set "RAILS_CACHE", ActionController::Base.cache_store }

    example.run

    silence_warnings { Object.const_set "RAILS_CACHE", store }
    ActionController::Base.cache_store = store
    ActionController::Base.perform_caching = caching
  end


end
