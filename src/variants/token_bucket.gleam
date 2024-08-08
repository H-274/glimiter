import gleam/dict.{type Dict}
import limiter.{type Limiter, Base}

pub type TokenBucket(key) =
  Limiter(Dict(key, Int), Int)

pub fn new(limit: Int) -> TokenBucket(key) {
  Base(dict.new(), limit)
}

pub fn increment(limiter: TokenBucket(key), key: key) -> TokenBucket(key) {
  let count: Int = case dict.get(limiter.data, key) {
    Ok(val) -> val + 1
    _ -> 1
  }

  dict.insert(limiter.data, key, count)
  |> Base(limiter.limit)
}

pub fn decrement(limiter: TokenBucket(key), key: key) -> TokenBucket(key) {
  let count: Int = case dict.get(limiter.data, key) {
    Ok(val) if val > 0 -> val - 1
    _ -> 0
  }

  dict.insert(limiter.data, key, count)
  |> Base(limiter.limit)
}

pub fn guard(
  given limiter: TokenBucket(key),
  with key: key,
  return default: response,
  otherwise continue: fn() -> response,
) {
  let count = case dict.get(limiter.data, key) {
    Ok(val) -> val
    _ -> 0
  }

  case count <= limiter.limit {
    True -> continue()
    _ -> default
  }
}
