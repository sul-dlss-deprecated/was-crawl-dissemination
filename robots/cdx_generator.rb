
module Robots
  module DorRepo
    module WasCrawlDissemination
      class CdxGenerator
        include LyberCore::Robot

        def initialize
          super('dor', 'wasCrawlDisseminationWF', 'cdx-generator')
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
          
          cdx_generator = Dor::WASCrawl::CDXGeneratorService.new(collection_path,druid,contentMetadata.content)
          cdx_generator.generate_cdx_for_crawl
        end
      end

    end
  end
end