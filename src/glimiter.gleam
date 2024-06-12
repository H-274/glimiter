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
  otherwise alternetive: fn(Limiter) -> a,
) -> a {
  let limiter = Limiter(add(limiter, key), limiter.count, limiter.duration)
  let limiter =
    Limiter(filter_prev_window(limiter, key), limiter.count, limiter.duration)

  let assert Ok(times) = dict.get(limiter.cache, key)
  case list.length(times) < limiter.count {
    True -> alternetive(limiter)
    False -> consequence
  }
}

fn add(limiter: Limiter, key: String) -> Dict(String, List(Time)) {
  let now = time.now()

  case dict.get(limiter.cache, key) {
    Ok(timestamps) -> {
      dict.insert(limiter.cache, key, [now, ..timestamps])
    }

    Error(_) -> {
      dict.insert(limiter.cache, key, [now])
    }
  }
}

fn filter_prev_window(limiter: Limiter, key: String) -> Dict(String, List(Time)) {
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
}
