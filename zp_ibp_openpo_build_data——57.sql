
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

ALTER PROCEDURE [dbo].[zp_ibp_openpo_build_data] AS                
            
SET ANSI_NULLS ON            
SET QUOTED_IDENTIFIER ON            
SET ANSI_WARNINGS ON            
SET ANSI_PADDING ON            
SET CONCAT_NULL_YIELDS_NULL ON            
SET NOCOUNT ON    
        
/*                
create by   : micky_wu
create date : 2017/09/29                
create goal : For IBP OpenPO Use 
*/         


--BEGIN TRAN
--ROLLBACK
--COMMIT             
               

  DECLARE @XML_INPUT xml ,@XML_OUTPUT xml ,@DOC_OUTPUT nvarchar(MAX), @XML_MSG xml
--(BEG)---(REC) ------------------------------------------------------------------------------------------------------
--(10)--- ServerBroker ( Don't Move or Change it ) ------------------------------------------------------------------------------------------------------
  DECLARE @xml_request xml ,@xml_result xml ,@xmldoc int , @global_id varchar(100)
     EXEC SourceDB.dbo.zp_GlobalSB_Get_MSG 'REC', @XML_INPUT OUTPUT, @xmldoc OUTPUT, @global_id OUTPUT


/*
SELECT @XML_INPUT = '<sb_request_context>
                        <inputstring>
                           <filename>20171002_103912_ACCTON_OPENPO.xml</filename>
							<msg_type>IBP_OPENPO</msg_type>
                        </inputstring>
                      </sb_request_context>'
*/
 

--[20]--- Extract Data FROM Request ------------------------------------------------------------------------------------------------------
   SELECT @xml_request = CAST( dbo.fnReplTag( CAST( @xml_request AS nvarchar(MAX) ) ) AS xml )
--[20]--- Extract Data FROM Request ------------------------------------------------------------------------------------------------------
  DECLARE @loop_count int ,@loop_index int ,@stat_b2b_next TINYint ,@wf_msg nvarchar(MAX) 
         ,@actioncode varchar(10) ,@inputstring nvarchar(MAX)                
  DECLARE @table_list nvarchar(MAX) ,@para_list nvarchar(MAX)
  DECLARE @input_xml xml                
   SELECT @wf_msg = CAST(T.c.query('.') AS nvarchar(MAX))
     FROM @XML_INPUT.nodes('/sb_request_context/wf') T(c)
   SELECT @wf_msg = ISNULL(@wf_msg, '<wf></wf>')
   SELECT @inputstring = CAST(T.c.query('.') AS nvarchar(MAX))
     FROM @XML_INPUT.nodes('/sb_request_context/inputstring') T(c)
   SELECT @inputstring = ISNULL(@inputstring, '<inputstring></inputstring>')
   SELECT @table_list = ''
   SELECT @para_list = ''
   SELECT @stat_b2b_next = 1
   SELECT @actioncode = 'A'
  
--DECLARE @check_point int
 --SELECT @check_point=0
------------------------------------------------------------------------------------------------------
 --SELECT top 100 * FROM workTemp.dbo.boolean_log with(nolock) WHERE code = 'zp_Gsn_get_sn' order by 1 desc                
 --INSERT workTemp.dbo.boolean_log( descrip ,xmldoc ,xmldoc1 ,code ) values ( '1 - THIS IS TESTING' ,@xml_request ,NULL ,@PROCNAME )                  
------------------------------------------------------------------------------------------------------
              
--DECLARE @id_admcomp int        
 --SELECT @id_admcomp = ( SELECT @XML_INPUT.value('(/sb_request_context/inputstring/id_admcomp)[1]', 'int') )        
        
       
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
       
   
--[ * ]-----------------------------------------------------------------------------------------------
--  *.SP Name Rule : zp_processing_xxxx  ( IF this sp is Processing
------------------------------------------------------------------------------------------------------

--[ 0.REQUEST RECORD  ]-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------


--[ 1.UPDATE SEQUENCE ]-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------


  DECLARE @ERROR_MSG  varchar(2000),@PROCNAME varchar(100), @ERROR_PROC varchar(1000) 
  DECLARE @PROCLEVEL int ,@ERROR_SEVERITY int,@RTN_STATUS int, @ROWSET nvarchar(MAX)

   SELECT @PROCLEVEL      = @@NESTLEVEL
   SELECT @PROCNAME       = ISNULL( OBJECT_NAME(@@PROCID) ,'' )
   SELECT @ERROR_PROC     = ''
   SELECT @ERROR_MSG      = ''
   SELECT @ERROR_SEVERITY = 0
   SELECT @RTN_STATUS     = 0
   SELECT @XML_OUTPUT     = '<rowset/><rtnparameter/>'
   SELECT @ROWSET         = '<rowset/>'                                
   SELECT @XML_MSG        = ''       

   BEGIN TRY                
        BEGIN TRANSACTION                           
  
------------------------------------------------------------------------------------------------------
--[ 2.Data Collect ]----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--<2.Data Collect Area>

  DECLARE @ENTER varchar(20)
         ,@pkey varchar(100)
         ,@id_msgQueue_inbound int
         ,@adm_table varchar(MAX)  --> Get Identity Value Use
         ,@adm_id varchar(MAX)     --> Get Identity Value Use
         ,@booking_id varchar(MAX) --> Get Identity Value Use
         ,@output varchar(MAX)     --> Get Identity Value Use
         ,@item int
         ,@item_MAX int
         ,@id_admslip int
         ,@dt_today datetime
         ,@count int
         ,@data xml
         ,@body nvarchar(MAX)     --> Work Flow Use
         ,@mail_to nvarchar(MAX)
         ,@subject nvarchar(MAX)
         ,@mail_filename nvarchar(MAX)
         ,@mail_subject nvarchar(MAX)
         ,@error_user varchar(1000)
         ,@rtnparameter nvarchar(MAX)
         ,@code varchar(100)
         ,@check_point int

  DECLARE @filename nvarchar(255) 
         ,@syntax varchar(8000) 
		 ,@folder nvarchar(255)
		 ,@output_xml xml
		 ,@outputfile varchar(MAX)
		 ,@msg_type nvarchar(30) 
		 ,@namespace nvarchar(255)
		 ,@xml_doc int
		 ,@header nvarchar(MAX)   --config
		 ,@tag_start nvarchar(MAX)
		 ,@tag_end nvarchar(MAX)

  DECLARE @accton_duns_no varchar(30)            
         ,@joy_code varchar(100)            
         ,@joy_DBDatabase varchar(50)            
         ,@joy_duns_no varchar(30)            
         ,@part_no varchar(MAX)   
         ,@document nvarchar(MAX)
         ,@sp_name varchar(255)            
         ,@doc nvarchar(MAX)            
         ,@joy_id_icim_comp varchar(MAX)            
         ,@joy_cust_no varchar(MAX)            
         ,@id_group varchar(MAX)            
         ,@period_range nvarchar(MAX)            
         ,@over_priority int            
         ,@over_column varchar(30)            
         ,@cnt_period int            
         ,@cnt int            
         ,@remark varchar(20)   


   SELECT @filename = filename
	     ,@msg_type = msg_type
	 FROM #tmp_inputstring

 --SELECT '@filename',@filename,'@msg_type',@msg_type

  
     IF object_id('tempdb.dbo.#master') is not null DROP TABLE #master  
   SELECT id_scvo_item_master,dt_release = MAX(dt_release)  
     intO #master  
     FROM scvo_item_master with(nolock)  
    WHERE stat_void = 0   
      AND status_release = 9  
    --AND DATEPART(quarter,dt_valid_FROM)=DATEPART(quarter,GETDATE()) -- Jill mark on 2013-06-28  
      AND CONVERT(varchar(10),GETDATE(),121) Between CONVERT(varchar(10),dt_valid_FROM,121)
	  AND CONVERT(varchar(10),dt_valid_to,121) -- Jill add on 2015-01-07
    GROUP BY id_scvo_item_master  

 --SELECT * FROM #master  

   
  DECLARE @day varchar(20) ,@str char(1),@batch_no varchar(12)  
  DECLARE @start int ,@long int   
 /*-----modIFy by ryan 20160317-----*/   
 --SELECT @day = CONVERT(nchar(16),dateadd(d,-1,GetDate()), 101)
   SELECT @day = replace(CONVERT(nchar,dateadd(d,-1,GetDate()), 101),'/','')
 /*-----modIFy by ryan 20160317-----*/      
   SELECT @long = LEN(@day)    
   SELECT @start = 0    
   SELECT @batch_no = '' ,@str = ''   
  
 --SELECT @day  
  
    WHILE (@start <= @long)    
    BEGIN    
          SELECT @str = SUBSTRING(@day,@start,1)     
            IF (@str like '[0-9]')    
               BEGIN    
                     SELECT @batch_no = @batch_no + @str    
                END    
          SELECT @start = @start + 1    
     END   
   
 --SELECT @batch_no
 /*-----modIFy by ryan 20160317-----*/  
 --SELECT @filename = 'OpenPOAccton_'+rtrim(ltrim(@batch_no))+'.txt'--modIFyby ryan 20160317
 --SELECT @filename = '656039310_JUNIPER_OpenPO_1.0_'+rtrim(ltrim(@batch_no))+'.xml' --mark by micky 20170915
 /*-----modIFy by ryan 20160317-----*/   

   SELECT @syntax = 'SELECT openpo_data_list FROM workTemp.dbo.ibp_openpo_snapshot ORDER BY row'  
  
   IF not exists (SELECT 1 FROM #master)  
       BEGIN    
           --SELECT @check_point=99                 
             SELECT @actioncode = 'N'--'C'    
             SELECT @ERROR_MSG  = 'The Program ['+@PROCNAME+'] Fail! The IBP Item data status is not confirmed !'                
               GOTO TransEnd  
           --SELECT 'N'              
        END      

/*   
   IF exists(SELECT top 1 *
               FROM scvo_openpo with(nolock)   
              WHERE CONVERT(varchar(10),dt_generate,121) = CONVERT(varchar(10),getdate(),121)
			      --CONVERT(varchar(10),dt_generate,121) = CONVERT(varchar(10),dateadd(d,0,getdate()),121)
                AND stat_void = 0
)  
       BEGIN  
             SELECT @actioncode = 'A'--'C'    
             SELECT @ERROR_MSG  = 'The Program ['+@PROCNAME+'] .IBP OpenPO Data has been created !! WorkFlow go to the Next Station !'    
               GOTO TransEnd  
        END  
  ELSE  
       BEGIN  
             SELECT @actioncode = 'N'--'C'    
             SELECT @ERROR_MSG  = 'The Program ['+@PROCNAME+'] .Auto Create IBP OpenPO snapshot Data with ''|'' -- Success !!! WorkFlow Process is canceled'    
        END  
*/
  
/*  
   SELECT *   
     FROM scvo_openpo with(nolock)  
    WHERE --CONVERT(varchar(10), dt_generate,121)  
          dt_openpo = CONVERT(varchar(10) ,getdate()) ,121)   
      AND stat_void = 0  
*/  

   
  DECLARE @id_scvo_item_master int  
   SELECT @id_scvo_item_master = id_scvo_item_master FROM #master  
  
  DECLARE @id_admcomp varchar(30)        
   SELECT @id_admcomp = id_admcomp         
     FROM admcomp (nolock)        
    WHERE stat_isheadquarter = 1        
      AND stat_void = 0         
  

   IF object_id ('tempdb.dbo.#tmp_icim_comp') IS NOT NULL DROP table #tmp_icim_comp            
   CREATE TABLE #tmp_icim_comp(
                 [id_scvo_item_detail] [int] NOT NULL
                ,[part_no] [varchar](20) NULL
                ,[part_type] [tinyint] NULL
                ,[goods_id] [tinyint] NULL
                ,[oem_unique] [varchar](15) NULL
                ,[juniper_part_no] [varchar](30) NULL
                ,[group_code] [char](2) NULL
                ,[PO_UNIT_COST] [decimal](14, 6) NULL
                ,[stat_exist_mt147] [tinyint] NULL
                ,[unique_parts] [char](2) NULL
                ,[stat_forecast] [tinyint] NULL
                ,[status_new] [tinyint] NULL
                ,[status_force_confirm] [tinyint] NULL
                ,[item_type] [varchar](250) NULL
                ,id_icim_comp int NULL
                ,unit_meas [varchar](3) NULL
                ,description [varchar](80) NULL
)

 --SELECT part_type,goods_id,oem_unique,unique_parts,* FROM #tmp_icim_comp            
   IF object_id ('tempdb.dbo.#tmp_partner_out_data') IS NOT NULL DROP TABLE #tmp_partner_out_data
   CREATE TABLE #tmp_partner_out_data(
                 item int                 Identity(1, 1)         
                ,GROUP_CODE               CHAR(20)
                ,SUPPLIER                 varchar(255)
                ,SUPPLIER_SITE            varchar(255)
                ,CM_PART_NUMBER           varchar(100)
                ,JUNIPER_PART_NUMBER      varchar(100)
                ,Item_Type                varchar(20)
                ,PO_NUMBER                varchar(255)
                ,PO_LINE_NUMBER           varchar(255)
                ,PO_SUPPLIER_NAME         varchar(255)
                ,PO_SUPPLIER_CONTACT_NAME varchar(255)
                ,MANUFACTURER_NAME        varchar(255)
                ,MANUFACTURE_PART_NUMBER  varchar(255)
                ,BUYER_CODE               varchar(255)
                ,BUYER_NAME               varchar(255)
                ,NCNR_FLAG                varchar(255)
                ,PURCHASING_LEAD_TIME     varchar(255)
                ,PO_TOTAL_QUANTITY        DECIMAL(14,2)
                ,PO_OPEN_QUANTITY         DECIMAL(14,2)
                ,PO_RECEIVED_QUANTITY     DECIMAL(14,2)
                ,UOM                      varchar(255)
                ,PO_UNIT_COST             DECIMAL(14,6)
                ,PO_PLACEMENT_DATE        varchar(10)
                ,REQUEST_DATE             varchar(10)
                ,COMMIT_DATE              varchar(10)
                ,AS_OF_DATE               varchar(26)
                ,description              varchar(255)
                ,STATUS_PO                int
				,STATUS_POPO              int
				,STATUS_POPOD             int
)
    --GET datetime 4/27/2010 18:20:00 GMT +8            
  DECLARE @DATE_GEN varchar(20),@DATE_GEN_STD varchar(26)            
   SELECT @DATE_GEN     = CONVERT(char(20),GETDATE(),120)            
 --SELECT @DATE_GEN             
   SELECT @DATE_GEN_STD = SUBSTRING(@DATE_GEN ,6,2) + '/' + SUBSTRING(@DATE_GEN ,9,2) + '/' + SUBSTRING(@DATE_GEN ,1,4)+ ' ' +  SUBSTRING(@DATE_GEN ,12,8) --+ ' GMT +8'               
 --SELECT @DATE_GEN_STD
 

  IF object_id ('tempdb.dbo.#tmp_MT_PurchaseOrder') is not null DROP TABLE #tmp_MT_PurchaseOrder
  CREATE TABLE #tmp_MT_PurchaseOrder(
                ITEM_NAME Character(250)
               ,ORGANIZATION_CODE Character(18)
               ,SR_INSTANCE_CODE Character(30)
               ,SUPPLIER_NAME Character(255)
               ,ORDER_TYPE int
               ,FIRM_PLANNED_TYPE Character(3)
               ,SUPPLIER_SITE_CODE Character(30)
               ,PURCH_LINE_NUM Character(50)
               ,ORDER_NUMBER Character(240)
               ,REVISION Character(10)
               ,NEW_ORDER_QUANTITY DECIMAL(14,2)
               ,BMT_FLAG Character(3)
               ,REQUESTED_SHIP_DATE Date
               ,PROMISED_SHIP_DATE Date
               ,CARRIER_NAME Character(80)
               ,MODE_OF_TRANSPORT Character(80)
               ,SERVICE_LEVEL Character(80)
               ,SHIP_METHOD Character(80)
               ,DROP_SHIP_DEST_TYPE int
               ,DROP_SHIP_CUST_NAME Character(255)
               ,DROP_SHIP_CUST_SITE_CODE Character(30)
               ,SCHEDULE_LINE_NUM Character(30)
               ,DELIVERY_PRICE int
               ,REQUESTED_DELIVERY_DATE Date
               ,PROMISED_DELIVERY_DATE Date
               ,SUBINVENTORY_CODE Character(10)
               ,DELETED_FLAG Character(3)
               ,CM_PART_NUMBER Character(250)
               ,NCNR_FLAG Character(3)
               ,PO_TOTAL_QUANTITY DECIMAL(14,2)
               ,PO_RECEIVED_QUANTITY DECIMAL(14,2)
               ,PO_UNIT_COST DECIMAL(14,6)
               ,GROUP_CODE  Character(8)
               ,FREE_ATTR1  Character(250)
               ,FREE_ATTR2  Character(250)
               ,FREE_ATTR3  Character(250)
               ,FREE_ATTR4  Character(250)
               ,FREE_ATTR5  Character(250)
               ,FREE_ATTR6  Character(250)
               ,FREE_ATTR7  Character(250)
               ,FREE_ATTR8  Character(250)
               ,FREE_ATTR9  Character(250)
               ,FREE_ATTR10 Character(250)
               ,FREE_ATTR11 Character(250)
               ,FREE_ATTR12 Character(250)
               ,FREE_ATTR13 Character(250)
               ,FREE_ATTR14 Character(250)
               ,FREE_ATTR15 Character(250)
               ,FREE_ATTR16 Character(250)
               ,FREE_ATTR17 Character(250)
               ,FREE_ATTR18 Character(250)
               ,FREE_ATTR19 Character(250)
               ,FREE_ATTR20 Character(250)
)

  
--</2.Data Collect Area>
------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------
--[ 3.Data Prepare (Only INSERT/Update #Temp Table ]--------------------------------------------------
------------------------------------------------------------------------------------------------------
--<3.Data Prepare Area>
                        

   INSERT intO #tmp_icim_comp(
                id_scvo_item_detail
               ,part_no
               ,part_type
               ,goods_id  
               ,oem_unique  
               ,juniper_part_no  
               ,group_code  
               ,PO_UNIT_COST  
               ,stat_exist_mt147  
               ,unique_parts  
               ,stat_forecast  
               ,status_new  
               ,status_force_confirm  
               ,item_type  
               ,id_icim_comp
               ,unit_meas              
               ,description
) 		  
   SELECT id_scvo_item_detail  = scvo_item_detail.id_scvo_item_detail  
         ,part_no              = scvo_item_detail.part_no  
         ,part_type            = scvo_item_detail.part_type  
         ,goods_id             = scvo_item_detail.goods_id  
         ,oem_unique           = scvo_item_detail.oem_unique  
         ,juniper_part_no      = scvo_item_detail.juniper_part_no  
         ,group_code           = scvo_item_detail.group_code  
         ,PO_UNIT_COST         = scvo_item_detail.cm_cost  
         ,stat_exist_mt147     = scvo_item_detail.stat_exist_mt147  
         ,unique_parts         = scvo_item_detail.unique_parts  
         ,stat_forecast        = scvo_item_detail.stat_forecast  
         ,status_new           = scvo_item_detail.status_new  
         ,status_force_confirm = scvo_item_detail.status_force_confirm  
         ,item_type            = scvo_item_detail.item_type  
         ,id_icim_comp         = icim_comp.id_icim_comp   
         ,unit_meas            = icim_comp.unit_meas  
         ,description          = icim_comp.descrip  
     FROM scvo_item_detail with(nolock)  
         ,#master scvo_item_master --scvo_item_master with(nolock)  
         ,icim_comp with(nolock)  
         ,admcomp with(nolock)  
    WHERE scvo_item_detail.id_scvo_item_master = scvo_item_master.id_scvo_item_master  
      AND scvo_item_detail.stat_void = 0  

      AND scvo_item_detail.part_no = icim_comp.part_no  
      AND icim_comp.id_admcomp = admcomp.id_admcomp  
      AND admcomp.stat_void = 0  
      AND admcomp.stat_isheadquarter = 1   
    --AND scvo_item_master.status_release = 9  
    --AND scvo_item_master.stat_void = 0  
    --AND @dt_start Between scvo_item_master.dt_valid_FROM AND scvo_item_master.dt_valid_to  
  
 --SELECT top 57 '#tmp_icim_comp',* FROM #tmp_icim_comp
                         
             
   INSERT intO #tmp_partner_out_data(
                GROUP_CODE
               ,SUPPLIER
               ,SUPPLIER_SITE
               ,CM_PART_NUMBER
               ,JUNIPER_PART_NUMBER
               ,Item_Type
               ,PO_NUMBER
               ,PO_LINE_NUMBER
               ,PO_SUPPLIER_NAME
               ,PO_SUPPLIER_CONTACT_NAME
               ,MANUFACTURER_NAME
               ,MANUFACTURE_PART_NUMBER
               ,BUYER_CODE
               ,BUYER_NAME
               ,NCNR_FLAG
               ,PURCHASING_LEAD_TIME
               ,PO_TOTAL_QUANTITY
               ,PO_OPEN_QUANTITY
               ,PO_RECEIVED_QUANTITY
               ,UOM
               ,PO_UNIT_COST
               ,PO_PLACEMENT_DATE
               ,REQUEST_DATE
               ,COMMIT_DATE
               ,AS_OF_DATE
               ,description
			   ,STATUS_PO
			   ,STATUS_POPO
			   ,STATUS_POPOD 
)
   SELECT GROUP_CODE               = ISNULL(group_code,'')
         ,SUPPLIER                 = 'Accton'
         ,SUPPLIER_SITE            = 'JoyTech'
         ,CM_PART_NUMBER           = ISNULL(b.part_no,'')
         ,JUNIPER_PART_NUMBER      = CASE WHEN ISNULL(juniper_part_no,'') = 'None-Control' THEN ''
		                             ELSE ISNULL(juniper_part_no,'') END
         ,Item_Type                = ISNULL(item_type,'')
         ,PO_NUMBER                = ISNULL(a.po_no,'')
         ,PO_LINE_NUMBER           = ISNULL(CONVERT(varchar(8),a.id_popod),'')
		 ,PO_SUPPLIER_NAME         = ISNULL(CONVERT(varchar(255),e.vendor_alias ),'') 
       --,PO_SUPPLIER_NAME         = CASE WHEN ISNULL(CONVERT(varchar(255),e.vendor_alias ),'') Like '%[^A-Za-z0-9]%' THEN '' ELSE ISNULL(e.vendor_alias,'') END --add by micky-20171026
         ,PO_SUPPLIER_CONTACT_NAME = ISNULL(CONVERT(varchar(55),e.contact1 ),'')
         ,MANUFACTURER_NAME        = ISNULL(CONVERT(varchar(255),'' ),'')
         ,MANUFACTURE_PART_NUMBER  = ISNULL(CONVERT(varchar(100),''),'')
         ,BUYER_CODE               = ISNULL(buyer_id,'')
         ,BUYER_NAME               = ISNULL(buyer_name,'')
         ,NCNR_FLAG                = ISNULL(CONVERT(varchar(3),''),'')
         ,PURCHASING_LEAD_TIME     = ISNULL(f.lead_time,'')
       --,PO_TOTAL_QUANTITY        = ISNULL(a.qty_openpo,0.0)
       --,PO_OPEN_QUANTITY         = ISNULL(a.qty_buy,0.0)
         ,PO_TOTAL_QUANTITY        = ISNULL(a.qty_buy,0.0)	-- change by Jill on 2017-07-18
         ,PO_OPEN_QUANTITY         = ISNULL(a.qty_openpo,0.0)
         ,PO_RECEIVED_QUANTITY     = ISNULL(a.qty_pass,0.0)
         ,UOM                      = ISNULL(b.unit_meas,'')
         ,PO_UNIT_COST             = ISNULL(PO_UNIT_COST,0.0)
         ,PO_PLACEMENT_DATE        = ISNULL(replace(CONVERT(char(10),g.dt_create,120),'-','/'),'') 
		                           --modIFy by micky 20170928
       --,SUBSTRING(CONVERT(char(16),g.dt_create,120) ,6,2) + '/' + SUBSTRING(CONVERT(char(16),g.dt_create,120) ,9,2) + '/' + SUBSTRING(CONVERT(char(16),g.dt_create,120) ,1,4)+ ' ' +  SUBSTRING(CONVERT(char(16),g.dt_create,120) ,12,5)
       --,SUBSTRING(g.dt_create ,6,2) + '/' + SUBSTRING(g.dt_create ,9,2) + '/' + SUBSTRING(g.dt_create ,1,4)+ ' ' +  SUBSTRING(g.dt_create ,12,5)
       --,PO_PLACEMENT_DATE        = SUBSTRING(CONVERT(char(16),h.dt_create,120) ,6,2) + '/' + SUBSTRING(CONVERT(char(16),h.dt_create,120) ,9,2) + '/' + SUBSTRING(CONVERT(char(16),h.dt_create,120) ,1,4)
       --,SUBSTRING(CONVERT(char(16),g.dt_create,120) ,6,2) + '/' + SUBSTRING(CONVERT(char(16),g.dt_create,120) ,9,2) + '/' + SUBSTRING(CONVERT(char(16),g.dt_create,120) ,1,4)+ ' ' +  SUBSTRING(CONVERT(char(16),g.dt_create,120) ,12,5)
       --,SUBSTRING(g.dt_create ,6,2) + '/' + SUBSTRING(g.dt_create ,9,2) + '/' + SUBSTRING(g.dt_create ,1,4)+ ' ' +  SUBSTRING(g.dt_create ,12,5)
         ,REQUEST_DATE             = ISNULL(replace(CONVERT(char(10),a.dt_need,120),'-','/'),'') --modIFy by micky 20170928
       --,COMMIT_DATE              = ISNULL(SUBSTRING(CONVERT(char(16),a.dt_schedule,120) ,6,2) + '/' + SUBSTRING(CONVERT(char(16),a.dt_schedule,120) ,9,2) + '/' + SUBSTRING(CONVERT(char(16),a.dt_schedule,120) ,1,4),'')
       -- Jill -- Update by Jill on 20170308 for IF no confirm schedule date put empty
	     ,COMMIT_DATE              = CASE WHEN  SUBSTRING(CONVERT(char(16),a.dt_schedule,120) ,1,4)  = CONVERT(varchar(4),DATEADD(year,10,GETDATE()),112) THEN CONVERT(char(16),'')
                                     ELSE ISNULL(replace(CONVERT(char(10),a.dt_schedule,120),'-','/'),'')  END --modIFy by micky 20170928
	     ,AS_OF_DATE               = ISNULL(@DATE_GEN_STD,'') --CONVERT(varchar(10),GETDATE(),101)
		                           --modIFy by micky 20170928
	     ,Description              = ISNULL(REPLACE(b.description,',',' '),'')
	     ,STATUS_PO                = g.status_po
	     ,STATUS_POPO              = g.status_popo
		 ,STATUS_POPOD             = h.status_popod  --add 3 STATUS by micky 171110
    FROM vw_orig_openpo a            
        ,#tmp_icim_comp b            
        ,admslip c (nolock)            
        ,admcomp d (nolock)            
        ,vendor  e (nolock)            
        ,icim_purchase f (nolock)            
        ,popo g (nolock)            
        ,popod h (nolock)          
   WHERE a.id_icim_comp = b.id_icim_comp             
     AND g.id_popo = a.id_popo             
     AND a.id_vendor_order = e.id_vendor             
     AND a.id_icim_comp = f.id_icim_comp             
     AND a.id_admslip = c.id_admslip            
     AND a.id_admcomp = d.id_admcomp             
     AND g.id_popo = h.id_popo         
     AND h.id_popod = a.id_popod         
     AND d.stat_isheadquarter = 1            
     AND c.stat_supply = 1
   --AND g.status_po <> 8
   --AND h.status_popod <> 8


--UPDATE 1 .12/31/8888 replace empty          
 /* mark by Jill on 2013-05             
  UPDATE #tmp_partner_out_data SET COMMIT_DATE = CONVERT(varchar(10),'')          
    FROM #tmp_partner_out_data          
   WHERE COMMIT_DATE = '12/31/8888'          
 */

 --SELECT COUNT(*) FROM #tmp_partner_out_data
               
     IF object_id('tempdb.dbo.#qvl_unique') is not null drop table #qvl_unique
   SELECT a.CM_PART_NUMBER,MANUFACTURER_NAME = c.grobal_vendor_name  
     intO #qvl_unique              
     FROM #tmp_partner_out_data a    
         ,qvl b (nolock)  
         ,qvl_vendor c (nolock)  
    WHERE a.CM_PART_NUMBER = b.part_no collate Chinese_PRC_Stroke_CI_AS              
      AND b.id_qvl_vendor = c.id_qvl_vendor   
      AND c.stat_void = 0   
      AND b.stat_void = 0 
	  AND b.stat_phaseout = 0  
    GROUP BY a.CM_PART_NUMBER,c.grobal_vendor_name  
   HAVING COUNT (*) = 1               
             
 --SELECT top 57 'table' = '#qvl_unique',* FROM #qvl_unique                  
  
   UPDATE a SET MANUFACTURE_PART_NUMBER = vendor_partno
               ,MANUFACTURER_NAME = c.MANUFACTURER_NAME              
 --SELECT vendor_partno,MANUFACTURE_PART_NUMBER,*               
     FROM #tmp_partner_out_data a              
         ,qvl b (nolock)              
         ,#qvl_unique c              
    WHERE a.CM_PART_NUMBER = b.part_no collate Chinese_PRC_Stroke_CI_AS                  
      AND b.part_no = c.CM_PART_NUMBER collate Chinese_PRC_Stroke_CI_AS
      AND b.stat_void = 0                  
                  

     IF object_id('tempdb.dbo.#qvl_multi') is not null drop table #qvl_multi              
   SELECT a.CM_PART_NUMBER               
     intO #qvl_multi              
     FROM #tmp_partner_out_data a  JOIN qvl b (nolock)              
       ON a.CM_PART_NUMBER = b.part_no collate Chinese_PRC_Stroke_CI_AS              
      AND b.stat_void = 0 
	  AND b.stat_phaseout = 0              
    GROUP BY a.CM_PART_NUMBER              
   HAVING COUNT (*) > 1               
                    
   UPDATE a SET MANUFACTURE_PART_NUMBER = 'Multi_MFG_PART'              
     FROM #tmp_partner_out_data a              
        , #qvl_multi c              
    WHERE a.CM_PART_NUMBER = c.CM_PART_NUMBER collate Chinese_PRC_Stroke_CI_AS                  
  
 --SELECT top 57 '#qvl_multi', * FROM #qvl_multi

 
/*--[Start]INSERT intO Real Table  
   INSERT intO scvo_openpo(
               dt_openpo
              ,group_code
              ,supplier
              ,supplier_site
              ,cm_part_number
              ,juniper_part_number
              ,item_type
              ,po_number
              ,po_line_number
              ,po_supplier_name
              ,po_supplier_contact_name
              ,manufacturer_name
              ,manufacture_part_number
              ,buyer_code
              ,buyer_name
              ,ncnr_flag
              ,purchasing_lead_time
              ,po_total_quantity
              ,po_open_quantity
              ,po_received_quantity
              ,uom
              ,po_unit_cost
              ,po_placement_date
              ,request_date
              ,commit_date
              ,as_of_date
              ,description
)
   SELECT dt_openpo = CONVERT(datetime,CONVERT(char(10),dateadd(d,-1,getdate()),121))
         ,GROUP_CODE
         ,SUPPLIER
         ,SUPPLIER_SITE
         ,CM_PART_NUMBER
         ,JUNIPER_PART_NUMBER
         ,Item_Type
         ,PO_NUMBER
         ,PO_LINE_NUMBER
         ,PO_SUPPLIER_NAME
         ,PO_SUPPLIER_CONTACT_NAME
         ,MANUFACTURER_NAME
         ,MANUFACTURE_PART_NUMBER
         ,BUYER_CODE
         ,BUYER_NAME
         ,NCNR_FLAG
         ,PURCHASING_LEAD_TIME
         ,PO_TOTAL_QUANTITY
         ,PO_OPEN_QUANTITY
         ,PO_RECEIVED_QUANTITY
         ,UOM
         ,PO_UNIT_COST
         ,PO_PLACEMENT_DATE
         ,REQUEST_DATE
         ,COMMIT_DATE
         ,AS_OF_DATE
         ,description              
     FROM #tmp_partner_out_data  

 --SELECT top 57 * FROM scvo_openpo  
 --RETURN  
*/--[End]INSERT intO Real Table  
  

   INSERT intO #tmp_MT_PurchaseOrder(
			    ITEM_NAME
               ,ORGANIZATION_CODE
               ,SR_INSTANCE_CODE
               ,SUPPLIER_NAME
               ,ORDER_TYPE
               ,FIRM_PLANNED_TYPE
               ,SUPPLIER_SITE_CODE
               ,PURCH_LINE_NUM
               ,ORDER_NUMBER
               ,REVISION
               ,NEW_ORDER_QUANTITY
               ,BMT_FLAG
               ,REQUESTED_SHIP_DATE
               ,PROMISED_SHIP_DATE
               ,CARRIER_NAME
               ,MODE_OF_TRANSPORT
               ,SERVICE_LEVEL
               ,SHIP_METHOD
               ,DROP_SHIP_DEST_TYPE
               ,DROP_SHIP_CUST_NAME
               ,DROP_SHIP_CUST_SITE_CODE
               ,SCHEDULE_LINE_NUM
               ,DELIVERY_PRICE
               ,REQUESTED_DELIVERY_DATE
               ,PROMISED_DELIVERY_DATE
               ,SUBINVENTORY_CODE
               ,DELETED_FLAG
               ,CM_PART_NUMBER
               ,NCNR_FLAG
               ,PO_TOTAL_QUANTITY
               ,PO_RECEIVED_QUANTITY
               ,PO_UNIT_COST
               ,GROUP_CODE
               ,FREE_ATTR1
               ,FREE_ATTR2
               ,FREE_ATTR3
               ,FREE_ATTR4
               ,FREE_ATTR5
               ,FREE_ATTR6
               ,FREE_ATTR7
               ,FREE_ATTR8
               ,FREE_ATTR9
               ,FREE_ATTR10
               ,FREE_ATTR11
               ,FREE_ATTR12
               ,FREE_ATTR13
               ,FREE_ATTR14
               ,FREE_ATTR15
               ,FREE_ATTR16
               ,FREE_ATTR17
               ,FREE_ATTR18
               ,FREE_ATTR19
               ,FREE_ATTR20
)
   SELECT ITEM_NAME = ISNULL(ltrim(rtrim(JUNIPER_PART_NUMBER)), '')
         ,ORGANIZATION_CODE  = 'JoyTech'
         ,SR_INSTANCE_CODE = 'EXT'
         ,SUPPLIER_NAME = ISNULL(ltrim(rtrim(SUPPLIER)) , '')
         ,ORDER_TYPE = '1'
         ,FIRM_PLANNED_TYPE = 'No'
         ,SUPPLIER_SITE_CODE = ISNULL(ltrim(rtrim(PO_SUPPLIER_NAME)), '')
         ,PURCH_LINE_NUM = ISNULL(ltrim(rtrim(PO_LINE_NUMBER)), '')
         ,ORDER_NUMBER = ISNULL(ltrim(rtrim(PO_NUMBER)), '')
         ,REVISION = ''
         ,NEW_ORDER_QUANTITY = ISNULL(ltrim(rtrim(PO_OPEN_QUANTITY)), '')
         ,BMT_FLAG = ''
         ,REQUESTED_SHIP_DATE = ISNULL(ltrim(rtrim(REQUEST_DATE)), '')
         ,PROMISED_SHIP_DATE = ISNULL(ltrim(rtrim(COMMIT_DATE)), '')
         ,CARRIER_NAME = ''
         ,MODE_OF_TRANSPORT = ''
         ,SERVICE_LEVEL = ''
		 ,SHIP_METHOD = ''
		 ,DROP_SHIP_DEST_TYPE = ''
		 ,DROP_SHIP_CUST_NAME = ''
		 ,DROP_SHIP_CUST_SITE_CODE = ''
		 ,SCHEDULE_LINE_NUM = ''
		 ,DELIVERY_PRICE = ''
		 ,REQUESTED_DELIVERY_DATE = ''
		 ,PROMISED_DELIVERY_DATE = ''
		 ,SUBINVENTORY_CODE = ''
		 ,DELETED_FLAG = 'No'
		 ,CM_PART_NUMBER = ltrim(rtrim(CM_PART_NUMBER))
		 ,NCNR_FLAG = ltrim(rtrim(NCNR_FLAG))
		 ,PO_TOTAL_QUANTITY = ltrim(rtrim(PO_TOTAL_QUANTITY))
		 ,PO_RECEIVED_QUANTITY = ltrim(rtrim(PO_RECEIVED_QUANTITY))
		 ,PO_UNIT_COST = ltrim(rtrim(PO_UNIT_COST))
		 ,GROUP_CODE = ltrim(rtrim(group_code))
		 ,FREE_ATTR1 = ''
		 ,FREE_ATTR2 = ''
		 ,FREE_ATTR3 = ''
		 ,FREE_ATTR4 = ''
		 ,FREE_ATTR5 = ''
		 ,FREE_ATTR6 = ''
		 ,FREE_ATTR7 = ''
		 ,FREE_ATTR8 = ''
		 ,FREE_ATTR9 = ''
		 ,FREE_ATTR10 = ''
		 ,FREE_ATTR11 = ''
		 ,FREE_ATTR12 = ''
		 ,FREE_ATTR13 = ''
		 ,FREE_ATTR14 = ''
		 ,FREE_ATTR15 = ''
		 ,FREE_ATTR16 = ''
		 ,FREE_ATTR17 = ''
		 ,FREE_ATTR18 = ''
		 ,FREE_ATTR19 = ''
		 ,FREE_ATTR20 = ''
     FROM #tmp_partner_out_data
                  

/*--modIFy by micky 20170928 start  
  DECLARE @header nvarchar(MAX), @tag_start  nvarchar(MAX), @tag_end nvarchar(MAX) 

   SELECT @header  = RTRIM(b.description)
     FROM admconfig a (nolock)
        , admconfigd b(nolock)
	    , admcomp c (nolock)
    WHERE a.id_admconfig  = b.id_admconfig  
      AND b.code = 'IBP_HEAD_TAG'
	  AND a.win_code = 'DT067'
	  AND a.id_admcomp = c.id_admcomp 
	  AND c.stat_isheadquarter = 1
	  AND c.stat_active = 1
	  AND c.stat_void = 0 
 --SELECT @header

   SELECT @tag_start = ltrim(rtrim(admconfigd.description)), @tag_end = ltrim(rtrim(admconfigd.code))
     FROM admconfig,admconfigd
    WHERE admconfig.config_code = 'IBP'
      AND admconfig.id_admconfig = admconfigd.id_admconfig
      AND admconfigd.config_value = 'PO'  --改為各自的Message Code
*/--modIFy by micky 20170928 end

         
--</3.Data Prepare Area>
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
--[ 4.Data VerIFy ]-----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--<4.Data VerIFy Area>

 --SELECT 'Table' = '#tmp_inputstring', * FROM #tmp_inputstring

--</4.Data VerIFy Area>
------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------
--[ 5.Data Transaction ]------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--<5.Data Transaction Area>

   SELECT @header = LTRIM(RTRIM(b.description))
     FROM admconfig a (nolock)
         ,admconfigd b(nolock)
         ,admcomp c (nolock)
    WHERE a.id_admconfig  = b.id_admconfig  
      AND b.code = 'IBP_HEAD_TAG'
      AND a.win_code = 'DT067'
      AND a.id_admcomp = c.id_admcomp 
	  AND c.stat_isheadquarter = 1
	  AND c.stat_active = 1
      AND c.stat_void = 0 
  --SELECT @header
	
/*--@amber_shi ver.
   SELECT @tag_start = LTRIM(RTRIM(admconfigd.config_value))
		 ,@tag_end = LTRIM(RTRIM(admconfigd.authorize_user))
	 FROM admconfig
	     ,admconfigd
	WHERE admconfig.config_code = 'IBP_NAMES'
      AND admconfig.id_admconfig = admconfigd.id_admconfig
      AND admconfigd.code = 'IBP_OPENPO'
*/	   

   SELECT @namespace = ISNULL(RTRIM(LTRIM(admconfigd.config_value)),'')	
	     ,@tag_end   = ISNULL(RTRIM(LTRIM(admconfigd.authorize_user)),'')	
	 FROM admconfig  with(nolock)    
	     ,admconfigd with(nolock)    
		 ,admcomp    with(nolock)
    WHERE admconfig.id_admconfig = admconfigd.id_admconfig    
	  AND admconfig.config_code = 'IBP_NAMES'
	  AND RTRIM(LTRIM(admconfigd.code)) = @msg_type
	  AND admconfig.id_admcomp = admconfig.id_admcomp 
	  AND admcomp.stat_isheadquarter = 1
	  AND admcomp.stat_active = 1
	  AND admcomp.stat_void = 0 

/*
<?xml version="1.0" encoding="utf-8"?>
<ns0:MT_PurchaseOrder xmlns:ns0="urn:juniper.net:IBP:PTP:CM:OracleSupplyCloud:PurchaseOrder:I592">
<Records>
<ns0:MT_PurchaseOrder>
*/


/*                        
 TransEnd:   
  
--DECLARE @path nvarchar(255)
--DECLARE @dt_generate varchar(MAX),@dt_openpo varchar(MAX)  
   
       IF ISNULL(@actioncode,'')='A'  

          BEGIN   

                SELECT top 1 @dt_generate = CONVERT(varchar(19),dt_generate,121)  
                          --,@dt_openpo   = CONVERT(varchar(10),dt_openpo ,112)  
                  FROM workTemp.dbo.ibp_openpo_snapshot with(nolock)   
                 WHERE CONVERT(varchar(10),dt_generate,121) = CONVERT(varchar(10),GETDATE(),121)  
   
              --SELECT @dt_generate = '<dt_generate>' + ISNULL(@dt_generate,'') + '</dt_generate>'  
              --SELECT @dt_openpo   = '<dt_openpo>' + ISNULL(@dt_openpo,'') + '</dt_openpo>'  

           END  
*/
 
/*  
--Test
   SELECT @folder='ibp\test'     --Test  
   SELECT @path='/archive/Test/' --Test  
   SELECT @folder='<floder>'+ISNULL(@folder,'')+'</floder>'  
   SELECT @path='<path>'+ISNULL(@path,'')+'</path>'  
--Test  
*/  

  DECLARE @PurchaseOrder nvarchar(MAX)

    SET @PurchaseOrder = --@tag_start 
	                 --+ '<MT_PurchaseOrder>'
	                     ISNULL((SELECT --top 1
                                        ITEM_NAME = ISNULL(ltrim(rtrim(JUNIPER_PART_NUMBER)), '')
                                       ,ORGANIZATION_CODE  = 'JoyTech'
                                       ,SR_INSTANCE_CODE = 'EXT'
                                       ,SUPPLIER_NAME = ISNULL(ltrim(rtrim(SUPPLIER)) , '')
                                       ,ORDER_TYPE = '1'
                                       ,FIRM_PLANNED_TYPE = 'No'
                                       ,SUPPLIER_SITE_CODE = ISNULL(ltrim(rtrim(PO_SUPPLIER_NAME)), '')
                                       ,PURCH_LINE_NUM = ISNULL(ltrim(rtrim(PO_LINE_NUMBER)), '')
                                       ,ORDER_NUMBER = ISNULL(ltrim(rtrim(PO_NUMBER)), '')
                                       ,REVISION = ''
                                       ,NEW_ORDER_QUANTITY = ISNULL(ltrim(rtrim(PO_OPEN_QUANTITY)), '')
                                       ,BMT_FLAG = ''
                                       ,REQUESTED_SHIP_DATE = ISNULL(ltrim(rtrim(REQUEST_DATE)), '')
                                       ,PROMISED_SHIP_DATE = ISNULL(ltrim(rtrim(COMMIT_DATE)), '')
                                       ,CARRIER_NAME = ''
                                       ,MODE_OF_TRANSPORT = ''
                                       ,SERVICE_LEVEL = ''
	                                   ,SHIP_METHOD = ''
                                       ,DROP_SHIP_DEST_TYPE = ''
							           ,DROP_SHIP_CUST_NAME = ''
							           ,DROP_SHIP_CUST_SITE_CODE = ''
							           ,SCHEDULE_LINE_NUM = ''
							           ,DELIVERY_PRICE = ''
							           ,REQUESTED_DELIVERY_DATE = ''
							           ,PROMISED_DELIVERY_DATE = ''
                                       ,SUBINVENTORY_CODE = ''
 							           ,DELETED_FLAG = 'No'
							           ,CM_PART_NUMBER = ltrim(rtrim(CM_PART_NUMBER))
							           ,NCNR_FLAG = ltrim(rtrim(NCNR_FLAG))
							           ,PO_TOTAL_QUANTITY = ltrim(rtrim(PO_TOTAL_QUANTITY))
							           ,PO_RECEIVED_QUANTITY = ltrim(rtrim(PO_RECEIVED_QUANTITY))
							           ,PO_UNIT_COST = ltrim(rtrim(PO_UNIT_COST))
							           ,GROUP_CODE = ltrim(rtrim(group_code))
							           ,FREE_ATTR1 = ''
							           ,FREE_ATTR2 = ''
                                       ,FREE_ATTR3 = ''
  							           ,FREE_ATTR4 = ''
							           ,FREE_ATTR5 = ''
							           ,FREE_ATTR6 = ''
							           ,FREE_ATTR7 = ''
							           ,FREE_ATTR8 = ''
							           ,FREE_ATTR9 = ''
							           ,FREE_ATTR10 = ''
							           ,FREE_ATTR11 = ''
							           ,FREE_ATTR12 = ''
							           ,FREE_ATTR13 = ''
							           ,FREE_ATTR14 = ''
							           ,FREE_ATTR15 = ''
							           ,FREE_ATTR16 = ''
							           ,FREE_ATTR17 = ''
							           ,FREE_ATTR18 = ''
							           ,FREE_ATTR19 = ''
							           ,FREE_ATTR20 = ''
                               --SELECT top 57 *
                                   FROM #tmp_partner_out_data Records FOR xml auto, elements), '<Records/>')
	                 --+ '</MT_PurchaseOrder>'
				     --+ @tag_end

 --SELECT '@PurchaseOrder-57', @PurchaseOrder

   SELECT @PurchaseOrder = @header
                         + ISNULL(@namespace, '')
						 + ISNULL(CAST(@PurchaseOrder AS nvarchar(MAX)), '')
						 + ISNULL(@tag_end, '')

 --SELECT '@PurchaseOrder-57', @PurchaseOrder


--xml transfer to nvarchar
--run function to remove mojibake AND transfer back origianl xml format
   SELECT @PurchaseOrder = gateway.dbo.CLRXMLInvalidRemove(@PurchaseOrder) 
--show origianl xml (revised) 
 --SELECT @PurchaseOrder


   IF object_id ('tempdb.dbo.#openpo_data_list') is not null DROP TABLE #openpo_data_list
   CREATE TABLE #openpo_data_list(
	             row int identity(1,1)
		        ,openpo_data_list varchar(MAX)
)

	INSERT intO #openpo_data_list(
                 openpo_data_list
)
    SELECT @PurchaseOrder


--/*
   IF object_id('workTemp.dbo.ibp_openpo_snapshot') is not null DROP TABLE workTemp.dbo.ibp_openpo_snapshot            
      BEGIN             
            CREATE TABLE workTemp.dbo.ibp_openpo_snapshot(
                         row int identity(1,1)
                        ,openpo_data_list nvarchar(MAX)
                        ,dt_generate datetime default getdate()
						,stat_void int default 0 
)            
       END            
          --select * from workTemp.dbo.ibp_openpo_snapshot

               
   INSERT intO workTemp.dbo.ibp_openpo_snapshot(openpo_data_list)
   SELECT openpo_data_list FROM #openpo_data_list
    WHERE ISNULL(openpo_data_list,'')<>''
    ORDER BY row
--*/
 --SELECT top 57 'workTemp.dbo.ibp_openpo_snapshot', * FROM workTemp.dbo.ibp_openpo_snapshot 


 TransEnd: 

 --SELECT @folder       = '<floder>'   + ISNULL(@folder,'')   + '</floder>'   
   SELECT @filename     = '<filename>' + ISNULL(@filename,'') + '</filename>'    
   SELECT @syntax       = '<syntax>' + ISNULL(@syntax,'') + '</syntax>'
   SELECT @RTNPARAMETER = ISNULL(@RTNPARAMETER,'') + @filename + @syntax --@folder
                                             
   SELECT @ERROR_MSG = 'IBP Purchase Order Dara with ''xml'' -- Success !!!'


   SELECT @RTNPARAMETER = ISNULL(@RTNPARAMETER,'')
                        + '<stat_b2b_next>' + CONVERT(VARCHAR(10),@stat_b2b_next) + '</stat_b2b_next>'
                        + '<actioncode>' + @actioncode + '</actioncode>'  

   SELECT @XML_OUTPUT = CAST('<rowset>' 
                      + '</rowset>' 
					  +   '<rtnparameter>'
					  +      ISNULL(@RTNPARAMETER,'') 
					  +   '</rtnparameter>' AS xml) 


--</5.Data Transaction Area>
------------------------------------------------------------------------------------------------------
    

/* --add by micky for temp test

  DECLARE @floder varchar(255)

/*設定路徑 為SVCO 測試的資料夾*/
   SELECT @floder = '\\srv_missqlbk\storedcerts\FTP\FILES\ibp\test\' + CONVERT(varchar(10),getdate(),120)

/*判斷路徑資料夾是否存在，若不存在，則產生資料夾*/
   IF gateway.dbo.CLRExistFolder( @floder ) = -1 
   SELECT gateway.dbo.CLRCreateFolder( @floder )

   SELECT gateway.dbo.CLRWriteFile(@floder + '\'+@filename,@Document,65001)

/*
Message                            
Item feed                I590   ITEM_MASTER 
Open PO                  I592   OPENPO
Work Order               I601   WORKORDER
WO reservations          I602   RESERVATION 
On HAND                  I605   ONHAND
In-Transit Inventory     I606   INSTRANSIT 
*/

  
   SELECT @code = 'OPENPO'  -- << 參考上面對照表


/*以下設定不需修改，直接直行即可*/
------------------------------------------------------------------------------------------------------


/*資料存放路徑，修改為IBP的TEST當中*/
   SELECT @floder = '\\srv_missqlbk\storedcerts\FTP\FILES\ibp\test\' + CONVERT(varchar(10),getdate(),120)
/*資料檔名，修改為抓取YYYYMMDD_HHMMSS_ACCTON_XXXX.xml*/
   SELECT @filename = CONVERT(varchar(8),getdate(),112) + '_' + replace(ltrim(rtrim(CONVERT(varchar(8), getdate(), 114))), ':','') + '_ACCTON_' + ISNULL(@code,'') + '.xml'

   SELECT '@filename' = @filename

 --SELECT '@filename'=@filename,'@floder'=@floder

     IF gateway.dbo.CLRExistFolder( @floder ) = -1  -->> 檢查資料夾是否存在
    BEGIN
          SELECT gateway.dbo.CLRCreateFolder( @floder )  -->> 若不存在則會產生資料夾
     END

   SELECT gateway.dbo.CLRWriteFile(@floder + '\'+@filename,@Document,65001) -->> 產生檔案，@Docment是產生的xml檔
*/--add by micky for temp test


     
--DECLARE @data_rowcount int        
 --SELECT @data = ( SELECT * FROM #temp a FOR xml auto, elements , ROOT('test'))     
 --SELECT @data  
  
/*[next step para]
   SELECT @XML_INPUT = '<sb_request_context>                      
                          <inputstring>      
                            <floder>ibp</floder>    
                            <filename>ibp_item.txt</filename>    
                            <syntax>SELECT part_no FROM scvo_item_detail WHERE id_scvo_item_master=5</syntax>                       
                          </inputstring>                      
                        </sb_request_context>'   
*/    


------------------------------------------------------------------------------------------------------


   COMMIT TRANSACTION                
--ROLLBACK
                
 END TRY                
                
    BEGIN CATCH                
                
          SELECT @ERROR_SEVERITY = ERROR_SEVERITY()               
          SELECT @ERROR_PROC     = ERROR_PROCEDURE()                
                
            IF ERROR_STATE() >= 101 AND ERROR_STATE() <= 200                
               SELECT @RTN_STATUS = ERROR_STATE()                
           ELSE               
               SELECT @RTN_STATUS = 201                
                
          SELECT @ERROR_MSG = '[PROC]:[' + LTRIM(STR(@PROCLEVEL)) + ']' + @PROCNAME + '[LINE]:' + CONVERT(varchar(MAX),ERROR_LINE()) + ', ' + ERROR_MESSAGE()                
                
            IF (XACT_STATE()) = -1                
                
				BEGIN                
                      ROLLBACK TRANSACTION                
                 END                
                
          GOTO Exception                
                
     END CATCH                
      
          
 ProcEnd:       

   SELECT @XML_OUTPUT = CAST ( '<outputstring>'
                           --+    ISNULL(CAST ( @XML_OUTPUT AS nvarchar(MAX) ), '<rowset/><rtnparameter/>')
                             +    '<rtncode>'                
                             +       '<code>' + LTRIM(str(@RTN_STATUS)) + '</code>'                
                             +       '<msg>'  + dbo.HTMLEncode(@ERROR_MSG)  + '</msg>' --> gateway.dbo.CLRHtmlEncode(@ERROR_MSG)                 
                             +    '</rtncode>'                    
                             +    CAST ( @XML_OUTPUT AS nvarchar(MAX) )                
                             +    ISNULL(@wf_msg, '') --> Work Flow Use                
                             +    ISNULL(@inputstring, '') --> Work Flow Use                
                             + '</outputstring>' AS xml )                
                
    EXEC SourceDB.dbo.zp_GlobalSB_Set_MSG @XML_OUTPUT                
 --SELECT '@XML_OUTPUT' = @XML_OUTPUT
                
   RETURN @RTN_STATUS                
               
			    
Exception:                
                
   SELECT @XML_OUTPUT = CAST ( '<outputstring>'                
                             +    '<rtncode>'                
                             +       '<code>' + LTRIM(str(@RTN_STATUS)) + '</code>'                
                             +       '<msg>'  + dbo.HTMLEncode(@ERROR_MSG)  + '</msg>' --> gateway.dbo.CLRHtmlEncode(@ERROR_MSG)
                             +    '</rtncode>'                    
                             +    CAST ( @XML_OUTPUT AS nvarchar(MAX) )                
                             +    ISNULL(@wf_msg, '') --> Work Flow Use                
                             +    ISNULL(@inputstring, '') --> Work Flow Use                
                             + '</outputstring>' AS xml )                
       
    EXEC SourceDB.dbo.zp_GlobalSB_Set_MSG @XML_OUTPUT
 --SELECT '@XML_OUTPUT' = @XML_OUTPUT                
                
   SELECT @DOC_OUTPUT = CAST( @XML_OUTPUT AS nvarchar(MAX) )                

                
RAISERROR ('<ERROR>PROC:[%d]%s CODE:%d</ERROR>%s)' ,@ERROR_SEVERITY ,@RTN_STATUS ,@PROCLEVEL ,@PROCNAME ,@RTN_STATUS ,@DOC_OUTPUT )


GO
Grant Execute On dbo.zp_ibp_openpo_build_data To Public
GO