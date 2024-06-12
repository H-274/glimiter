# glimiter

[![Package Version](https://img.shields.io/hexpm/v/glimiter)](https://hex.pm/packages/glimiter)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glimiter/)

### This is meant to be more of a simple proof of concept than anything. I can't figure out a way to make this algorithm work in a real-world scenario using pure gleam (Using wisp for example) because of the immutable nature of gleam

```sh
gleam add glimiter
```
```gleam
import birl/duration
import glimiter

pub fn main() {
  // Creating our limiter to allow 1 request per minute for a given request key
  let limiter = new_limiter(1, duration.minutes(1))

  // When the request arrives
  let limiter = update(limiter, "RequestKey")

  // Using the guard so that when the limit is exceeded, we return the error
  use <- limit_guard(
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

## More Examples

 - [Single Limiter](https://github.com/H-274/glimiter/blob/main/examples/single_limiter.gleam)
 - [Multiple Limiters](https://github.com/H-274/glimiter/blob/main/examples/multi_limiter.gleam)
