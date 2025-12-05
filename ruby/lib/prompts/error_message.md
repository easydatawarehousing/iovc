# Goal
The overall goal is to: ${instructions}

# Environment
The current code is:

``` ruby
${code}
```

# Task
- The code returns error with message: '${error_message}'. Rewrite the code to fix the error
- Specify which additional Ruby gems are needed, if any. Do NOT write `require` statements for these gems
- Keep all code comments

# Response
Respond in json using this format:

``` json
{
  "code": "New code",
  "gem_names": []
}
```