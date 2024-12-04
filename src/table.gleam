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
