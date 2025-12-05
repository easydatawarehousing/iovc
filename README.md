# Inside-Out Vibe Coding
Vibe code one method at the time.

## What is this?
Primary aim of this exercise is to see how far you can get 'vibe coding' Ruby using only small LLM's.
Why use small LLM's? Efficiency, state-of-the-art models are very inefficient powerwise.
And to be able to run everything on a local machine.

To be succesful with small models (~8..30 billion parameters) I figure you will need to break coding tasks down
into the smallest possible unit of work, i.e. a single method at the time. Similar to how humans code.
To make this work, making clever use of Ruby's strengths is essential.

> The idea is simple, start from an application template: one line of code that calls a method that does not yet exist.  
> Execute the code. Ruby's `method_missing` will intercept the call to the missing method.  
> Ask an LLM to write code for this method given a description of the app.  
> Then repeat: run app again, fill in more missing code and fix errors.  
> Stop when the app returns normal (hopefully the desired) output.

In practice, making this work is a bit more involved than it sounds. LLM's need enough context to produce a useful response.
These scripts are mostly a way to manage context. This is my first attempt, status: _proof of concept_.

## Why is Ruby perfect for this style of vibe coding?
To be able to use this style of vibe coding you will need a flexible programming language. Ruby fits that bill perfectly because:

- Meta programming: catch code that is called but doesn't exist via `method_missing`.
  Captured at the lowest possible level (BasicObject) so it doesn't interfere with Ruby gems that might also be using method_missing
- Parse/unparse: built in code parser (Prism) that lets you locate, manipulate and validate source code.
  Unparser gem (not used currently) to convert back to source code
- Dependency management: easily add dependencies (Ruby gems) via a gemfile and bundler
- Require code: easily require code from Gemfile and all files using Bundler and Zeitwerk gems, no need for the LLM to write 'require' statements
- Typeless/duck typing: less code for an LLM to write, less errors (maybe)
- Error handling: find out where an error occurred with a detailed error message and backtrace (something that all languages support),
  but Ruby can even intercept syntax errors

## How is this different from regular vibe coding?
Current (vibe) coding tools use big LLM's to generate one or more complete files in one go. Then the code is executed and error messages given as feedback to the model.  
Inside-Out Vibe Coding, as the name suggests first runs the program, finds out what needs changing, only then runs an LLM.
It repeats this cycle to work its way out. This is more or less the exact opposite of vibe coding with big LLM's.

## How does it work exactly?
You need a target folder containing at least an [instructions](examples/demo/instructions.md)
file describing what the program is supposed to do.

- Run the iovc script
- This will first copy some template files to the target folder
- If this is a new folder it will ask an LLM for some guidance on structure of the program and any Ruby gems needed
- Then start an endless loop that:
  - runs 'bundle install'
  - runs the target application (in a separate process)
  - captures its output, either:
    - plain text: for normal output of the app
    - json: missing method
    - json: runtime error
    - json: syntax error
  - runs an LLM to handle the output: add missing code or fix an error
  - rinse and repeat until normal output is returned or too many errors occurred

The interesting bit of code that loads code, catches errors and missing methods is in
[ruby/lib/templates/main.rb.tt](examples/demo/main.rb).

## Requirements

- A recent Ruby (3.3+)
- A running [Ollama](https://ollama.com/) instance.
  Any OpenAI compatible API is possible with some tweaking of parameters in [llm.rb](ruby/lib/llm.rb)).
  Even without a GPU you can run Ollama: accept longer response times or use one of the 'cloud' models

## How to run?
Get the code ([source](https://github.com/easydatawarehousing/iovc)):

    git clone github.com/easydatawarehousing/iovc.git
    cd iovc/ruby
    bundle install

Check your Ruby version:

    ruby -v

Optionally edit [ruby/lib/templates/.ruby-version.tt](ruby/lib/templates/.ruby-version.tt)
to match desired Ruby version (only needed when using a Ruby version manager).

Remove the generated demo code (everything but 'instructions.md'), like:

    rm ../examples/demo/README.md
    rm ../examples/demo/*.rb
    rm ../examples/demo/Gemfile
    rm ../examples/demo/Gemfile.lock
    rm ../examples/demo/.ruby-version

Optionally change the `LLM_MODEL_NAMES` constant in [ruby/lib/llm.rb](ruby/lib/llm.rb).
Defaults are 'gpt-oss:20b' and 'qwen3:14b' hosted by a local Ollama.

Run iovc:

    bin/iovc ../examples/demo

All executed prompts and responses are logged to 'ruby/llm_calls.log'.

## Examples
Included are several example apps build by these scripts:
demo, fizzbuzz, wordcount, static_site_generator, cowsay.

Most of these examples were built in one session. Sometimes deleting some generated code and restarting the script.
But to be fair all examples have been retried multiple times to improve the prompts.

Static-site-generator: here I needed to include some instructions on how to use some gems.

Cowsay: this example seems easy (flip the cow to look to the right) but is surprisingly difficult. More instructions were needed and the generated code is still far from correct. GPT5-mini couldn't produce a correct answer either. Gemini3-thinking took 10 minutes then seemed to produce correct code but crashed before I could copy the code.

## Security
These scripts should not be able to read/write outside the given target folder.  
But, the target application has same access right that you have and will do whatever the LLM generated code instructs it to. You have been warned!

## Issues
The script sometimes fails due to:

- Class instance initializers with parameters are currently not supported. LLM sometimes try to do this even though instructions say create an object first and set parameters later
- Sometimes a class definition is added to the response, even when instructions forbid it. Script currently does not handle this situation
- Class level methods not yet supported. LLM's sometimes try to use these, even when instructions forbid it
- Sometimes more context is needed, for instance when negotiating a methods parameters and return value between caller and callee
- Code that uses Ruby's built in gems might actually need require statements, like 'json', usually this fixed in an error step
- An occasional endless loop where the same action is tried again and again

## Features to add
Apart from fixing all issues, some useful features to add:

- Run inside a sandbox (docker, micro vm) for security reasons
- When an error message is returned: find out what the best place is to fix the error, caller or callee?
- Improve logic to find what part of the code needs to be built/fixed/improved and selectively replace methods in existing code.
  Maybe use 'unparser' gem
- Regularly run a 'guidance' step to keep focus on desired output
- Add a workflows to improve code based on human feedback or to add features to existing code
- Ideally use a BDD/TDD approach to steer output in the right direction
- For gem usage, access to their docs is very useful, needs a more agentic style
- How to extend for generating non-Ruby code like html?

## Conclusions
So, does it actually work? Yes. For simple programs.
But there are various issues that need to be addressed for this to become usable.
Good news is that Ruby has everything on board needed for this style of vibe coding.

Small LLM's are not very good at writing Ruby. Often Python like constructs or syntax is used.
Coming up with good algorithms is not a problem for a small LLM,
but proper handling of often used Ruby variable types (like Hash) could be better.

Using one step bigger LLM's (or waiting for improved small models) might show better results.
However I found models like qwen-coder to be very eager to produce more code than requested.
Often these generate the whole solution to the problem instead of just the small part being asked about.
Perhaps more prompt engineering is needed to get these models to perform as desired.

## License
This project is licensed under the MIT License.
You can view the full license text [here](LICENSE.txt).
