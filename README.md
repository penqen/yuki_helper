# YukiHelper

`YukiHelper` provides helpers to download testcases and to compile the source code in order to help test (judge) your souce code (e.g. ac, wa, re) in your local environment.

Current version supports `YukiCoder` and `Elixir`.

Note that `YukiHelper` needs your access token to download testcases for any problem.
Please set the access token into your config file described later.

## Installation

Add to your project dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:yuki_helper, "~> 0.1.0"},
  ]
end
```

```sh
mix deps.get
```

Or, globally install using escript.

```sh
mix escript.install hex yuki_helper
```

Export a path for executable escript.

```sh
export $PATH $PATH:path/to/escript
```

## Usages

Provides the following commands.

> See detail usages using the help command `mix help COMMAND` or `yuki help COMMAND`.

### From Mix Task

```sh
# prints current configuration
mix yuki.config

# prints a list of supported language
mix yuki.lang.list

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

### From Escript

The following commands are `escript` version of the above `mix task`.

```sh
# prints help for the following commands 
yuki help COMMAND

yuki config
yuki lang.list
yuki testcase.list 10
yuki testcase.list 10 --problem-id
yuki testcase.download 10
yuki test 10
```

## Configuration

`.yuki_helper.default.config.yml` is an example configuration.
There are three pattern of locations of config file.

1. `~/.yukihelper.config.yml`

2. `~/.config/yukihelper/.config.yml`

3. `./.yuki_helper.config.yml`

Configurations are overridden in the order of the above, with the manner that any `nil` value is skipped or ignored in current version.

> Note: name of config file depends on location.

### Example Configuration

`YukiHelper` needs your access token for `Yukicoder` to download any testcase.
Please get your access token from `Yukicoder` homepage and set it in your config files.

```yaml
# .yuki_helper.default.config.yml
#
# Configures about languages.
#
languages:
  # Specifies default language using on testing.
  # If `null`, default to `elixir`.
  primary: null
  #
  # Configure each languages.
  # `source_directory`: if `nil`, finds a source file from `./lib` and `./src`.
  # `path`: is optional.
  # `compiler_path`: set value if there is difference between `path` and `compiler_path`.
  # `prefix`: is optional.
  #
  elixir:
    # If `null`, finds a source file from `./lib` and `./src`.
    # If found multiple find, selects first found file. 
    source_directory: null
    # If 'null', solves `elixir` automatically.
    # Because of finding from export path, does not consider any version.
    path: null
    # If 'null', solves `elixirc` automatically.
    # Because of finding from export path, does not consider any version.
    compiler_path: null
    # If 'null', in case problem number is 10, name of source file is `10.ex`.
    # However, in Elixir, relates closely between file name and module name in point of naming rules.
    # In the above, regards module name as `P10`.
    # Strongly recommends to set `prefix` in Elixir.
    prefix: "p"
  c++11:
    source_directory: null
    path: null
    compiler_path: null
    prefix: null
  ruby:
    source_directory: null
    path: null
    compiler_path: null
    prefix: null
#
# Configures about testcase to download.
#
testcase:
  # Positive integer value more than 10.
  # If `bundile` is 100, directory of testcase for problem 10 is `testcase/100/p10`.
  bundle: null
  # Root direcotry of testcases to download
  directory: "testcase"
  # Prefix of testcase `testcase/p10`
  prefix: "p"
#
# Configures about providers to need to login.
# Supports for only YukiCoder in current version.
#
providers:
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
