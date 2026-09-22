require "action_dispatch/testing/integration"

Rails.application.config.action_dispatch.show_exceptions = :none

session = ActionDispatch::Integration::Session.new(Rails.application)

%w[/registration/new /session/new].each do |path|
  puts "=" * 60
  puts "GET #{path}"
  begin
    session.get(path)
    puts "status=#{session.response.status}"
  rescue => e
    puts "EXCEPTION: #{e.class}"
    puts e.message
    puts "--- backtrace ---"
    puts e.backtrace[0..25]
  end
end
