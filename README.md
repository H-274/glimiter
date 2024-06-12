# glimiter

[![Package Version](https://img.shields.io/hexpm/v/glimiter)](https://hex.pm/packages/glimiter)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glimiter/)

```sh
gleam add glimiter
```
```gleam
import birl/duration
import glimiter

pub fn main() {
  // Creating our limiter to allow 1 request per minute for a given request key
  let limiter = glimiter.new_limiter(1, duration.minutes(1))

  // Using the guard so that when the limit is exceeded, we return the error
  use <- glimiter.limit_guard(
    when: limiter,
    with: "RequestKey",
    return: Error("Request limit exceeded"),
  )

  Ok("Response")
}
```

Further documentation can be found at <https://hexdocs.pm/glimiter>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
