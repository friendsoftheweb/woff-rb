# This uses the forked and embedded woffTools script, it needs python available, as well
# as woffTools python dependencies.

require 'spec_helper.rb'
require 'tmpdir'

describe "#font_with_licensee_and_id" do
  let(:no_metadata_woff_path) { File.expand_path("../data/font-with-no-metadata.woff", __FILE__) }
  let(:output_path) { File.join(Dir.mktmpdir, "with_licensee_and_id.woff") }

  let(:licensee) { "Some Licensee" }
  let(:id) { "L012356093901" }

  after do
    FileUtils.rm(output_path)
  end

  before do
    woff = WOFF::Builder.new(no_metadata_woff_path)

    data = woff.font_with_licensee_and_id("The Friends", "L012356093901")
    File.binwrite(output_path, data)
  end

  it "is valid according to woffTools" do
    validate_script = File.expand_path("../../../woffTools/Lib/woffTools/tools/validate.py", __FILE__)
    expect(system("python", validate_script, output_path, "-q")).to be(true)
  end

end
