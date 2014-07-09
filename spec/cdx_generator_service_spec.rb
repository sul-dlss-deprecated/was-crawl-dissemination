require 'spec_helper'
require 'cdx_generator_service'

#  specify { expect(3).to eq(3) }
#  specify { expect(3).not_to eq(4) }
#  specify { expect { raise "boom" }.to raise_error("boom") }
#  specify { expect { }.not_to raise_error }

describe Dor::WASCrawl::CDXGeneratorService do

  before(:all) do
    @stacks_path = Pathname(File.dirname(__FILE__)).join("../fixtures/stacks")
    @workspace = Pathname(File.dirname(__FILE__)).join("../fixtures/workspace")
    @collection_id = "test_collection"
    @crawl_id = "test_crawl"
  end
  
  context ".generate_cdx_for_crawl" do
    before(:all) do
      @druid_id_1 = "dd111dd1111"
      @druid_id_2 = "dd111dd1111"
      @druid_id_3 = "ee111ee1111"
      @content_metadata_xml_location = "fixtures/metadata/"
      @collection_path = "#{@stacks_path}/data/collections/test_collection"
    end

    it "should generate cdx file for each warc or arc file in contentMetadata" do
      
      contentMetadata = File.open(@content_metadata_xml_location+"contentMetadata_3files.xml").read
      collection_path = "#{@stacks_path}/data/collections/test_collection"
      cdx_generator = Dor::WASCrawl::CDXGeneratorService.new(@collection_path,@druid_id_1,contentMetadata)
      
      cdx_generator.instance_variable_set(:@cdx_working_directory,"#{@stacks_path}/data/indecies/cdx_working")
      cdx_generator.generate_cdx_for_crawl
      
      cdx_file_path_1 = "#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_1}/WARC-Test.cdx"
      cdx_file_path_2 = "#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_1}/ARC-Test.cdx"
      
      expect(File.exist?(cdx_file_path_1)).to eq(true)
      expect(File.exist?(cdx_file_path_2)).to eq(true)
      
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(cdx_file_path_1))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read("fixtures/cdx_files/WARC-Test.cdx"))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    
      
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(cdx_file_path_2))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read("fixtures/cdx_files/ARC-Test.cdx"))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    
      
    end

    it "should generate cdx file for each warc or arc file in contentMetadata even if there are some file already created" do
      
      #Make sure the test case is correctly setup
      cdx_file_path_1 = "#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_2}/WARC-Test.cdx"
      expect(File.exist?(cdx_file_path_1)).to eq(true)
      
      contentMetadata = File.open(@content_metadata_xml_location+"contentMetadata_3files.xml").read
      cdx_generator = Dor::WASCrawl::CDXGeneratorService.new(@collection_path,@druid_id_2,contentMetadata)
      
      cdx_generator.instance_variable_set(:@cdx_working_directory,"#{@stacks_path}/data/indecies/cdx_working")
      cdx_generator.generate_cdx_for_crawl

      cdx_file_path_1 = "#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_2}/WARC-Test.cdx"
      cdx_file_path_2 = "#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_2}/ARC-Test.cdx"
      
      expect(File.exist?(cdx_file_path_1)).to eq(true)
      expect(File.exist?(cdx_file_path_2)).to eq(true)
      
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(cdx_file_path_1))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read("fixtures/cdx_files/WARC-Test.cdx"))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    
      
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(cdx_file_path_2))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read("fixtures/cdx_files/ARC-Test.cdx"))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    
      
    end
    
    it "should do nothing for the contentMetadata without any arcs or warcs" do
      contentMetadata = File.open(@content_metadata_xml_location+"contentMetadata_0file.xml").read
      cdx_generator = Dor::WASCrawl::CDXGeneratorService.new(@collection_path,@druid_id_3,contentMetadata)
      cdx_generator.instance_variable_set(:@cdx_working_directory,"#{@stacks_path}/data/indecies/cdx_working")
      cdx_generator.generate_cdx_for_crawl
      
      cdx_dir = "#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_3}/"
      
      expect(File.exist?(cdx_dir)).to eq(true)
      expect(Dir.glob('#{cdx_dir}{*,.*}').empty? ).to eq(true)
    end
    after(:all) do
      FileUtils.rm_rf("#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_1}/")
      FileUtils.rm_rf("#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_3}/")
      FileUtils.rm_rf("#{@stacks_path}/data/indecies/cdx_working/#{@druid_id_2}/ARC-Test.cdx")
    end
  end

  context ".generate_cdx_for_one_warc" do
    before(:all) do
      @cdx_generator = Dor::WASCrawl::CDXGeneratorService.new("","","")
    end

    it "should generate CDX file for the input warc file" do
      cdx_file_path = "tmp/WARC-Test.cdx"
      warc_file_path = "#{@workspace}/aa111aa1111/WARC-Test.warc.gz"
      @cdx_generator.generate_cdx_for_one_warc(warc_file_path,cdx_file_path )
      
      expect(File.exist?(cdx_file_path)).to eq(true)
      
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(cdx_file_path))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read("fixtures/cdx_files/WARC-Test.cdx"))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    

    end
    
    after(:all) do
      FileUtils.rm "tmp/WARC-Test.cdx"
    end
  end

  context ".get_cdx_file_name" do
    before(:all) do
      @cdx_generator = Dor::WASCrawl::CDXGeneratorService.new("","","")
    end

    it "should return the cdx file for .warc.gz" do
      warc_file_name  = "file.warc.gz"
      cdx_file_name = @cdx_generator.get_cdx_file_name(warc_file_name)
      expect(cdx_file_name).to eq("file.cdx") 
    end
    
    it "should return the cdx file for .arc.gz" do
      warc_file_name  = "file.arc.gz"
      cdx_file_name = @cdx_generator.get_cdx_file_name(warc_file_name)
      expect(cdx_file_name).to eq("file.cdx") 
    end
    
    it "should return the cdx file for .warc" do
      warc_file_name  = "file.warc"
      cdx_file_name = @cdx_generator.get_cdx_file_name(warc_file_name)
      expect(cdx_file_name).to eq("file.cdx") 
    end
    
    it "should return the cdx file for .arc" do
      warc_file_name  = "file.arc"
      cdx_file_name = @cdx_generator.get_cdx_file_name(warc_file_name)
      expect(cdx_file_name).to eq("file.cdx") 
    end
    
    it "should return the cdx file for irregular file extension" do
      warc_file_name  = "file.txt"
      cdx_file_name = @cdx_generator.get_cdx_file_name(warc_file_name)
      expect(cdx_file_name).to eq("file.txt.cdx") 
    end
    
    it "should return the cdx file without the directory path" do
      expect(@cdx_generator.get_cdx_file_name("tmp/file.txt")).to eq("file.txt.cdx") 
      expect(@cdx_generator.get_cdx_file_name("./file.txt")).to eq("file.txt.cdx") 
      expect(@cdx_generator.get_cdx_file_name("../file.txt")).to eq("file.txt.cdx") 
      expect(@cdx_generator.get_cdx_file_name("/tmp/file.txt")).to eq("file.txt.cdx") 
      expect(@cdx_generator.get_cdx_file_name("c://tmp/file.txt")).to eq("file.txt.cdx") 
      expect(@cdx_generator.get_cdx_file_name("file://tmp/file.txt")).to eq("file.txt.cdx") 
   end

    
    after(:all) do
    end
  end

  context ".prepare_cdx_generation_cmd_string" do
    before(:all) do
      @cdx_generator = Dor::WASCrawl::CDXGeneratorService.new("","","")
    end

    it "should returns the command string as expected" do
      warc_file_name = "file.warc" 
      cdx_file_name = "file.cdx"
      @cdx_generator.instance_variable_set(:@cdx_working_directory,"working_directory/")
      cmd_string = @cdx_generator.prepare_cdx_generation_cmd_string(warc_file_name, cdx_file_name)
      expect(cmd_string).to eq("java -Xmx1024m -cp jar/webarchive-commons-jar-with-dependencies.jar  org.archive.extract.ResourceExtractor -cdxURL  file.warc > file.cdx 2>> log/jar_webarchive_commons.log")
    end

    it "should raise an error with nil or missing file names" do
      warc_file_name = nil 
      cdx_file_name = "file.cdx"
      
      expect{@cdx_generator.prepare_cdx_generation_cmd_string(nil,  cdx_file_name)}.to raise_error 
      expect{@cdx_generator.prepare_cdx_generation_cmd_string("",   cdx_file_name)}.to raise_error 
      expect{@cdx_generator.prepare_cdx_generation_cmd_string(warc_file_name, nil)}.to raise_error 
      expect{@cdx_generator.prepare_cdx_generation_cmd_string(warc_file_name,  "")}.to raise_error 
    end
    
    after(:all) do
    end
  end

  context Dor::WASCrawl::Dissemination::Utilities, ".run_sys_cmd" do
    before(:all) do
    end

    it "should generate CDX file in the right location with valid WARC file" do
      warc_file_name = "#{@workspace}/aa111aa1111/WARC-Test.warc.gz"
      cdx_file_name = "tmp/WARC-Test.cdx"
      cmd_string = "java -Xmx1024m -cp jar/webarchive-commons-jar-with-dependencies.jar  org.archive.extract.ResourceExtractor -cdxURL  #{warc_file_name} > #{cdx_file_name} 2>> log/jar_webarchive_commons.log"
      Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd( cmd_string, "extracting CDX")

      expect(File.exist?(cdx_file_name)).to eq(true)
      
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(cdx_file_name))    
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read("fixtures/cdx_files/WARC-Test.cdx"))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)    
    end

    it "should raise an error with invalid input file" do
      warc_file_name = "{@workspace}/bb111bbb1111/WARC-Test.txt"
      cdx_file_name = "tmp/WARC-Test.cdx"
      cmd_string = "java -Xmx1024m -cp jar/webarchive-commons-jar-with-dependencies.jar  org.archive.extract.ResourceExtractor -cdxURL  #{warc_file_name} > #{cdx_file_name} 2>> log/java_jar.txt"
      expect{Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd(cmd_string,"extracting CDX")}.to raise_error
    end

    
    after(:all) do
    end
  end

end
