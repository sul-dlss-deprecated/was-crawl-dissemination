require 'spec_helper'

describe Dor::WASCrawl::CDXMergeSortPublishService do
  before(:all) do
    @cdx_files = Pathname(File.dirname(__FILE__)).join('fixtures/cdx_files')
    @stacks_path = Pathname(File.dirname(__FILE__)).join('fixtures/stacks')

    @content_metadata_xml_location = Pathname(File.dirname(__FILE__)).join('fixtures/metadata/')
    @cdx_working_directory = "#{@stacks_path}/data/indecies/cdx_working"
    @cdx_backup_directory = "#{@stacks_path}/data/indecies/cdx_backup"
  end

  describe '.sort_druid_cdx' do
    it 'should merge and sort all cdx files within the druid directory' do
      druid_id = 'ff111ff1111'

      mergeSortPublishService = Dor::WASCrawl::CDXMergeSortPublishService.new(druid_id, @cdx_working_directory, '')
      mergeSortPublishService.sort_druid_cdx

      expected_merged_file_path = "#{@cdx_files}/#{druid_id}_merged_index.cdx"
      actual_merged_file_path = "#{@cdx_working_directory}/#{druid_id}_merged_index.cdx"
      expect(File.exist?(actual_merged_file_path)).to eq(true)

      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(actual_merged_file_path))
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read(expected_merged_file_path))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)
    end

    after(:all) do
      FileUtils.rm_rf("#{@stacks_path}/data/indecies/cdx_working/ff111ff1111_merged_index.cdx")
    end
  end

  describe '.merge_with_main_index' do
    it 'should sort and remove duplicate from the merged index' do
      druid_id = 'gg111gg1111'

      mergeSortPublishService = Dor::WASCrawl::CDXMergeSortPublishService.new(druid_id, @cdx_working_directory, '')
      mergeSortPublishService.instance_variable_set(:@main_cdx_file, "#{@stacks_path}/data/indecies/cdx/index.cdx")
      mergeSortPublishService.merge_with_main_index

      expected_sorted = "#{@cdx_files}/#{druid_id}_sorted_index.cdx"
      actual_sorted = "#{@cdx_working_directory}/#{druid_id}_sorted_index.cdx"
      expect(File.exist?(actual_sorted)).to eq(true)
      actual_cdx_MD5 = Digest::MD5.hexdigest(File.read(actual_sorted))
      expected_cdx_MD5 = Digest::MD5.hexdigest(File.read(expected_sorted))
      expect(actual_cdx_MD5).to eq(expected_cdx_MD5)
    end

    after(:all) do
      FileUtils.rm_rf("#{@stacks_path}/data/indecies/cdx_working/gg111gg1111_sorted_index.cdx")
      FileUtils.rm_rf("#{@stacks_path}/data/indecies/cdx_working/gg111gg1111_sorted_duplicate_index.cdx")
    end
  end

  context 'publish' do
    it 'should publish the cdx main index to indecies/cdx location' do
      druid_id = 'hh111hh1111'

      mergeSortPublishService = Dor::WASCrawl::CDXMergeSortPublishService.new(druid_id, @cdx_working_directory, '')
      mergeSortPublishService.instance_variable_set(:@main_cdx_file, "#{@stacks_path}/data/indecies/cdx/g_index.cdx")
      expect(File.exist?("#{@stacks_path}/data/indecies/cdx/g_index.cdx")).to eq(false)

      mergeSortPublishService.publish
      expect(File.exist?("#{@stacks_path}/data/indecies/cdx/g_index.cdx")).to eq(true)
    end

    after(:all) do
      FileUtils.mv("#{@stacks_path}/data/indecies/cdx/g_index.cdx", "#{@stacks_path}/data/indecies/cdx_working/hh111hh1111_sorted_index.cdx")
    end
  end

  describe '.clean' do
    it 'should clean all the working directory and move the files to backup' do
      druid_id = 'ii111ii1111'
      FileUtils.cp_r("#{@cdx_files}/ii/.", "#{@cdx_working_directory}")

      mergeSortPublishService = Dor::WASCrawl::CDXMergeSortPublishService.new(druid_id, @cdx_working_directory, @cdx_backup_directory)
      mergeSortPublishService.clean

      expect(File.exist?("#{@cdx_backup_directory}/ii111ii1111")).to eq(true)
      expect(File.exist?("#{@cdx_backup_directory}/ii111ii1111/file1.cdx")).to eq(true)
      expect(File.exist?("#{@cdx_backup_directory}/ii111ii1111/file2.cdx")).to eq(true)
      expect(File.exist?("#{@cdx_backup_directory}/ii111ii1111_merged_index.cdx")).to eq(false)
      expect(File.exist?("#{@cdx_backup_directory}/ii111ii1111_sorted_duplicate_index.cdx")).to eq(false)
    end

    after(:all) do
      FileUtils.rm_rf("#{@cdx_backup_directory}/.")
    end
  end
end
