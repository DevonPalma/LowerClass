local function test()
    -- Load the lowerclass module
    local lowerclass = require('lib.LowerClass')

    -- Create a mixin with shared methods
    ---@class MyMixin
    local MyMixin = {
        mixinVar = "This is a mixin variable",
        greet = function(self)
            print("Hello from Mixin!")
        end,
        included = function(self, class)
            print(class.name .. " has included MyMixin.")
        end,
    }

    -- -------------------------------------------------------------------------- --
    --                                Basic Class                                 --
    -- -------------------------------------------------------------------------- --

    -- Create a basic class with an initializer
    ---@class Animal : Class
    local Animal = lowerclass("Animal")

    -- Define __init, a variable, and a method in the Animal class
    function Animal:__init(name)
        self.name = name
    end

    Animal.species = "Generic Animal"
    function Animal:speak()
        print("Animal sound!")
    end

    -- Create an instance of Animal and test it
    local animalInstance = Animal:new("Buddy")
    print("Name:", animalInstance.name)       -- Output: Buddy
    print("Species:", animalInstance.species) -- Output: Generic Animal
    animalInstance:speak()                    -- Output: Animal sound!

    print()
    -- -------------------------------------------------------------------------- --
    --                             Class with Mixin                               --
    -- -------------------------------------------------------------------------- --

    -- Create a new class and include MyMixin
    ---@class Dog : Class, MyMixin
    local Dog = lowerclass("Dog")
    Dog:include(MyMixin)

    -- Add specific properties, an initializer, and methods to Dog
    function Dog:__init(name, breed)
        self.name = name
        self.breed = breed
    end

    Dog.species = "Dog"
    function Dog:speak()
        print("Woof! Woof!")
    end

    -- Create an instance of Dog and test it
    local dogInstance = Dog:new("Rover", "Labrador")
    print("Name:", dogInstance.name)   -- Output: Rover
    print("Breed:", dogInstance.breed) -- Output: Labrador
    dogInstance:speak()                -- Output: Woof! Woof!
    dogInstance:greet()                -- Output: Hello from Mixin!

    print()
    print()

    -- -------------------------------------------------------------------------- --
    --                             Class with Metamethods                          --
    -- -------------------------------------------------------------------------- --

    -- Define a Point class with `__index` and `__add` metamethods
    ---@class Point : Class
    ---@operator add: Point
    local Point = lowerclass("Point")

    -- Add initializer for Point
    function Point:__init(x, y)
        self.x = x or 0
        self.y = y or 0
    end

    -- Define a default value for z using __index
    function Point.__index(tbl, key)
        if key == "z" then
            return 0 -- default value for z
        end
    end

    -- Define an __add metamethod for Point
    function Point.__add(a, b)
        return Point:new(a.x + b.x, a.y + b.y)
    end

    -- Create two Point instances
    local point1 = Point:new(1, 2)
    local point2 = Point:new(3, 4)

    -- Access the default value for z
    print("Point1 Z:", point1.z) -- Output: 0

    -- Add points using the __add metamethod
    local resultPoint = point1 + point2
    print("Resulting Point:", resultPoint.x, resultPoint.y) -- Output: 4, 6
end

return test
