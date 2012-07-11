# Membrane

Membrane provides an easy to use DSL for specifying validators declaratively.
It's intended to be used to validate data received from external sources,
such as API endpoints or config files. Use it at the edges of your process to
decide what data to let in and what to keep out.

## Overview

The core concept behind Membrane is the ```schema```. A ```schema```
represents an invariant about a piece of data (similar to a type) and is
capable of verifying whether or not a supplied datum satisfies the
invariant. Schemas may be composed together to produce more expressive
constructs.

Membrane provides a handful of useful schemas out of the box. You should be
able to construct the majority of your schemas using only what is provided
by default. The provided schemas are:

* _Any_        - Accepts all values. Use it sparingly. It is synonymous to
  class Object in Ruby.
* _Bool_       - Accepts ```true``` and ```false```.
* _Class_      - Accepts instances of a supplied class.
* _Dictionary_ - Accepts hashes whose keys and values validate against their
  respective schemas.
* _Enum_       - Accepts values that validate against _any_ of the supplied
  schemas. Similar to a sum type.
* _List_       - Accepts arrays where each element of the array validates
  against a supplied schema.
* _Record_     - Accepts hashes with known keys. Each key has a supplied schema,
  against which its value must validate.
* _Regexp_     - Accepts strings that match a supplied regular expression.
* _Tuple_      - Accepts arrays of a given length whose elements validate
  against their respective schemas.
* _Value_      - Accepts values using ```==```.

## Usage

Membrane schemas are typically created using a concise DSL. For example, the
following creates a schema that will validate a hash where the key "ints"
maps to a list of integers and the key "string" maps to a string.

    schema = Membrane::SchemaParser.parse do
      { "ints"   => [Integer],
        "string" => String,
      }
    end

    # Validates successfully
    schema.validate({
      "ints"   => [1],
      "string" => "hi",
    })

    # Fails validation. The key "string" is missing and the value for "ints"
    # isn't the correct type.
    schema.validate({
      "ints" => "invalid",
    })

This is a more complicated example that illustrate the entire DSL. It should
be self-explanatory.

    Membrane::SchemaParser.parse do
      { "ints"          => [Integer]
        "true_or_false" => bool,
        "anything"      => any, # You can also use Object instead.
        optional("_")   => any,
        "one_or_two"    => enum(1, 2),
        "strs_to_ints"  => dict(String, Integer),
        "foo_prefix"    => /^foo/,
        "three_ints"    => tuple(Integer, Integer, Integer),
      }
    end

## Adding new schemas

Adding a new schema is trivial. Any class implementing the following "interface"
can be used as a schema:

    # @param [Object] The object being validated.
    #
    # @raise [Membrane::SchemaValidationError] Raised when a supplied object is
    # invalid.
    #
    # @return [nil]
    def validate(object)

If you wish to include your new schema as part of the DSL, you'll need to
modify ```membrane/schema_parser.rb``` and have your class inherit from
```Membrane::Schema::Base```
