require "membrane/schema/any"
require "membrane/schema/base"
require "membrane/schema/bool"
require "membrane/schema/class"
require "membrane/schema/dictionary"
require "membrane/schema/enum"
require "membrane/schema/list"
require "membrane/schema/record"
require "membrane/schema/regexp"
require "membrane/schema/tuple"
require "membrane/schema/value"

module Membrane
  module Schema
    ANY = Membrane::Schema::Any.new
  end
end
