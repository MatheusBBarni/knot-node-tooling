export function greet(name: string): string {
  return "hello " + name;
}

const message: string = greet("knot");
console.log(message);
