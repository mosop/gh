# Gh

A yet another Crystal library for the GitHub API.

Experimental.

[![Build Status](https://travis-ci.org/mosop/gh.svg?branch=master)](https://travis-ci.org/mosop/gh)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  gh:
    github: mosop/gh
```

<a href="code_examples"></a>

## Code Examples

### Creating Pull Requests

```crystal
params = Gh::PullRequest::CreateParams.new
  .title("Creating Pull Requests")
  .head("john:create_pull_requests")
  .base("master")
  .body(<<-EOS
  Hi @mosop,

  I added the Gh::PullRequest class for creating pull requests.

  Thanks.
  EOS
  )

Gh::PullRequest.create "mosop", "gh", params
```

## Usage

```crystal
require "gh"
```

and see [Code Examples](#code_examples).
