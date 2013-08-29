require_relative "repository"

module GithubSnapshot

  class Organization

    attr_reader :name, :repos

    def initialize(name, repos)
      @name   = name
      @repos  = repos
    end

    def backup
      repos.to_a.each do |repo|
        GithubSnapshot.exec "mkdir -p #{name}"
        repository = Repository.new repo, self
        repository.backup
      end
    end

  end

end
