
module Robots
  module DorRepo
    module WasCrawlDissemination
      class PathIndexer
        include LyberCore::Robot

        def initialize
          super('dor', 'wasCrawlDisseminationWF', 'path-indexer')
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid_obj = Dor::Item.find(druid)          
          collection_id = Dor::WASCrawl::Dissemination::Utilities.get_collection_id(druid_obj)
          collection_path = Dor::Config.was_crawl_dissemination.stacks_collections_path + collection_id
          contentMetadata = druid_obj.datastreams['contentMetadata']
          path_working_directory = Dor::Config.was_crawl_dissemination.path_working_directory

          path_indexer_service = Dor::WASCrawl::PathIndexerService.new(druid,collection_path,path_working_directory,contentMetadata.content)
          path_indexer_service.merge
          path_indexer_service.sort
          path_indexer_service.publish
          path_indexer_service.clean
        end
      end

    end
  end
end