# YukiHelper

`YukiHelper` provides helpers to download testcases and to compile the source code in order to help test (judge) your souce code (e.g. ac, wa, re) in your local environment.

Current version supports `YukiCoder` and `Elixir`.

Note that `YukiHelper` needs your access token to download testcases for any problem.
Please set the access token into your configuration file described later.

## Installation

Add your project `mix.exs`

```elixir
def deps do
  [
    {:yuki_helper, path: "../.."},
  ]
end
```

```sh
mix deps.get
```

## Usages

Provides the following commands.

> See detail usages using the help command such as `mix help yuki.test`

```sh
# prints current configuration
mix yuki.config

# prints a list of testcase for Problem No. 10
mix yuki.testcase.list 10

# prints a list of testcase for Problem Id 10
mix yuki.testcase.list 10 --problem-id

# downloads a list of testcase for Problem No. 10
mix yuki.testcase.download 10

# tests your source code for Problem No. 10
# tries to execute `elixirc lib/path/to/10.ex` and `elixir -e P10.main` sequentially
mix yuki.test 10
```

## Configurations

`.yuki_helper.default.config.yml` is an example configuration.
There are three pattern of locations of configuration file in the following.

1. `~/.yukihelper.config.yml`

2. `~/.config/yukihelper/.config.yml`

3. `./.yuki_helper.config.yml`

Configurations are overridden in the order of the above, with the manner that any `nil` value is skipped or ignored in current version.

Note that name of the configuration file depends on the directory.

### Example Configuration

`YukiHelper` needs your access token for `Yukicoder` to download any testcase.
Please get your access token from `Yukicoder` homepage and set it in your configuration files.

```yaml
# .yuki_helper.default.config.yml
testcase:
  # Positive integer value more than 10.
  # If `bundile` is 100, directory of testcase for problem 10 is `testcase/100/p10`.
  bundle: null
  # Root direcotry of testcases to download
  directory: "testcase"
  # Prefix of testcase `testcase/p10` and source code `lib/p10.ex`
  prefix: "p"
yukicoder:
  # Access Token for Yukicoder. Be careful to treat.
  access_token: "your access token"
```

### Directory Structure

- Initial Configuration

```yml
# .yuki_helper.config.yml
testcase:
  bundle: null
  directory: "testcase"
  prefix: null
```

```console
├── lib
│   ├── 10.ex
│   └── 11.ex
└── testcase
    ├── 10
    │   ├── in
    │   └── out
    └── 11
```

- Custum Configuration

```yml
# .yuki_helper.config.yml
testcase:
  bundle: 100
  directory: "test-case"
  prefix: "p"
```

```console
├── lib
│   ├─── 100
│   │    ├── p10.ex
│   │    └── p11.ex
│   └── p12.ex
└── test-case
    ├─── 100
    │   ├── p10
    │   │   ├── in
    │   │   └── out
    │   └── p11
    └── 200
```

## Features

- [x] to dwonload testcases for any problem
- [ ] additional options for `mix yuki.test`
  - [ ] to specify module name
  - [ ] `timeout` option
  - [ ] `force` option
- [ ] to juadge testcase
  - [x] CE
  - [x] AC/WA/RE
  - [ ] TLE
  - [ ] MLE
- [ ] to support for handling unexpected error (e.g. communication)
- [ ] to support for other languages
- [ ] to support for other provider (except YukiCoder) if necessary
