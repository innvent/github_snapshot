module Utilities
  Error     = Class.new(RuntimeError)
  ExecError = Class.new(Error)

  module_function

  def exec(cmd, logger)
    out, err, status = Open3.capture3 cmd
    if err.empty?
      logger.debug out unless out.empty?
    else
      logger.error "Open3 error:\n#{'='*79}\n#{err}Command was:\n#{cmd}\n#{'='*79}\n"
      raise Utilities::ExecError
    end
  end

  def tar(file, logger)
    if File.exists? file
      Utilities.exec "tar zcf #{file}.tar.gz #{file}", logger
    else
      logger.error "Unable to tar #{file}"
    end
  end

end
