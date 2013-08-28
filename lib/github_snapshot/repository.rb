require "open3"
require "rake"
require "timeout"
require_relative "utilities"

module GithubSnapshot

  class Repository

    attr_reader :name, :folder, :wiki_folder, :ssh_url, :wiki_ssh_url,
                :canonical_name, :pushed_at, :gh_has_wiki, :organization

    def initialize(repo, organization)
      @name           = repo['name']
      @folder         = "#{@name}-#{GithubSnapshot.time_now}.git"
      @wiki_folder    = @folder.gsub('.git', '.wiki.git')
      @ssh_url        = repo['ssh_url']
      @wiki_ssh_url   = @ssh_url.gsub('.git', '.wiki.git')
      @canonical_name = "#{organization.name}/#{@name}"
      @pushed_at      = repo['pushed_at']
      @gh_has_wiki    = repo['has_wiki']
      @organization   = organization
    end

    def has_wiki?
      Open3.capture3("git ls-remote #{wiki_ssh_url}")[1].empty? && gh_has_wiki
    end

    def backup
      GithubSnapshot.logger.info "#{canonical_name} - backing up"

      # Go to next repo if the repository is empty
      unless pushed_at
        GithubSnapshot.logger.info "#{canonical_name} is empty"
        return nil
      end

      Dir.chdir "#{organization.name}"
      clone
      clone_wiki if self.has_wiki?
      prune_old_backups
      Dir.chdir ".."

      GithubSnapshot.logger.info "#{canonical_name} - success"
    end

  private

    def clone
      GithubSnapshot.logger.info "#{canonical_name} - cloning"
      begin
        Timeout::timeout (300) {
          GithubSnapshot.exec "#{GithubSnapshot.git_clone_cmd} #{ssh_url} #{folder}"
        }
      rescue Timeout::Error => e
        logger.error "Could not clone #{canonical_name}, timedout"
      end
      GithubSnapshot.exec "tar zcf #{folder}.tar.gz #{folder}"
      GithubSnapshot.exec "rm -rf #{folder}"
    end

    def clone_wiki
      GithubSnapshot.logger.info "#{canonical_name} - cloning wiki"
      GithubSnapshot.exec "#{GithubSnapshot.git_clone_cmd} #{wiki_ssh_url} #{wiki_folder}"
      GithubSnapshot.exec "tar zcf #{wiki_folder}.tar.gz #{wiki_folder}"
      GithubSnapshot.exec "rm -rf #{wiki_folder}"
    end

    def prune_old_backups
      GithubSnapshot.logger.info "#{canonical_name} - pruning old backups"
      file_regex  = "#{name}*"
      zipped_bkps = FileList[file_regex].exclude(/wiki/)
      zipped_bkps.sort[0..-(GithubSnapshot.releases_to_keep + 1)].each do |file|
        File.delete file
      end if zipped_bkps.length > GithubSnapshot.releases_to_keep

      wiki_regex   = "#{name}*wiki*"
      zipped_wikis = FileList[wiki_regex]
      zipped_wikis.sort[0..-(GithubSnapshot.releases_to_keep + 1)].each do |file|
        File.delete file
      end if zipped_wikis.length > GithubSnapshot.releases_to_keep
    end

  end

end
