import gleam/list

pub fn add(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  #(a.0 + b.0, a.1 + b.1)
}

pub fn subtract(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  #(a.0 - b.0, a.1 - b.1)
}

pub fn in_range(a: #(Int, Int), min: #(Int, Int), max: #(Int, Int)) {
  { a.0 >= min.0 && a.0 <= max.0 } && { a.1 >= min.1 && a.1 <= max.1 }
}

pub fn neighbours_4(a: #(Int, Int)) -> List(#(Int, Int)) {
  use item <- list.map([#(0, 1), #(1, 0), #(-1, 0), #(0, -1)])
  add(a, item)
}
