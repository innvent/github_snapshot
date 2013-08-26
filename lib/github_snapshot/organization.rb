require_relative "repository"

module GithubSnapshot

  class Organization

    attr_reader :name, :folder, :repos

    def initialize(name, folder, repos)
      @name   = name
      @folder = folder
      @repos  = repos
    end

    def backup
      repos.to_a.each do |repo|
        repository = Repository.new repo, self
        repository.backup
      end
    end

  end

end
