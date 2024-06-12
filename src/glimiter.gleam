import birl.{type Time} as time
import birl/duration.{type Duration}
import gleam/dict.{type Dict}
import gleam/list
import gleam/order

pub opaque type Limiter(a) {
  Limiter(cache: Dict(a, List(Time)), count: Int, duration: Duration)
}

pub fn new_limiter(count: Int, size: Duration) -> Limiter(a) {
  Limiter(dict.new(), count, size)
}

pub fn update(limiter: Limiter(a), key: a) -> Limiter(a) {
  let limiter = Limiter(add(limiter, key), limiter.count, limiter.duration)

  Limiter(filter_prev_window(limiter, key), limiter.count, limiter.duration)
}

pub fn limit_guard(
  when limiter: Limiter(a),
  with key: a,
  return consequence: b,
  otherwise alternetive: fn() -> b,
) -> b {
  let assert Ok(times) = dict.get(limiter.cache, key)
  case list.length(times) < limiter.count {
    True -> alternetive()
    False -> consequence
  }
}

fn add(limiter: Limiter(a), key: a) -> Dict(a, List(Time)) {
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

fn filter_prev_window(limiter: Limiter(a), key: a) -> Dict(a, List(Time)) {
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
