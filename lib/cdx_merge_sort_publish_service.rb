
module Dor
  module WASCrawl
    class CDXMergeSortPublishService
      
      def initialize( druid_id, cdx_working_directory, cdx_backup_directory)
        @main_cdx_file = Dor::Config.was_crawl_dissemination.main_cdx_file
        @source_cdx_dir = "#{cdx_working_directory}/#{druid_id}/"
        @working_merged_cdx = "#{cdx_working_directory}/#{druid_id}_merged_index.cdx"
        @working_sorted_duplicate_cdx = "#{cdx_working_directory}/#{druid_id}_sorted_duplicate_index.cdx"
        @working_sorted_cdx = "#{cdx_working_directory}/#{druid_id}_sorted_index.cdx"
        @cdx_backup_directory = cdx_backup_directory
      end
      
      def merge
        #merge files from working_directory/druid_id/*.cdx with cdx/index.cdx 
        # to working_directory/unsorted_cdx/
        merge_cmd_string = "cat #{@main_cdx_file} #{@source_cdx_dir}*.cdx > #{@working_merged_cdx}"
        Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd(merge_cmd_string, "merging the CDX files")
      end
      
      def sort
        #read file from working_directory/unsorted_cdx/index.cdx
        #to working/directory/sorted_cdx/index.cdx
        sort_cmd_string = "LC_ALL=C sort #{@working_merged_cdx} > #{@working_sorted_duplicate_cdx}"
        Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd(sort_cmd_string, "sorting CDX files")
        uniq_cmd_string = "uniq #{@working_sorted_duplicate_cdx} > #{@working_sorted_cdx}"
        Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd(uniq_cmd_string, "removing duplicates from CDX file")
      end
      
      def publish
        FileUtils.mv( @working_sorted_cdx, @main_cdx_file)
      end
      
      def clean
        FileUtils.mv(@source_cdx_dir, @cdx_backup_directory)
        FileUtils.rm(@working_sorted_duplicate_cdx)
        FileUtils.rm(@working_merged_cdx)
      end
    end
  end
end