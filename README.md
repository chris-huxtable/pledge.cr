# pledge.cr
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://chris-huxtable.github.io/pledge.cr/)
[![GitHub release](https://img.shields.io/github/release/chris-huxtable/pledge.cr.svg)](https://github.com/chris-huxtable/pledge.cr/releases)

Adds `pledge(2)` to crystal.

## Installation

Add this to your application's `shard.yml`:

``` yaml
dependencies:
  pledge:
    github: chris-huxtable/pledge.cr
```

## Usage

``` crystal
require "pledge"
```

Partial `syscall` restrictions:
``` crystal
Process.pledge(:stdio, :rpath, :wpath, :flock)
Process.pledge("stdio", "rpath")
```

Full restrictions:
``` crystal
Process.pledge()
```

More information and a list of 'promises' is available in the OpenBSD [man pages](http://man.openbsd.org/pledge).

## Contributing

1. Fork it ( https://github.com/chris-huxtable/pledge.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Chris Huxtable](https://github.com/chris-huxtable) - creator, maintainer
