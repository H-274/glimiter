import birl.{type Time}
import birl/duration.{type Duration}
import gleam/dict.{type Dict}
import gleam/list
import gleam/order
import gleam/result

pub type Window {
  Window(count: Int, duration: Duration)
}

pub opaque type Limiter(k) {
  Limiter(data: Dict(k, List(Time)), window: Window)
}

pub fn new(window: Window) -> Limiter(k) {
  Limiter(dict.new(), window)
}

fn increment(limiter: Limiter(k), key: k) -> Limiter(k) {
  let now = birl.now()
  let new_list = case dict.get(limiter.data, key) {
    Ok(list) -> [now, ..list]
    Error(_) -> [now]
  }

  key_insert(limiter, key, new_list)
}

fn key_insert(limiter: Limiter(k), key: k, list: List(Time)) {
  list
  |> dict.insert(limiter.data, key, _)
  |> fn(d) { Limiter(..limiter, data: d) }
}

fn filter(limiter: Limiter(k), key: k) -> Limiter(k) {
  let filter_result: Result(List(Time), Nil) = {
    use list: List(Time) <- result.try(dict.get(limiter.data, key))

    let new_list: List(Time) = {
      use time: Time <- list.filter(list)

      let window_end_time: Time = birl.add(time, limiter.window.duration)
      case birl.compare(window_end_time, birl.now()) {
        order.Lt -> False
        _ -> True
      }
    }

    Ok(new_list)
  }

  let limiter: Limiter(k) = case filter_result {
    Ok(new_list) -> key_insert(limiter, key, new_list)
    _ -> limiter
  }

  limiter
}

pub fn update(limiter: Limiter(k), key: k) -> Limiter(k) {
  let limiter = increment(limiter, key)
  let limiter = filter(limiter, key)

  limiter
}

pub fn guard(
  when key: k,
  with limiter: Limiter(k),
  return default: a,
  otherwise f: fn() -> a,
) {
  let result = case dict.get(limiter.data, key) {
    Ok(list) -> list
    Error(_) -> []
  }

  let len = list.length(result)
  case len > limiter.window.count {
    True -> default
    False -> f()
  }
}
