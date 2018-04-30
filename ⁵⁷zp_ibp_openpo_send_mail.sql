SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO

--CREATE PROCEDURE [dbo].[zp_ibp_openpo_build_data]        

--AS                
            
SET ANSI_NULLS ON            
SET QUOTED_IDENTIFIER ON            
SET ANSI_WARNINGS ON            
SET ANSI_PADDING ON            
SET CONCAT_NULL_YIELDS_NULL ON            
SET NOCOUNT ON    
        
/*                
create by   : micky_wu
create date : 2017/10/6                
create goal : For IBP OpenPO Use 
*/         


--BEGIN TRAN
--ROLLBACK
--COMMIT


  DECLARE @XML_INPUT XML, @XML_OUTPUT XML  
--(BEG)---(REC) -----------------------------------------------------------------------------------------------------------------------------------------------  
--(10)---  ServerBroker ( Don't Move or Change it ) -----------------------------------------------------------------------------------------------------------  
  DECLARE @xml_request XML, @xml_result XML, @xmldoc INT, @global_id VARCHAR(100), @DOC_OUTPUT NVARCHAR(MAX)  
   EXEC SourceDB.dbo.zp_GlobalSB_Get_MSG 'REC', @XML_INPUT OUTPUT, @xmldoc OUTPUT, @global_id OUTPUT  
  
/*  
  SELECT @XML_INPUT = '<sb_request_context>      
                          <inputstring>      
                           <id_scvo_item_master>1</id_scvo_item_master>      
                           --<mail_subject>SCVO Ship Plan</mail_subject>      
                           --<cust_no_mail>USA0191</cust_no_mail>    
			               --<dt_generate>2013-05-10 17:12:51</dt_generate>  
                           --<dt_openpo>20130510</dt_openpo>  
                         --<rowset>      
                           --<ship_plan_list>      
                             --<ship_plan>      
                             --  <SUPPLIER>XXX</SUPPLIER>      
                             --         ......      
                             --</ship_plan>      
                             --<ship_plan>      
                             --  <SUPPLIER>XXX</SUPPLIER>      
                             --         ......      
                             --</ship_plan>      
                           --</ship_plan_list>      
                         --</rowset>      
                         </inputstring>      
                       </sb_request_context>'  
*/  
  
  DECLARE @id_scvo_item_master int      
   SELECT @id_scvo_item_master = ( SELECT @XML_INPUT.value('(/sb_request_context/inputstring/id_scvo_item_master)[1]', 'int') )  

  DECLARE @cust_no_mail Varchar(60)           
   SELECT @cust_no_mail = ( SELECT @XML_INPUT.value('(/sb_request_context/inputstring/cust_no_mail)[1]', 'varchar(60)') )      
      
/*       
    EXEC sp_xml_preparedocument @xmldoc output, @XML_INPUT                                 
     IF object_id('tempdb.dbo.#tmp_inputstring') is not null DROP TABLE #tmp_inputstring                              
   CREATE TABLE #tmp_inputstring
                (filename VARCHAR(255) 
	            ,msg_type VARCHAR(30))            
              
   INSERT #tmp_inputstring                      
   SELECT *               
     FROM openxml(@xmldoc, '/sb_request_context/inputstring', 3) with #tmp_inputstring                      
 --SELECT * FROM #tmp_inputstring                      
    EXEC sp_xml_removedocument @xmldoc             
--*/      
  
--SELECT 'Table' = '#tmp_inputstring', * FROM #tmp_inputstring  
--SELECT 'Table' = '#tmp_ship_plan_list', * FROM #tmp_ship_plan_list  
  
--[ * ]----------------------------------------------------------------------------------------------------------------------
--  *.SP Name Rule : zp_processing_xxxx  ( if this sp is Processing  
-----------------------------------------------------------------------------------------------------------------------------
  
--[ 0.REQUEST RECORD  ]------------------------------------------------------------------------------------------------------
--  
-----------------------------------------------------------------------------------------------------------------------------
  
--[ 1.UPDATE SEQUENCE ]------------------------------------------------------------------------------------------------------
--  
-----------------------------------------------------------------------------------------------------------------------------
  
SET NOCOUNT ON  
  
  DECLARE @ERROR_PROC VARCHAR(100), @PROCLEVEL INT, @ERROR_SEVERITY INT, @RTN_STATUS INT, @PROCNAME VARCHAR(100), @ERROR_MSG VARCHAR(2000)  
  
   SELECT  @PROCLEVEL      = @@NESTLEVEL  
   SELECT  @PROCNAME       = isnull( OBJECT_NAME(@@PROCID), '' )  
   SELECT  @ERROR_PROC     = ''  
   SELECT  @ERROR_MSG      = ''  
   SELECT  @ERROR_SEVERITY = 0  
   SELECT  @RTN_STATUS     = 0  
   SELECT  @XML_OUTPUT     = '<rowset/><rtnparameter/>'  
  
SET XACT_ABORT ON  
  
    BEGIN TRY  
  
    BEGIN TRANSACTION  
  
-----------------------------------------------------------------------------------------------------------------------------
--[ 2.Data Collect    ]------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
--<2.Data Collect Area>  
  
  DECLARE @wf_msg NVARCHAR(MAX)      --> Work Flow Use  
         ,@inputstring NVARCHAR(MAX) --> Work Flow Use  
         ,@id_scvo_ship_plan_master Int  
         ,@ship_plan_no Varchar(60)  
         ,@mail_subject NVarchar(MAX)  
         ,@id_oecust_br Int  
         ,@mail_to NVarchar(MAX)  
         ,@subject NVarchar(MAX)  
         ,@column_name NVarchar(MAX)  
         ,@excel_column_name NVarchar(MAX)  
         ,@body NVarchar(MAX)  
         ,@mail_body NVarchar(MAX)  
         ,@rowset NVarchar(MAX)  
         ,@rtnparameter NVarchar(MAX)  
  
-- Get @wf_msg --> Work Flow Use  
   SELECT @wf_msg = CAST(T.c.query('.') AS NVARCHAR(MAX))  
     FROM @XML_INPUT.nodes('/sb_request_context/wf') T(c)  
  
     IF isnull(@wf_msg, '') <> ''  
        BEGIN  
              SELECT @inputstring = CAST(T.c.query('.') AS NVARCHAR(MAX))  
                FROM @XML_INPUT.nodes('/sb_request_context/inputstring') T(c)  
  
        SELECT @inputstring = isnull(@inputstring, '<inputstring></inputstring>')  
        
		 END  
  

  

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
    
--[Start]Get information for Mail   
--/Get  Mail Recipients from FS019       
  DECLARE @now_quarter int
         ,@scvo_quarter int
		 ,@scvo_dt_valid_from varchar(10)
		 ,@scvo_dt_valid_to varchar(10)
		 ,@book_name varchar(30)
		 ,@status_release varchar(20)

  DECLARE @content varchar(max)
  DECLARE @ENTER Varchar(20)   
   SELECT @ENTER = CHAR(13) + CHAR(10)  			
			
  DECLARE @email_body varchar(max)              
  DECLARE @email_recipients varchar(max)
	
   SELECT @book_name=item_book_name
	 FROM scvo_item_master with(nolock)
	WHERE id_scvo_item_master = @id_scvo_item_master
	
	
/*			                    
   SELECT @email_recipients=isnull(@email_recipients,'')+detail.e_mail+';'           
 --SELECT detail.e_mail,*            
	 FROM partner_contact master with(nolock)                  
	     ,partner_contact detail with(nolock)                  
	WHERE     
	    --master.ref_from = 'b2b_contacter'                  
    --AND master.contact_name = '#IUID_duplicate_version'
	  AND master.id_partner_contact=detail.ref_id                  
	  AND master.stat_void = 0                  
	  AND detail.stat_void = 0      
	  AND master.contact_name = '#SCVO_Item Master'         
			                
   SELECT @email_recipients = RTRIM(LTRIM(SUBSTRING(@email_recipients, 1, (LEN(@email_recipients) - 1))))                
 --SELECT @email_recipients_next--for test  
*/
			
   SELECT @id_oecust_br=id_oecust_br
     FROM oecust_br a with(nolock)
         ,admcomp b with(nolock)
    WHERE a.stat_void = 0
      AND a.cust_no = @cust_no_mail--'USA0191' 
	  AND a.id_admcomp= b.id_admcomp
	  AND b.stat_active = 1
	  AND b.stat_void = 0
	  AND b.stat_isheadquarter = 1
			
    EXEC zp_Gedi_notice_mail @id_oecust_br, '#IBP_OPENPO', 0, @mail_to OUTPUT
				  
--[End]Get information for Mail            
			
   SELECT @content = 'Dear All :IBP Open PO Data Upload Success !! ' 
   SELECT @email_body = @content

/*
	EXEC msdb.dbo.sp_send_dbmail                              
		 @profile_name                = 'SMTPMail'  
		,@recipients                  = @mail_to--@email_recipients                      
		,@copy_recipients             = ''                            
		,@blind_copy_recipients       = ''--Mail bcc                              
		,@body                        = @email_body                            
		,@attach_query_result_as_file = 0                              
		,@subject                     = 'IBP In Transit Data Upload Success!!'--@email_subject
		
   SELECT @email_body_next               
*/

      
	EXEC gateway.dbo.zp_notice_gateway   @method	= 1                                            
										,@name		= @PROCNAME
										,@type		= 'ERP'                                        
										,@subject	= 'IBP Open PO Data Upload Success!!'--@mail_subject
										,@to_User	= @mail_to --'micky_wu@accton.com'--                                   
										,@cc_User	= ''  --@mail_cc
										,@bcc_User	= ''                                  
										,@descrip	= @email_body   
										,@error_user = 'micky_wu@accton.com'
									    ,@class_name = 'IBP_OPENPO'  
								      --,@class_name = 'IBP_In_Transit' 
								       


-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
  
 --SELECT @rowset = '<notice_mail>' + CAST(@mail_body as NVarchar(max)) + '</notice_mail>'  
  
 --SELECT '@rowset' = @rowset, '@rowset' = CAST(@rowset AS XML)  
  
   SELECT @rtnparameter = '<mail_to>' + isnull(@email_recipients, '') + '</mail_to>'  
  
   SELECT @XML_OUTPUT = CAST('<rowset></rowset>'
                      + '<rtnparameter>'
					       + isnull(@rtnparameter, '') 
					  + '</rtnparameter>' AS XML)  
  
 --SELECT '@XML_OUTPUT' = @XML_OUTPUT  
  
     IF @XML_OUTPUT is null  
        BEGIN  
              RAISERROR('5.3 - Error, "XML_OUTPUT" is empty !!', 16, 101)  
         END  
  
        SELECT @ERROR_MSG = 'Send Notice Mail -- Success !!!'  
  
/*  
   SELECT 'Table' = 'scvo_ship_plan_master', *  
     FROM scvo_ship_plan_master with(nolock)  
    WHERE id_scvo_ship_plan_master = @id_scvo_ship_plan_master  
    ORDER BY id_scvo_ship_plan_master  
*/  
  
--- 1.DataBase Error ( Object Error )  
  
--- 2.User Error ( Business Error )  
  
--</5.Data Transaction Area>  
-----------------------------------------------------------------------------------------------------------------------------
    TransEnd:  
  
  COMMIT TRANSACTION  
  
END TRY  
  
BEGIN CATCH  
  
   SELECT @ERROR_SEVERITY = ERROR_SEVERITY()  
   SELECT @ERROR_PROC     = ERROR_PROCEDURE()  
  
     IF ERROR_STATE() >= 101 and ERROR_STATE() <= 200  
        SELECT @RTN_STATUS = ERROR_STATE()  
    ELSE  
        SELECT @RTN_STATUS = 201  
  
   SELECT @ERROR_MSG = '[PROC]:[' + LTRIM(STR(@PROCLEVEL)) + ']' + @PROCNAME + '[LINE]:' + CONVERT(VARCHAR(MAX),ERROR_LINE()) + ', ' + ERROR_MESSAGE()  
  
     IF (XACT_STATE()) = -1  
        BEGIN  
              ROLLBACK TRANSACTION  
         END  
  
    GOTO Exception  
  
END CATCH  
  
ProcEnd:  
  
   SELECT @XML_OUTPUT = CAST ( '<outputstring>'  
                               +    isnull(CAST ( @XML_OUTPUT AS NVARCHAR(MAX) ), '<rowset/><rtnparameter/>')  
                               +    '<rtncode>'  
                               +       '<code>' + LTRIM(str(@RTN_STATUS)) + '</code>'  
                               +       '<msg>'  + isnull(@ERROR_MSG,'') + '</msg>'  
                               +    '</rtncode>'  
                               +    isnull(@wf_msg, '') --> Work Flow Use  
                               +    isnull(@inputstring, '') --> Work Flow Use  
                               +'</outputstring>' AS XML )  
  
    EXEC SourceDB.dbo.zp_GlobalSB_Set_MSG @XML_OUTPUT  
  
 --SELECT '@XML_OUTPUT' = @XML_OUTPUT  
  
 RETURN --@RTN_STATUS  
  
Exception:  
  
    SELECT @XML_OUTPUT = CAST ( '<outputstring>'  
                               +    isnull(CAST ( @XML_OUTPUT AS NVARCHAR(MAX) ), '<rowset/><rtnparameter/>')  
                               +    '<rtncode>'  
                               +       '<code>' + LTRIM(str(@RTN_STATUS)) + '</code>'  
                               +       '<msg>'  + isnull(@ERROR_MSG,'') + '</msg>'  
                               +    '</rtncode>'  
                               +    isnull(@wf_msg, '') --> Work Flow Use  
                               +    isnull(@inputstring, '') --> Work Flow Use  
                               +'</outputstring>' AS XML )  
  
    EXEC SourceDB.dbo.zp_GlobalSB_Set_MSG @XML_OUTPUT  
  
 --SELECT '@XML_OUTPUT' = @XML_OUTPUT  
  
   SELECT @DOC_OUTPUT = CAST( @XML_OUTPUT AS NVARCHAR(MAX) )  
  
RAISERROR ('<ERROR>PROC:[%d]%s CODE:%d</ERROR>%s)', @ERROR_SEVERITY, @RTN_STATUS, @PROCLEVEL, @PROCNAME, @RTN_STATUS, @DOC_OUTPUT)  

