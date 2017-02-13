# This uses the forked and embedded woffTools script, it needs python available, as well
# as woffTools python dependencies.

require 'spec_helper.rb'
require 'tmpdir'

describe WOFF::Builder do
  let(:tmpdir_path) { Dir.mktmpdir }
  let(:output_path) { File.join(tmpdir_path, "with_licensee_and_id.woff") }
  let(:no_metadata_woff_path) { File.expand_path("../data/font-with-no-metadata.woff", __FILE__) }

  after do
    FileUtils.rm_r(tmpdir_path)
  end

  describe "#font_with_licensee_and_id" do
    let(:licensee) { "Some Licensee" }
    let(:id) { "L012356093901" }

    before do
      woff = WOFF::Builder.new(no_metadata_woff_path)

      data = woff.font_with_licensee_and_id("The Friends", "L012356093901")
      File.binwrite(output_path, data)
    end

    it "is valid according to woffTools" do
      validate_script = File.expand_path("../../woffTools/Lib/woffTools/tools/validate.py", __FILE__)
      expect(system("python", validate_script, output_path, "-q")).to be(true)
    end
  end
end
