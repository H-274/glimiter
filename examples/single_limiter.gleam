import birl/duration
import glimiter

pub fn main() {
  // Creating our limiter to allow 1 request per minute for a given request key
  let limiter =
    new_limiter(1, duration.minutes(1))
    |> update("RequestKey")

  // Using the guard so that when the limit is exceeded, we return the error
  use <- limit_guard(
    when: limiter,
    with: "RequestKey",
    return: Error("Request limit exceeded"),
  )

  Ok("Response")
}
