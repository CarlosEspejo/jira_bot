require 'logger'

$PROGRAM_NAME = 'jira_bot_daemon'

logger = Logger.new('./daemon.log')

puts "#{$PROGRAM_NAME} its daemon time!!!"

Process.daemon(true)

logger.debug "Started Daemon pid #{Process.pid}"

loop do
  begin

    `ruby runner.rb`

    sleep 10
  rescue Exception => e
    logger.debug "Error: #{e}"
  end
end
