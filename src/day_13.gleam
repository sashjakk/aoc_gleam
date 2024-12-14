import advent
import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  let content = advent.read_lines("./input/day_13.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 13, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 13, part: 2, result: result_2)
}

fn part_1(content: List(String)) -> Int {
  parse(content, [])
  |> list.filter_map(win)
  |> list.fold(0, fn(acc, it) { acc + { it.0 * 3 + it.1 * 1 } })
}

fn part_2(content: List(String)) -> Int {
  parse(content, [])
  |> list.map(fn(it) {
    let prize_x = 10_000_000_000_000 + it.prize.0
    let prize_y = 10_000_000_000_000 + it.prize.1
    Machine(..it, prize: #(prize_x, prize_y))
  })
  |> list.filter_map(win)
  |> list.fold(0, fn(acc, it) { acc + { it.0 * 3 + it.1 * 1 } })
}

type Machine {
  Machine(a: #(Int, Int), b: #(Int, Int), prize: #(Int, Int))
}

fn parse(lines: List(String), acc: List(Machine)) {
  case lines {
    [a, b, prize, ..rest] -> {
      let a = parse_line(a, 2)
      let b = parse_line(b, 2)
      let prize = parse_line(prize, 1)
      let machine = Machine(a:, b:, prize:)

      parse(rest, [machine, ..acc])
    }
    _ -> acc
  }
}

fn parse_line(button: String, drop: Int) -> #(Int, Int) {
  let numbers =
    string.split(button, " ")
    |> list.drop(drop)
    |> list.filter_map(fn(it) {
      string.slice(it, 2, string.length(it))
      |> string.replace(",", "")
      |> int.parse
    })

  case numbers {
    [x, y] -> #(x, y)
    _ -> #(0, 0)
  }
}

fn win(machine: Machine) -> Result(#(Int, Int), Nil) {
  let a = machine.a
  let b = machine.b
  let prize = machine.prize

  let determinant = a.0 * b.1 - a.1 * b.0
  use <- bool.guard(determinant == 0, Error(Nil))

  let times_a = prize.0 * b.1 - prize.1 * b.0
  use <- bool.guard(times_a % determinant != 0, Error(Nil))

  let times_b = a.0 * prize.1 - a.1 * prize.0
  use <- bool.guard(times_b % determinant != 0, Error(Nil))

  Ok(#(times_a / determinant, times_b / determinant))
}
