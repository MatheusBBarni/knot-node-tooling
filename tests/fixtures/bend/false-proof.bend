import Base

law add_zero:
  for x: Nat
  {Nat.add(x, 0n) == x : Nat}

def add_zero(x):
  {==}
