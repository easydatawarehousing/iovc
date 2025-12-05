# Goal
The overall goal is to: ${instructions}

# Environment
The current code is:

``` ruby
${code}
```

# Task
- Describe what the structure of the code should look like.
- Describe what classes are needed to implement the code structure.
- Think about clear separation of concerns.
- Specify which Ruby gems will be needed, if any.

# Response
Respond in json using this format:

``` json
{
  "structure": "Elaborate description of the application and code structure",
  "classes": [
    {
      "class_name": "name", "class_description": "Short description of purpose of the class"
    }
  ],
  "gem_names": []
}
```