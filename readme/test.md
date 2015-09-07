# knife.test

A fixture-free test framework.

```lua
local T = require 'knife.test'
```

## T (title, section)

Create a test case section.

### Parameters

- *string* **label**

  Label for the test case section.

- *function* **section (T)**

  Function containing the body of the section. Should define a single parameter
  `T` which shadows the outer `T`, providing the same API.

### Example

```lua
T('Given a value of 1', function (T)
    local value = 1
    T('When incremented by 1', function (T)
        value = value + 1
        -- assertion goes here
    end)
end)
```

## T:assert (value, label)

Assert that `value` is truthy.  

### Parameters

- *mixed* **value**

  A value (generally the result of an expression) that should be truthy.
  If the value is `nil` or `false`, the test fails, otherwise it passes.

- *string* **label**

  Label for the assertion.

### Example

```lua
T:assert(value == 2, 'Then the value is equal to 2')
```

## T:error (func, label)

Assert that `func` throws an error when invoked.  

### Parameters

- *function* **func**

  A function that should throw an error when invoked.
  If the function throws an error, the test passes, otherwise it fails.

- *string* **label**

  Label for the assertion.

### Example

```lua
T:error(function () error 'oops' end,
    'Then an error is thrown')
```

## Caveats/features

- The power of this test framework comes from its *isolated sections*.
  When executing a test, the entire test is executed from the root section for
  each leaf section. This makes fixtures unnecessary, as each section serves
  to initialize state for inner sections. This is best illustrated by example:

  ```lua
  T('Given a value of 1', function (T)
      local value = 1
      T('When incremented by 1', function (T)
          assert(value == 1)
          value = value + 1
          T:assert(value == 2, 'Then the value is equal to 2')
      end)
      T('When incremented by 2', function (T)
          assert(value == 1) -- value is 1 again here!
          value = value + 2
          T:assert(value == 3, 'Then the value is equal to 3')
      end)
  end)
  ```

- The module may be run from the command line.

  ```bash
  lua knife/test.lua spec/foo.lua spec/bar.lua
  ```

  When run from the command line, `T` is exported into the global environment.
