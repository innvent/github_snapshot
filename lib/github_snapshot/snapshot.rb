require "github_api"
require "logger"
require_relative "utilities"
require_relative "organization"

module GithubSnapshot
  @@logger                 = Logger.new(STDOUT)
  @@logger.level           = Logger::INFO
  @@logger.datetime_format = '%Y-%m-%d %H:%M:%S '
  @@git_clone_cmd          = "git clone --quiet --mirror"
  @@time_now               = Time.now.getutc.strftime("%Y%m%d%H%M")
  @@releases_to_keep
  @@git_clone_timeout

  def self.logger;            @@logger;             end
  def self.git_clone_cmd;     @@git_clone_cmd;      end
  def self.time_now;          @@time_now;           end
  def self.releases_to_keep;  @@releases_to_keep;   end
  def self.git_clone_timeout; @@git_clone_timeout;  end

  def self.releases_to_keep=(releases_to_keep)
    @@releases_to_keep = releases_to_keep
  end

  def self.git_clone_timeout=(git_clone_timeout)
    @@git_clone_timeout = git_clone_timeout
  end

  def self.exec(cmd)
    Utilities.exec cmd, @@logger
  end

  class Snapshot
    require "yaml"

    attr_reader :username, :password, :organizations, :s3_bucket, :backup_folder,
                :releases_to_keep, :git_clone_cmd, :time_now, :github, :logger

    def initialize(config_file="config.yml")
      config = YAML.load(File.read(config_file))

      @username      = config['username']
      @password      = config['password']
      @organizations = config['organizations']
      @s3_bucket     = config['s3bucket']
      @backup_folder = config['backup_folder']
      GithubSnapshot.releases_to_keep  = config['releases_to_keep']
      GithubSnapshot.git_clone_timeout = config['git_clone_timeout']

      @github = Github.new do |config|
        config.login           = username
        config.password        = password
        config.auto_pagination = true
      end
    end

    def backup
      create_backup_folder
      download_from_s3
      backup_orgs
      upload_to_s3

      total_size = %x[ du -sh #{backup_folder} | cut -f1 ]
      GithubSnapshot.logger.info "backup finished, total size is #{total_size}"
    end

  private
    def create_backup_folder
      GithubSnapshot.exec "mkdir -p #{backup_folder}"
    end

    def download_from_s3
      GithubSnapshot.logger.info "downloading fom s3"
      begin
        GithubSnapshot.exec "s3cmd sync --delete-removed --skip-existing s3://#{s3_bucket}/ #{backup_folder}/"
      rescue Utilities::ExecError
        GithubSnapshot.logger.info "s3cmd doesn't respect exit status\n"\
                                   "there is a good chance that the sync was successful"
      end
    end

    def backup_orgs
      Dir.chdir "#{backup_folder}"
      organizations.each do |org|
        GithubSnapshot.logger.info "#{org} - initializing"
        repos        = github.repos.list org: org
        organization = Organization.new org, repos
        organization.backup
        GithubSnapshot.logger.info "#{org} - ending"
      end
      Dir.chdir ".."
    end

    def upload_to_s3
      GithubSnapshot.logger.info "uploading to s3"
      GithubSnapshot.exec "s3cmd sync --delete-removed --skip-existing #{backup_folder}/ s3://#{s3_bucket}/"
    end

  end

end
