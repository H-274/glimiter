import birl/duration.{type Duration}

pub type Window {
  Window(capacity: Int, duration: Duration)
}

pub type Limiter(data, limit) {
  Base(data: data, limit: limit)
}
