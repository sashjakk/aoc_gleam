import advent
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn main() {
  let lines = advent.read_lines("./input/day_24.txt")

  let wires =
    lines
    |> list.filter_map(parse_wire)
    |> dict.from_list

  let gates = list.filter_map(lines, parse_gate)
  let network = parse_network(gates)

  network
  |> dict.fold([], fn(acc, key, _) {
    use <- bool.guard(!string.starts_with(key, "z"), acc)
    [#(key, get_signal_value(network, wires, key)), ..acc]
  })
  |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
  |> list.fold("", fn(acc, it) { int.to_string(it.1) <> acc })
  |> int.base_parse(2)
  |> echo
}

type Wire =
  #(String, Int)

fn parse_wire(line: String) -> Result(Wire, Nil) {
  case string.split(line, ": ") {
    [key, value] -> {
      use value <- result.try(int.parse(value))
      Ok(#(key, value))
    }
    _ -> Error(Nil)
  }
}

type Gate {
  Gate(from: String, to: String, target: String, apply: fn(Int, Int) -> Int)
}

fn parse_gate(line: String) -> Result(Gate, Nil) {
  case string.split(line, " ") {
    [from, "AND", to, _, target] ->
      Gate(from, to, target, int.bitwise_and) |> Ok
    [from, "OR", to, _, target] -> Gate(from, to, target, int.bitwise_or) |> Ok
    [from, "XOR", to, _, target] ->
      Gate(from, to, target, int.bitwise_exclusive_or) |> Ok
    _ -> Error(Nil)
  }
}

pub type Network =
  Dict(String, List(Gate))

fn parse_network(gates: List(Gate)) -> Network {
  let upsert = fn(dependencies: List(Gate)) {
    fn(existing: option.Option(List(Gate))) {
      case existing {
        option.None -> dependencies
        option.Some(values) ->
          [values, dependencies]
          |> list.flatten
          |> list.unique
      }
    }
  }

  use network, gate <- list.fold(gates, dict.new())

  network
  |> dict.upsert(gate.target, upsert([gate]))
  |> dict.upsert(gate.from, upsert([]))
  |> dict.upsert(gate.to, upsert([]))
}

fn get_signal_value(
  network: Network,
  signals: Dict(String, Int),
  key: String,
) -> Int {
  case dict.get(signals, key) {
    Ok(value) -> value
    Error(_) -> {
      dict.get(network, key)
      |> result.unwrap([])
      |> list.map(fn(it) {
        let Gate(from, to, _, apply) = it
        let a = get_signal_value(network, signals, from)
        let b = get_signal_value(network, signals, to)
        apply(a, b)
      })
      |> int.sum
    }
  }
}
