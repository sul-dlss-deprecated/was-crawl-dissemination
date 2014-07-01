
module Dor
  module WASCrawl
    class CDXGeneratorService

      def initialize (collection_path, druid_id, contentMetadata)
        @contentMetadata = contentMetadata
        @druid_id = druid_id
        @collection_path = collection_path
       
        @cdx_generator_jar_file_name = Dor::Config.was_crawl_dissemination.webarchives_commons_jar
        @cdx_working_directory = Dor::Config.was_crawl_dissemination.cdx_working_directory
        @java_heap_size = Dor::Config.was_crawl_dissemination.java_heap_size
        @java_log_file = "log/jar_webarchive_commons.log"
      end
      
      def generate_cdx_for_crawl
        warc_file_list = Dor::WASCrawl::Dissemination::Utilities.get_warc_file_list_from_contentMetadata(@contentMetadata) 
        cdx_druid_dir= "#{@cdx_working_directory}/#{@druid_id}"
        FileUtils.makedirs cdx_druid_dir unless File.exists?(cdx_druid_dir)

        warc_file_list.each do |warc_file_name|
          
          cdx_file_name = get_cdx_file_name( warc_file_name )
          cdx_file_path= "#{cdx_druid_dir}/#{cdx_file_name}"
          warc_file_path = "#{@collection_path}/#{warc_file_name}"
         
          generate_cdx_for_one_warc(warc_file_path, cdx_file_path) 
        end
        
      end

      def get_cdx_file_name( warc_file_name )
        
        cdx_file_name = File.basename(warc_file_name)
        if cdx_file_name.end_with?"gz"
          cdx_file_name = cdx_file_name[0...-3]
        end     
        if cdx_file_name.end_with?".arc"
          cdx_file_name = cdx_file_name[0...-4]
        elsif cdx_file_name.end_with?".warc"
          cdx_file_name = cdx_file_name[0...-5]
        end
        
        return cdx_file_name+".cdx"
      end
      
      def generate_cdx_for_one_warc( warc_file_path,cdx_file_path )
        cmd_string = prepare_cdx_generation_cmd_string(warc_file_path,cdx_file_path)
        Dor::WASCrawl::Dissemination::Utilities.run_sys_cmd(cmd_string,"extracting CDX")
      end
      
      def prepare_cdx_generation_cmd_string(warc_file_path,cdx_file_path)
        raise "invalid warc file name" if warc_file_path.nil? or warc_file_path.length <1
        raise "invalid cdx file name" if cdx_file_path.nil? or cdx_file_path.length <1
        
        cmd_string = "java #{@java_heap_size} -cp #{@cdx_generator_jar_file_name}  org.archive.extract.ResourceExtractor -cdxURL  #{warc_file_path} > #{cdx_file_path} 2>> #{@java_log_file}"
        return cmd_string
      end

    end
  end
end

