The application is a small command‑line tool that takes an optional string argument, runs the external `cowsay` program to generate the cow ASCII art, then processes that output to flip the cow’s direction so it looks to the right. The code is split into three main responsibilities:

1. **App** – The entry point that parses the command‑line argument, orchestrates the other components, and prints the final result.
2. **CowsayRunner** – Encapsulates the logic for invoking the `cowsay` command and capturing its output. It uses Ruby’s `Open3` module to run the command safely and return the full string.
3. **CowDirectionReverser** – Contains the algorithm that takes the raw cowsay output, identifies the cow art block, and transforms the left‑looking cow into a right‑looking one. It only manipulates the ASCII art lines, leaving the text and surrounding dashes untouched.

The flow is:
```
App.parse_args -> CowsayRunner.run -> CowDirectionReverser.reverse -> App.print
```
This separation keeps each class focused on a single concern and makes the code easier to test and maintain.