Dor::Config.configure do

  workflow.url 'https://lyberservices-dev.stanford.edu/workflow/'

  robots do 
    workspace '/tmp'
  end
  
  was_crawl_dissemination do
    
    java_heap_size  '-Xmx1024m'
    cdx_working_directory "/web-archiving-stacks/data/indecies/cdx_working/"
    cdx_backup_directory  "/web-archiving-stacks/data/indecies/cdx_backup/"
    main_cdx_file "/web-archiving-stacks/data/indecies/cdx/index.cdx"

    path_working_directory "/web-archiving-stacks/data/indecies/path_working/"
    main_path_index_file "/web-archiving-stacks/data/indecies/path/path-index.txt"

    webarchives_commons_jar "jar/webarchive-commons-jar-with-dependencies.jar"
    stacks_collections_path "/web-archiving-stacks/data/collections/"
    
  end


  dor do
    service_root 'https://USERNAME:PASSWORD@lyberservices-dev.stanford.edu/dor'
  end
   
end

REDIS_URL = "sul-lyberservices-dev.stanford.edu:6379/resque:development"