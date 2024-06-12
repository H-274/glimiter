import birl/duration
import gleam/dict.{type Dict}
import gleam/io
import glimiter.{type Limiter}

pub type Context {
  Context(String)
}

pub type Req {
  Req(user: String)
}

pub fn main() {
  let ctx = Context("")
  let route = "route1"

  let limiters =
    dict.from_list([
      #("limiter1", new_limiter(10, duration.seconds(10))),
      #("limiter2", new_limiter(1, duration.seconds(10))),
    ])

  let res = handle(route, ctx, limiters)
  let _limiters = res.1
}

pub fn handle(
  route: String,
  ctx: Context,
  limiters: Dict(String, Limiter(String)),
) -> #(Result(String, String), Dict(String, Limiter(String))) {
  case route {
    "route1" -> {
      let assert Ok(limiter) = dict.get(limiters, "limiter1")
      let limiter = update(limiter, "key")
      let res = route1(ctx, limiter)

      #(res, dict.insert(limiters, "key", limiter))
    }
    "route2" -> {
      let assert Ok(limiter) = dict.get(limiters, "limiter2")
      let limiter = update(limiter, "key")
      let res = route2(ctx, limiter)

      #(res, dict.insert(limiters, "key", limiter))
    }
    _ -> {
      let assert Ok(limiter) = dict.get(limiters, "limiter1")
      let limiter = update(limiter, "key")

      #(Error("Not found"), dict.insert(limiters, "key", limiter))
    }
  }
}

fn route1(_ctx: Context, limiter: Limiter(String)) -> Result(String, String) {
  use <- limit_guard(when: limiter, with: "key", return: Error("Err"))

  Ok("Ok1")
}

fn route2(_ctx: Context, limiter: Limiter(String)) -> Result(String, String) {
  use <- limit_guard(when: limiter, with: "key", return: Error("Err"))

  Ok("Ok2")
}
