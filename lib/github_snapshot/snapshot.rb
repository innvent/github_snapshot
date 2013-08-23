require "github_api"
require "logger"

module GithubSnapshot
  class Snapshot
    require "yaml"

    attr_reader :username, :password, :organizations, :s3_bucket, :backup_folder,
                :release_to_keep, :git_clone_cmd, :time_now, :github

    def initialize(config_file="config.yml")
      config = YAML.load(File.read(config_file))

      @username
      @password
      @organizations
      @s3_bucket
      @backup_folder
      @release_to_keep

      @github = Github.new do |gh_config|
        gh_config.login           = @username
        gh_config.password        = @password
        gh_config.auto_pagination = true
      end

      @git_clone_cmd = "git clone --quiet --mirror"
      @time_now = Time.now.getutc.strftime("%Y%m%d%H%M")
    end
  end
end
