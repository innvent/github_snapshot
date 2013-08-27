# GithubSnapshot

Snapshoting organization's repositories, including wikis

## Installation

`github_snapshot` should be run as a command line tool, so it makes sense installing it globally

    $ gem install github_snapshot

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
