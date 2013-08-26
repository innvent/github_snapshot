module Utilities
  module_function

  def exec(cmd, logger)
    out, err, status = Open3.capture3 cmd
    if err.empty?
      logger.debug out unless out.empty?
    else
      logger.error(err + " command was: #{cmd}")
    end
  end
end
