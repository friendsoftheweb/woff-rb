# WOFF

This reads binary data from WOFF files in pure Ruby and allows limited
modification of metadata.

## Installation

Add this line to your application's Gemfile:

    gem 'woff', '~> 1.0.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install woff

## Usage

Used in generation of WOFF files. Returns the data to be written to a file or
sent to the Zip gem of your choice.

```ruby
woff = WOFF::Builder.new("/Users/Desktop/sample.woff")

# This will set or update the metadata's licensee name to `The Friends` and the
# metadata's license id to `L012356093901`.
data = woff.font_with_licensee_and_id("The Friends", "L012356093901")

File.write("/Users/Desktop/sample-with-metadata.woff", data)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
