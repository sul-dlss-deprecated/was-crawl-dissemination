require 'spec_helper'
require 'path_indexer_service'

#  specify { expect(3).to eq(3) }
#  specify { expect(3).not_to eq(4) }
#  specify { expect { raise "boom" }.to raise_error("boom") }
#  specify { expect { }.not_to raise_error }

describe Dor::WASCrawl::PathIndexerService do
  
  before(:all) do
    @stacks_path = Pathname(File.dirname(__FILE__)).join("../fixtures/stacks")
    @path_files = Pathname(File.dirname(__FILE__)).join("../fixtures/path_files")
    @path_working_directory = "#{@stacks_path}/data/indecies/path_working"
    @collection_path = "#{@stacks_path}/data/collections/test_collection"
  end
  
  context ".merge" do
    
    before(:all) do
      @druid = "druid:dd111dd1111"
      @content_metadata_xml_location = "fixtures/metadata/"
    end
  
    it "should merge results from contentMetadata to the main path index" do
      contentMetadata = File.open(@content_metadata_xml_location+"contentMetadata_3files.xml").read
      path_index_service = Dor::WASCrawl::PathIndexerService.new(@druid,@collection_path,@path_working_directory,contentMetadata)
      path_index_service.instance_variable_set(:@main_path_index_file,"#{@stacks_path}/data/indecies/path/path-index.txt")

      path_index_service.merge
      
      expected_merged_file_path = "#{@path_files}/merged_path_index.txt"
      actual_merged_file_path = "#{@path_working_directory}/merged_path_index.txt"
      expect(File.exist?(actual_merged_file_path)).to eq(true)
 
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(actual_merged_file_path))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read(expected_merged_file_path))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    

    end
    
    after(:all) do
      FileUtils.rm_rf("#{@path_working_directory}/.")
    end
  end
  
  context ".sort" do
    
    before(:all) do
    end
  
    it "should sort and remove duplicate frm the merged path index" do
      FileUtils.cp("#{@path_files}/merged_path_index.txt","#{@path_working_directory}/merged_path_index.txt")

      path_index_service = Dor::WASCrawl::PathIndexerService.new(@druid,@collection_path,@path_working_directory,"")
      path_index_service.sort
      
      expected_duplicate_path_index = "#{@path_files}/duplicate_path_index.txt"
      actual_duplicate_path_index = "#{@path_working_directory}/duplicate_path_index.txt"
      expect(File.exist?(actual_duplicate_path_index)).to eq(true)
 
      actual_MD5 = Digest::MD5.hexdigest(File.read(actual_duplicate_path_index))    
      expected_MD5 = Digest::MD5.hexdigest(File.read(expected_duplicate_path_index))
      expect(actual_MD5).to eq(expected_MD5)

      expected_path_index = "#{@path_files}/path_index.txt"
      actual_path_index = "#{@path_working_directory}/path_index.txt"
      expect(File.exist?(actual_path_index)).to eq(true)
 
      actual_MD5 = Digest::MD5.hexdigest(File.read(actual_path_index))    
      expected_MD5 = Digest::MD5.hexdigest(File.read(expected_path_index))
      expect(actual_MD5).to eq(expected_MD5)
    end
    
    after(:all) do
      FileUtils.rm_rf("#{@path_working_directory}/.")
    end
  end
  
  context ".publish" do
    
    before(:all) do
      
    end
  
    it "should" do
      FileUtils.cp("#{@path_files}/path_index.txt","#{@path_working_directory}/path_index.txt")

      path_index_service = Dor::WASCrawl::PathIndexerService.new(@druid,@collection_path,@path_working_directory,"")
      path_index_service.instance_variable_set(:@main_path_index_file,"#{@stacks_path}/data/indecies/path/test_path-index.txt")

      path_index_service.publish

      actual_path_index = "#{@stacks_path}/data/indecies/path/test_path-index.txt"
      expect(File.exist?(actual_path_index)).to eq(true)
 


    end
    
    after(:all) do
      FileUtils.rm("#{@stacks_path}/data/indecies/path/test_path-index.txt")
    end
  end
  
  context ".clean" do
    
    before(:all) do
    end
  
    it "should" do
    end
    
    after(:all) do
    end
  end
  
  after(:all) do
  end
end