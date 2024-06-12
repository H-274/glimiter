import birl.{type Time} as time
import birl/duration.{type Duration}
import gleam/dict.{type Dict}
import gleam/list
import gleam/order

pub opaque type Limiter {
  Limiter(cache: Dict(String, List(Time)), count: Int, duration: Duration)
}

pub fn new_limiter(count: Int, size: Duration) -> Limiter {
  Limiter(dict.new(), count, size)
}

pub fn limit_guard(
  when limiter: Limiter,
  with key: String,
  return consequence: a,
  otherwise alternetive: fn() -> a,
) -> a {
  add(limiter, key)
  filter_prev_window(limiter, key)

  let assert Ok(times) = dict.get(limiter.cache, key)
  case list.length(times) < limiter.count {
    True -> alternetive()
    False -> consequence
  }
}

fn add(limiter: Limiter, key: String) -> Nil {
  let now = time.now()

  case dict.get(limiter.cache, key) {
    Ok(timestamps) -> dict.insert(limiter.cache, key, [now, ..timestamps])
    Error(_) -> dict.insert(limiter.cache, key, [now])
  }

  Nil
}

fn filter_prev_window(limiter: Limiter, key: String) -> Nil {
  let assert Ok(times) = dict.get(limiter.cache, key)
  let now = time.now()

  let new_times =
    list.filter(times, fn(time) {
      let end_time = time.add(time, limiter.duration)
      case time.compare(now, end_time) {
        order.Lt | order.Eq -> True
        _ -> False
      }
    })
  dict.insert(limiter.cache, key, new_times)

  Nil
}
