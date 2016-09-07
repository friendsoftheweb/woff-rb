require "woff/version"
require "zlib"
require "bindata"
require "rexml/document"
require "woff/builder"
require "woff/data"

module WOFF
  class FontNotFoundError < StandardError
    def initialize(msg = "The font file could not be located. Font building failed.")
      super(msg)
    end
  end
end
