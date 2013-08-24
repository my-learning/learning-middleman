---
title: Example Article
date: 2012-01-01
tags: example
---

This is an example article. You probably want to delete it and write your own articles!

```ruby
class Person
  attr_reader :name

  def name= name
    @name = name
  end
end

if __FILE__ == $0
  taro = (Person.new.name = "taro")
end
```
