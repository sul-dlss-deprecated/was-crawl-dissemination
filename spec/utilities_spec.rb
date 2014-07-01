
require 'spec_helper'
require 'utilities'


describe Dor::WASCrawl::Dissemination::Utilities do

  context ".run_sys_cmd" do
    before(:all) do
    end

    it "should return nothing with succesful command" do
      Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd("ls","")
    end
    
    it "should raise an error with wrong command" do
      expect{ Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd("lss","") }.to raise_error
    end
    
    after(:all) do
    end
  end
  
  context ".prepare_new_file_list" do
    
    it "should return a list for the extrcted arc and warc files" do
      content_metadata_xml_location = "fixtures/metadata/" 
      contentMetadata = File.open(content_metadata_xml_location+"contentMetadata_3files.xml").read

      file_list = Dor::WASCrawl::Dissemination::Utilities.get_warc_file_list_from_contentMetadata(contentMetadata)
      expect(file_list.length).to eq(2) 
    end
    
    it "should return an empty list for the contentMetadata with no arcs or warcs inside" do
      content_metadata_xml_location = "fixtures/metadata/" 
      contentMetadata = File.open(content_metadata_xml_location+"contentMetadata_0file.xml").read

      file_list = Dor::WASCrawl::Dissemination::Utilities.get_warc_file_list_from_contentMetadata(contentMetadata)
      expect(file_list).not_to be_nil
      expect(file_list.length).to eq(0) 

    end
    
  end

end