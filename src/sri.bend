import Base

def sri_ok(got: String, integrity: String) -> Bool:
  String.eq("sha512-" ++ got, integrity)
