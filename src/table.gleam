import gleam/list
import gleam/bool
import gleam/dict.{type Dict}

pub type Table =
  Dict(#(Int, Int), String)

pub fn from(content: List(String)) -> Table {
  do_from(content, #(0, 0), dict.new())
}

fn do_from(
  content: List(String),
  position: #(Int, Int),
  table: Dict(#(Int, Int), String),
) -> Table {
  case content {
    [] -> table
    [it, ..rest] ->
      case it {
        "\n" -> do_from(rest, #(position.0 + 1, 0), table)
        value ->
          do_from(
            rest,
            #(position.0, position.1 + 1),
            dict.insert(table, position, value),
          )
      }
  }
}

pub fn snapshot(table: Table) {
  do_snapshot(table, 0, 0, "")
}

fn do_snapshot(grid: Table, row: Int, column: Int, acc: String) {
  use <- bool.guard(
    when: grid
      |> dict.keys
      |> list.is_empty,
    return: acc,
  )

  case dict.get(grid, #(row, column)) {
    Ok(key) -> {
      let next_grid = grid |> dict.delete(#(row, column))
      do_snapshot(next_grid, row, column + 1, acc <> key)
    }
    Error(_) -> do_snapshot(grid, row + 1, 0, acc <> "\n")
  }
}
