# Define Enums

<#
AWP_Upload_Report_Type 
    - General idea, every file in the folders extracted from WinDip will have a a single entry in the report CSV file. This enables a count comparison.
    - The enum below provides further information about the success or otherwise of the file processing / upload.
    - The only exception is the INFO_ONLY records which store additional info for HR, and are not included in the file count.

      ALREADY_UPLOADED              - Self-explanatory
      INFO_ONLY,                    - E.g. Deletion due in next three months
      UPLOADED,           
      DRY_RUN_UPLOADED,             - 7 or more years since Termination date, not uploaded
      PROCESSED_XML_FILE,
      INVALID_XML_FILE,
      NO_VALID_METADATA,            - Files inside the same folder as an Invalid Xml (Metadata) file, not uploaded
      ERROR                         - Other, unexpected error. Any unexpected error during upload needs investigating and most likely a re-run.
#>

Add-Type -TypeDefinition @"
   public enum AWP_Upload_Report_Type
   {
      ALREADY_UPLOADED,
      INFO_ONLY,
      UPLOADED,
      DRY_RUN_UPLOADED,
      IGNORED,
      PROCESSED_XML_FILE,
      INVALID_XML_FILE,
      NO_VALID_METADATA, 
      ERROR
   }
"@

Add-Type -TypeDefinition @"
   public enum AWP_Upload_Processing
   {
      DRY_RUN,
      LIVE_UPLOAD,
      FILE_COUNT
   }
"@

