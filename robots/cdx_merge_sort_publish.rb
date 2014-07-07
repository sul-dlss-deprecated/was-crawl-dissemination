
module Robots
  module DorRepo
    module WasCrawlDissemination
      class CdxMergeSortPublish
        include LyberCore::Robot

        def initialize
          super('dor', 'wasCrawlDisseminationWF', 'cdx-merge-sort-publish')
        end

        def perform(druid)
#          druid_obj = Dor::Item.find(druid)
          
          cdx_working_directory = Dor::Config.was_crawl_dissemination.cdx_working_directory 
          cdx_backup_directory = Dor::Config.was_crawl_dissemination.cdx_backup_directory 
          
          cdx_merge_sort_publish = Dor::WASCrawl::CDXMergeSortPublishService.new( druid, cdx_working_directory, cdx_backup_directory)
          cdx_merge_sort_publish.merge
          cdx_merge_sort_publish.sort
          cdx_merge_sort_publish.publish
          cdx_merge_sort_publish.clean
        end
      end

    end
  end
end