main() {
    x -> int = 15;          // defined
    z -?;                   // undefined until assignment, default 0
    
    echo("Hello, Love, Again", s: "", e: ""); // custom delimiters
    echo(x);
    
    if : x > 30 : {
        echo("Big Boi");
    } else if : x == 30 : {
        echo("Average")
    } others {
        echo("Small Boi");
    }
    z -> int;               // explicit type declaration
    z = 0;                  // assigns value

    while : z < 10 : {
        z++;                // increment operation
        echo(z);            // auto-appends a newline
    }

    y = x + z * 2 / 4;      // implicit order of operations
    echo(y);                // smart output formatting
}


func sample(param1: x, param2: {}) -> int {
    num -> int = x + 10;   // local variable declaration
    push :: num;           // return value
}