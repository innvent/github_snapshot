# GithubSnapshot

Snapshots multiple organizations GitHub repositories, including wikis, and syncs them to Amazon's S3. The gem also prunes old backups, keeping only the N most recent snapshots for each repository.

Please do keep in mind that we are not setting up an additional remote that is kept in sync. We do a `git clone --mirror` on each repository and then gzip it with a timestamp. Here is a typical (and reduced for clarity) tree structure of the backup folder/S3 bucket:

```
github-backups/
├── mongodb
│   ├── mongo-201308260300.git.tar.gz
│   ├── mongo-201308270300.git.tar.gz
│   ├── mongo-java-driver-201308260300.git.tar.gz
│   ├── mongo-java-driver-201308260300.wiki.git.tar.gz
│   ├── mongo-java-driver-201308270300.git.tar.gz
│   ├── mongo-java-driver-201308270300.wiki.git.tar.gz
└── innvent
    ├── github_snapshot-201308260300.git.tar.gz
    ├── github_snapshot-201308270300.git.tar.gz
    ├── matross-201308260300.git.tar.gz
    ├── matross-201308270300.git.tar.gz
    └── jobs-201308260300.git.tar.gz
    └── jobs-201308270300.git.tar.gz
```

## Installation

`github_snapshot` should be run as a command line tool, so it makes sense installing it globally

```bash
$ gem install github_snapshot
```

[`s3cmd`](https://github.com/s3tools/s3cmd) should also be installed on the system and properly configured.

## Usage

`github_snapshot` expects a `config.yml` file on the folder it is run, here is a sample:

```yaml
username: <github user with read access to the repositories>
password: <github password>
organizations:
  - organization1
  - organization2
s3bucket: <s3 bucket to store the backups>
backup_folder: <backup folder were the repos will be cloned to>
releases_to_keep: <how many releases to keep>
```

Then, simply run the gem's binary:

```bash
$ github_snapshot
```

**You could be prompted to check the authenticity for `github.com` host**. You can either say yes during the first script execution or disable strict host key checking for it:

```bash
$ echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
```

## To-Do

Although this gem was created to serve a very specific purpose at Innvent, here is the roadmap we have in mind:

- Tests;
- Backup GitHub issues;
- Flag based configuration, in addition to the YAML config file;
- Turn off S3 synchronization;
- Restore backups to GitHub;

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
