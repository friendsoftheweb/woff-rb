require "woff/version"
require "zlib"
require "brotli"
require "bindata"
require "rexml/document"
require "woff/file"
require "woff/builder"

module WOFF
  class FontNotFoundError < StandardError
    def initialize(msg = "The font file could not be located. Font building failed.")
      super(msg)
    end
  end

  class InvalidSignatureError < StandardError
    def initialize(msg = "The WOFF file contains an invalid WOFF or WOFF2 signature.")
      super(msg)
    end
  end
end
