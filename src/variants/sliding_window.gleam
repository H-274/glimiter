import birl.{type Time}
import gleam/dict.{type Dict}
import gleam/list
import gleam/order
import gleam/result
import limiter.{type Limiter, type Window, Base}

pub type SlidingWindow(key) =
  Limiter(Dict(key, List(Time)), Window)

pub fn new(window: Window) -> SlidingWindow(key) {
  Base(dict.new(), window)
}

pub fn increment(limiter: SlidingWindow(key), key: key) -> SlidingWindow(key) {
  let now = birl.now()
  let new_list = case dict.get(limiter.data, key) {
    Ok(list) -> [now, ..list]
    Error(_) -> [now]
  }

  dict.insert(limiter.data, key, new_list)
  |> Base(limiter.limit)
}

pub fn cleanup(limiter: SlidingWindow(key), key: key) -> SlidingWindow(key) {
  let filter_result: Result(List(Time), Nil) = {
    use list: List(Time) <- result.try(dict.get(limiter.data, key))

    let new_list: List(Time) = {
      use time: Time <- list.filter(list)

      let window_end_time: Time = birl.add(time, limiter.limit.duration)
      case birl.compare(window_end_time, birl.now()) {
        order.Gt -> True
        _ -> False
      }
    }

    Ok(new_list)
  }

  let limiter: SlidingWindow(key) = case filter_result {
    Ok(new_list) ->
      dict.insert(limiter.data, key, new_list) |> Base(limiter.limit)
    _ -> limiter
  }

  limiter
}

pub fn guard(
  when key: key,
  with limiter: SlidingWindow(key),
  return default: a,
  otherwise f: fn() -> a,
) {
  let result = case dict.get(limiter.data, key) {
    Ok(list) -> list
    Error(_) -> []
  }

  let len = list.length(result)
  case len > limiter.limit.capacity {
    True -> default
    False -> f()
  }
}
