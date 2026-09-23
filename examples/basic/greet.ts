interface Person {
  name: string;
}

type Greeting = string;

export function greet(person: Person): Greeting {
  return "hello " + person.name;
}

const message: Greeting = greet({ name: "knot" });
console.log(message);
