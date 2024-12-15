import advent
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  let content = advent.read_lines("./input/day_14.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 14, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 14, part: 2, result: result_2)
}

fn part_1(content: List(String)) -> Int {
  let space = #(101, 103)

  let robots =
    content
    |> list.map(to_robot)
    |> list.map(move(_, space, 100))

  [
    Quadrant(left: 0, right: space.0 / 2 - 1, top: 0, bottom: space.1 / 2 - 1),
    Quadrant(
      left: space.0 / 2 + 1,
      right: space.0,
      top: 0,
      bottom: space.1 / 2 - 1,
    ),
    Quadrant(
      left: 0,
      right: space.0 / 2 - 1,
      top: space.1 / 2 + 1,
      bottom: space.1,
    ),
    Quadrant(
      left: space.0 / 2 + 1,
      right: space.0,
      top: space.1 / 2 + 1,
      bottom: space.1,
    ),
  ]
  |> list.map(count(_, robots))
  |> int.product
}

fn part_2(content: List(String)) -> Int {
  let space = #(101, 103)
  let robots = list.map(content, to_robot)
  find_xmas_tree(robots, space, 0)
}

type Robot {
  Robot(position: #(Int, Int), velocity: #(Int, Int))
}

fn to_robot(line: String) -> Robot {
  let parsed =
    line
    |> string.split(" ")
    |> list.map(fn(it) { string.slice(it, 2, string.length(it)) })
    |> list.map(fn(it) {
      let coordinates =
        string.split(it, ",")
        |> list.filter_map(int.parse)

      case coordinates {
        [x, y] -> #(x, y)
        _ -> #(0, 0)
      }
    })

  case parsed {
    [position, velocity] -> Robot(position:, velocity:)
    _ -> Robot(position: #(0, 0), velocity: #(0, 0))
  }
}

fn move(robot: Robot, size: #(Int, Int), seconds: Int) -> Robot {
  let x =
    { robot.position.0 + seconds * { robot.velocity.0 + size.0 } } % size.0

  let y =
    { robot.position.1 + seconds * { robot.velocity.1 + size.1 } } % size.1

  Robot(..robot, position: #(x, y))
}

type Quadrant {
  Quadrant(left: Int, right: Int, top: Int, bottom: Int)
}

fn count(quadrant: Quadrant, robots: List(Robot)) {
  use robot <- list.count(robots)
  let x =
    robot.position.0 >= quadrant.left && robot.position.0 <= quadrant.right
  let y =
    robot.position.1 >= quadrant.top && robot.position.1 <= quadrant.bottom
  x && y
}

fn find_xmas_tree(robots: List(Robot), size: #(Int, Int), acc: Int) {
  let next = robots |> list.map(move(_, size, 1))
  let unique = robots |> list.map(fn(it) { it.position }) |> list.unique
  case list.length(robots) == list.length(unique) {
    True -> acc
    False -> find_xmas_tree(next, size, acc + 1)
  }
}
