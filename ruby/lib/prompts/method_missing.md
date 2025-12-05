# Goal
The overall goal is to: ${instructions}

# Environment
About this app:
${readme}

The current code is:

``` ruby
${code}
```

# Task
- The `${method_missing}` function is called but not present. Write the code to implement the missing function. Do not repeat the class definition.${arguments}
- Specify which additional Ruby gems are needed, if any. Do NOT write `require` statements for these gems
- Only write instance methods. Do NOT use `result = MyClass.get_result` but `my_class = MyClass.new; result = my_class.get_result`
- Never call the new method with parameters, instead create a new object and then call one of its methods. Do NOT use `my_class = MyClass.new(param)` but `my_class = MyClass.new; my_class.my_method(param)`

# Response
Respond in json using this format:

``` json
{
  "code": "Code for the ${method_missing} function",
  "gem_names": []
}
```

Only write code for the missing function, do NOT repeat the current code, do NOT add a `class` definition and do NOT write any other functions! Pretend that any functions you want to call exist.