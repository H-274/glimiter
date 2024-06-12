import birl/duration
import gleam/dict.{type Dict}
import glimiter.{type Limiter}

pub type Context {
  Context(limiters: Dict(String, Limiter))
}

pub type Req {
  Req(user: String)
}

pub fn main() {
  let route = "route1"
  let req: Req = Req("someIp")

  // Creating our limiters
  let limiter1 = glimiter.new_limiter(1, duration.minutes(1))
  let limiter2 = glimiter.new_limiter(2, duration.minutes(1))
  let limiter3 = glimiter.new_limiter(3, duration.minutes(1))

  // We add the limiters to some form of client
  let context =
    Context(
      dict.from_list([
        #("route1", limiter1),
        #("route2", limiter2),
        #("route3", limiter3),
      ]),
    )

  case route {
    "route1" -> handle_route1(req, context)
    "route2" -> handle_route2(req, context)
    _ -> handle_route3(req, context)
  }
}

fn handle_route1(req: Req, ctx: Context) {
  let assert Ok(route_limiter) = dict.get(ctx.limiters, "route1")
  use <- glimiter.limit_guard(
    when: route_limiter,
    with: "route1" <> req.user,
    return: Error("Route 1 Rate limit exceeded"),
  )

  Ok("Route 1 Result")
}

fn handle_route2(req: Req, ctx: Context) {
  let assert Ok(route_limiter) = dict.get(ctx.limiters, "route2")
  use <- glimiter.limit_guard(
    when: route_limiter,
    with: "route2" <> req.user,
    return: Error("Route 2 Rate limit exceeded"),
  )

  Ok("Route 2 Result")
}

fn handle_route3(req: Req, ctx: Context) {
  let assert Ok(route_limiter) = dict.get(ctx.limiters, "route3")
  use <- glimiter.limit_guard(
    when: route_limiter,
    with: "route3" <> req.user,
    return: Error("Route 3 Rate limit exceeded"),
  )

  Ok("Route 3 Result")
}
