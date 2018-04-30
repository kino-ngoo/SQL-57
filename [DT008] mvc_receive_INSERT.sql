USE [joyDB]
GO

/****** Object:  StoredProcedure [dbo].[mvc_receive_INSERT]    Script Date: 04/30/2018 02:15:54 PM  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[mvc_receive_INSERT] AS

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_WARNINGS ON
SET ANSI_PADDING ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NOCOUNT ON

--begin tran
--rollback


  DECLARE @XML_INPUT XML ,@XML_OUTPUT XML 
  DECLARE @ERROR_MSG varchar(2000),@XML_MSG XML ,@PROCNAME varchar(100) ,@return_message nvarchar(MAX)
  DECLARE @ERROR_PROC varchar(1000) ,@PROCLEVEL int ,@ERROR_SEVERITY int,@RTN_STATUS int                         
  DECLARE @ROWSET nvarchar(MAX) ,@RTNPARAMETER nvarchar(MAX)                                                                   
                                                                                
  SELECT  @PROCLEVEL      = @@NESTLEVEL                                                                                  
  SELECT  @PROCNAME       = ISNULL( OBJECT_NAME(@@PROCID) ,'' )                                                                                  
  SELECT  @ERROR_PROC     = ''                                                                                  
  SELECT  @ERROR_MSG      = ''                                                                                  
  SELECT  @ERROR_SEVERITY = 0                                                                      
  SELECT  @RTN_STATUS     = 0                                                   
  SELECT  @XML_OUTPUT     = '<rowset/><rtnparameter/>'                        
  SELECT  @ROWSET         = '<rowset/>'                    
  SELECT  @XML_MSG        = ''                                

SET XACT_ABORT ON 

/*----------------------------------------------------------------------------------------------------
[ 0.REQUEST RECORD ]
 2017/10/23 : INSERT partial hub intO EXPIC, RCVIC by boss
 create by  : micky_wu

[ 1.UPDATE SEQUENCE ]
  expect_receive í· expect_received í· expect_extension 
í· receive_invioce í· receive í· received í· received_extension í· ictr í· ictrd
*/----------------------------------------------------------------------------------------------------


--(BEG)---(REC) ------------------------------------------------------------------------------------------------------
--(10)--- ServerBroker ( Don't Move or Change it ) ------------------------------------------------------------------------------------------------------


  DECLARE @xml_request XML ,@xml_result XML ,@xmldoc INT ,@global_id VARCHAR(100) ,@DOC_OUTPUT NVARCHAR(MAX)
   EXEC SourceDB.dbo.zp_GlobalSB_Get_MSG 'REC' ,@XML_INPUT OUTPUT ,@xmldoc OUTPUT ,@global_id OUTPUT


/*
SELECT @XML_INPUT = '<sb_request_context>
                       <inputstring>
                         <duns_no_to>0001</duns_no_to>
                         <dn_no>171100325</dn_no>
                         <id_Gedi_preasn_head>360</id_Gedi_preasn_head>
                         <person_uid>839</person_uid>
                       </inputstring>
                     </sb_request_context>' 
*/

    EXEC sp_xml_preparedocument @xmldoc output ,@XML_INPUT

   IF object_id ('tempdb.dbo.#tmp_inputstring') is not null DROP TABLE #tmp_inputstring
   CREATE TABLE #tmp_inputstring(
                 id_Gedi_preasn_head int NULL
		        ,dn_no nvarchar(20) NULL
			    ,person_uid varchar(10) NULL
)

   INSERT #tmp_inputstring
   SELECT * FROM openxml(@xmldoc, '/sb_request_context/inputstring', 3) with #tmp_inputstring


 --SELECT * FROM #tmp_inputstring
 --RETURN

    EXEC sp_xml_removedocument @xmldoc

  -- /*
     IF (SELECT count(*) FROM #tmp_inputstring) = 0
        BEGIN
              RAISERROR('2.1 Warn, #tmp_inputstring has No Data, Please Check it. !!', 16, 101)
         END
  --*/

  --UPDATE #tmp_inputstring set dn_no = LTRIM(RTRIM(dn_no))
  -- WHERE dn_no like '% %'

  DECLARE @id_Gedi_preasn_head int, @dn_no nvarchar(50) ,@person_uid varchar(10)
   SELECT TOP 1 @id_Gedi_preasn_head = id_Gedi_preasn_head
		       ,@dn_no = LTRIM(RTRIM(dn_no))
		       ,@person_uid = person_uid
     FROM #tmp_inputstring

  --SELECT '@id_Gedi_preasn_head' = @id_Gedi_preasn_head, '@dn_no' = @dn_no

   IF object_id ('tempdb.dbo.#tmp_Gedi_preasn_hub') is not null DROP TABLE #tmp_Gedi_preasn_hub
   CREATE TABLE #tmp_Gedi_preasn_hub(
                 id_Gedi_preasn_dn int
				,qty_dn_ship Decimal(14,2)
				,qty_dn_receive Decimal(14,2)
				,dn_no nvarchar(50)
				,id_Gedi_preasn_head int
		      --,vendor_duns_no
			    ,id_vendor int
				,dt_create datetime
				,dt_need datetime
				,delivery_no varchar(20)
				,currency char(3)
				,address varchar(30)
			  --,create_by varchar(20)
				,id_Gedi_preasn_detail int
				,buyer_part_no char(20)
				,seller_part_no char(20)
				,descrip varchar(60)
				,up Decimal(16,6)
				,unit_meas char(4)
				,qty_buy Decimal(14,2)
				,qty_comfirm Decimal(14,2)
				,qty_received Decimal(14,2)
		      --,source_id int
			    ,qty_ship Decimal(14,2)
				,iqc_type varchar(20)
)
   INSERT intO #tmp_Gedi_preasn_hub(
                id_Gedi_preasn_dn ,qty_dn_ship ,qty_dn_receive ,dn_no ,id_Gedi_preasn_head 
             --,vendor_duns_no  
               ,id_vendor ,dt_create ,dt_need ,delivery_no ,currency ,address --,create_by
			   ,id_Gedi_preasn_detail ,buyer_part_no ,seller_part_no ,descrip ,up ,unit_meas
			   ,qty_buy ,qty_comfirm ,qty_received ,qty_ship ,iqc_type --,source_id	
)
   SELECT id_Gedi_preasn_dn     = a.id_Gedi_preasn_dn
		 ,qty_dn_ship           = a.qty_dn_ship
		 ,qty_dn_receive        = a.qty_dn_receive
		 ,dn_no                 = LTRIM(RTRIM(a.dn_no))
		 ,id_Gedi_preasn_head   = a.id_Gedi_preasn_head
 	     ,id_vendor             = b.id_vendor
		 ,dt_create             = b.dt_create
	     ,dt_need               = b.dt_need
		 ,delivery_no           = b.delivery_no
		 ,currency              = b.currency
		 ,address               = b.address
	   --,create_by             = b.create_by
		 ,id_Gedi_preasn_detail = c.id_Gedi_preasn_detail
		 ,buyer_part_no         = c.buyer_part_no
		 ,seller_part_no        = c.seller_part_no 
		 ,descrip               = c.descrip
		 ,up                    = c.up
		 ,unit_meas             = c.unit_meas
		 ,qty_buy               = c.qty_buy
		 ,qty_confirm           = c.qty_confirm
		 --,qty_received          = c.qty_received
		 ,qty_received          = a.qty_dn_ship -- change by jill at 2018-04-23
	     ,qty_ship              = c.qty_ship
	     ,iqc_type              = c.iqc_type
     FROM Gedi_preasn_dn a
	     ,Gedi_preasn_head b
		 ,Gedi_preasn_detail c
    WHERE a.id_Gedi_preasn_head = b.id_Gedi_preasn_head
	  AND a.id_Gedi_preasn_detail = c.id_Gedi_preasn_detail
	  AND a.id_Gedi_preasn_head = @id_Gedi_preasn_head
	--AND a.dn_no = @dn_no
	  AND LTRIM(RTRIM(a.dn_no))= @dn_no
	  AND a.stat_void = 0 AND a.stat_frozen = 0
	  AND b.stat_void = 0 AND b.stat_frozen = 0
	  AND c.stat_void = 0 AND c.stat_frozen = 0
	  --AND c.qty_received > 0 -- add by jill at 2018-03-22 
	  AND a.qty_dn_ship > 0 -- change by jill at 2018-04-23
	  

 --SELECT '0??' = '#tmp_Gedi_preasn_hub', * FROM #tmp_Gedi_preasn_hub

--[20]---  Extract Data FROM Request ------------------------------------------------------------------------------------------------------
   SELECT @xml_request = CAST( dbo.fnReplTag( CAST( @XML_INPUT AS nvarchar(MAX) ) ) AS XML )	   
--[20]--- Extract Data FROM Request ------------------------------------------------------------------------------------------------------
 --SELECT top 10 * FROM workTemp.dbo.boolean_log with (nolock) 
 -- WHERE code = 'zp_process_sample' ORDER BY 1 desc
 --INSERT workTemp.dbo.boolean_log ( descrip , xmldoc , xmldoc1 ,code ) values ( '' ,@xml_request , null ,@PROCNAME)	
------------------------------------------------------------------------------------------------------

  DECLARE @wf_msg nvarchar(MAX) ,@inputstring nvarchar(MAX) ,@doc_no nvarchar(MAX)
         ,@name nvarchar(MAX) ,@actioncode varchar(10)
  DECLARE @stat_b2b_next TINYint 
   SELECT @wf_msg = CAST(T.c.query('.') AS nvarchar(MAX)) FROM @xml_request.nodes('/sb_request_context/wf') T(c)
   SELECT @wf_msg = ISNULL(@wf_msg, '<wf></wf>')
   SELECT @inputstring = CAST(T.c.query('.') AS nvarchar(MAX)) FROM @xml_request.nodes('/sb_request_context/inputstring') T(c)
   SELECT @inputstring = ISNULL(@inputstring, '<inputstring></inputstring>')

------------------------------------------------------------------------------------------------------

BEGIN TRY  
	 BEGIN TRANSACTION                                                                         

------------------------------------------------------------------------------------------------------
   
  DECLARE @dt_today datetime ,@INSERT_output nvarchar(MAX)
         ,@id_admcomp int ,@id_admuser varchar(50) ,@cost_id varchar(50) ,@user_id varchar(10)
         ,@id_admslip_expic int ,@id_admslip_rcinv int ,@id_admslip_rcvic int ,@id_admslip_ictr int
		 ,@id_expect_receive int ,@id_expect_received int
		 ,@id_receive_invoice int ,@id_receive int ,@id_received int
		 ,@id_ictr int ,@id_ictrd int
		 ,@exp_no varchar(15) ,@rcv_no char(15) ,@ictr_no char(15)
         ,@exp_admreason int ,@rcv_admreason int ,@id_icstockroom int
		 ,@id_icim_comp int ,@id_glsubject_db int ,@id_glsubject_cr int ,@id_buffer int

  DECLARE @adm_table Varchar(MAX) --> Lock Table & Get Identity Value Use        
         ,@adm_id Varchar(MAX)    --> Lock Table & Get Identity Value Use 
         ,@booking_id Varchar(MAX)--> Lock Table & Get Identity Value Use 
         ,@output Varchar(MAX)    --> Lock Table & Get Identity Value Use 
  
   
   SELECT @dt_today = GetDate()

   SELECT @id_admuser = admuser.id_admuser
         ,@cost_id = admuser.dept_id 
		 ,@id_admcomp = wf_signer_group_m.id_admcomp_hq
		 ,@user_id = admuser.user_id
     FROM admuser
	     ,wf_signer_group_m 
    WHERE admuser.user_id = wf_signer_group_m.user_id
	  AND wf_signer_group_m.id_wf_signer_group_m = @person_uid
 --SELECT @id_admuser, @cost_id ,@id_admcomp
   SELECT @id_admslip_expic = 675

   SELECT @id_icstockroom = a.id_icstockroom 
     FROM icstockroom a with(nolock)
	     ,#tmp_Gedi_preasn_hub b with(nolock)
    WHERE a.id_vendor = b.id_vendor
	  AND b.id_Gedi_preasn_head = @id_Gedi_preasn_head
	  AND a.stat_void = 0 AND a.stat_active = 1

SET rowcount 1
    SELECT @id_buffer = id_icstockroom_receive
      FROM admfacility a (nolock)
          ,admcomp b(nolock)
     WHERE a.id_admcomp = b.id_admcomp 
       AND b.stat_isheadquarter = 1
       AND a.stat_void = 0 
       AND b.stat_void = 0 
       AND a.stat_active = 1 
       AND b.stat_active = 1 
     ORDER BY a.id_admfacility 
 SET rowcount 0 
  --SELECT '@id_buffer' = @id_buffer


/*
-- Accton
  DECLARE @id_buffer int
   SELECT @id_buffer = id_icstockroom_receive FROM admfacility
    WHERE id_admcomp =2 AND id_admfacility = 1
   SELECT '@id_buffer' = @id_buffer

--JoyTech
  DECLARE @id_buffer int
   SELECT @id_buffer = id_icstockroom_receive FROM admfacility
    WHERE id_admcomp =10 AND id_admfacility = 10
   SELECT '@id_buffer' = @id_buffer

*/


  IF Object_id ('tempdb.dbo.#expect_receive') is not null DROP TABLE #expect_receive
  CREATE TABLE #expect_receive(
                id_expect_receive int Identity(1, 1)
               ,id_admcomp int
               ,id_admslip int
               ,id_admfacility_apply int
               ,id_admfacility_receive int
               ,id_business_partner int
               ,id_applier int
               ,cost_id int
               ,id_rate_type int
               ,id_paymenterm int
               ,id_priceterm int
               ,receive_type Tinyint
               ,expect_receive_no varchar(15)
               ,source_code varchar(2)
	           ,source_id int
               ,dt_apply datetime NULL
               ,dt_receiveschedule datetime
               ,currency varchar(3)
               ,amt_receive Decimal(20, 2)
               ,status_receive Tinyint NULL
               ,dt_create datetime
               ,create_by varchar(50)
               ,ref_po_no varchar(20)
               ,id_admcomp_FROM int
               ,id_business_partner_order int
)

   IF Object_id ('tempdb.dbo.#expect_received') is not null DROP TABLE #expect_received
   CREATE TABLE #expect_received(
                 id_expect_received int Identity(1, 1)
                ,id_expect_receive int
				,source_id int
                ,id_icim_comp int
                ,id_icstkroom int
                ,qty_expect_receive Decimal(14, 2)
                ,qty_received Decimal(14, 2)
                ,qty_pass Decimal(14, 2)
                ,qty_iqc Decimal(14, 2)
                ,qty_reject Decimal(14, 2)
                ,up Decimal(16, 6)
                ,um varchar(10)
                ,id_admreason int
                ,status_received Tinyint
                ,stat_hold Tinyint
                ,dt_close datetime
                ,dt_create datetime
                ,create_by varchar(20)
                ,dt_schedule datetime
                ,id_icim_comp_order int
                ,part_no varchar(30)
                ,partners_reference_no varchar(30)
                ,model_no varchar(30)
                ,description varchar(60)
                ,brand varchar(20)
                ,goods_code varchar(10)
                ,comments varchar(40)
				,loc_iqc varchar(10) NULL
                ,stat_outiqc int
				,receive_iqc_type varchar(20)
)

   IF Object_id ('tempdb.dbo.#receive_invoice') is not null DROP TABLE #receive_invoice
   CREATE TABLE #receive_invoice(
                 id_receive_invoice int identity(1,1)
				,invoice_no varchar(15)
				,id_vendor int
				,dt_invoice datetime
				,amt_invoice Decimal(14, 2)
				,amt_tax Decimal(14, 2)
				,invoice_type int
				,tax_type int
				,create_by varchar(20)
				,dt_create datetime
				,receive_no varchar(15)
				,receive_type Tinyint
				,dt_receive_invoice datetime
				,delivery_no varchar(20)
				,id_admslip int
				,ref_id int
				,buf_no varchar(15)
				,custom_apply_no varchar(20)
				,shipper_name int
)

   IF Object_id ('tempdb.dbo.#receive') is not null DROP TABLE #receive
   CREATE TABLE #receive(
                 id_receive int identity(1,1)    
                ,id_expect_receive int 
				,id_expect_received int      
                ,id_admcomp int       
                ,id_admslip int       
                ,id_admfacility_apply int       
                ,id_admfacility_receive int       
                ,cost_id int       
                ,id_business_partner int       
                ,id_receiver int       
                ,id_rate_type int       
                ,id_paymenterm int       
                ,id_priceterm int       
                ,receive_type tinyint       
                ,receive_no varchar(15)       
                ,source_code char(2)       
                ,source_no char(15)       
                ,source_id int       
                ,dt_received datetime       
                ,invoice_no char(15)       
                ,dt_ap datetime       
                ,currency char(3)       
                ,amt_receive decimal(20, 2)       
                ,status_receive tinyint       
                ,stat_accounting tinyint       
                ,stat_allowadjust tinyint       
                ,dt_create datetime       
                ,create_by varchar(20)       
                ,dt_update datetime null      
                ,update_by varchar(20) null      
                ,stat_void tinyint       
                ,stat_costvh tinyint       
                ,stat_apvh tinyint       
                ,dt_process datetime       
                ,id_ictr int       
                ,id_accounting_reference int       
                ,bto_id_stockroom int       
                ,bto_id_ictr int       
                ,iccrm_no char(15) null      
                ,print_counter smallint       
                ,vendor_deliver_no char(15)       
                ,id_receive_invoice int       
                ,id_icim_comp int       
                ,qty_receive decimal(14, 2)       
                ,qty_inspect decimal(14, 2)       
                ,qty_reject decimal(14, 2)       
                ,model_no char(30)       
                ,descrip varchar(60)
				,receive_iqc_type varchar(20)
                ,part_no char(20)       
                ,stat_outiqc int       
                ,stat_b2b tinyint       
                ,id_admcomp_FROM int       
                ,id_business_partner_order int       
                ,dt_arrival datetime null      
                ,carrier varchar(60) null      
                ,shipvia varchar(20) null      
                ,tracking_ref_no varchar(180) null      
                ,valid_days decimal(14, 2) null       
             -- ,id_expect_received int        
)

   IF Object_id ('tempdb.dbo.#received') is not null DROP TABLE #received
   CREATE TABLE #received(
                 id_received   int identity(1,1)      
                ,id_receive   int       
                ,id_expect_received int       
                ,id_icstkroom  int       
                ,loc_iqc   varchar(10)       
                ,source_id   int       
                ,id_icim_comp int       
                ,quantity   decimal(14, 2)       
                ,qty_pass   decimal(14, 2)       
                ,qty_iqc   decimal(14, 2)       
                ,qty_reject   decimal(14, 2)       
                ,qty_un_receive  decimal(14, 2)       
                ,up     decimal(16, 6)       
                ,um     varchar(10)       
                ,id_admreason  int       
                ,nocharge   tinyint       
                ,amt_local_ap  decimal(20, 2)       
                ,dt_create   datetime       
                ,create_by   varchar(20)         
                ,dt_update   datetime   null      
                ,update_by   varchar(20)   null      
                ,stat_void   tinyint       
                ,amt_local_cost  decimal(20, 2)       
                ,id_glsubject_db int       
                ,subject_no_db  char(8)       
                ,id_glsubject_cr int       
                ,subject_no_cr  char(8)       
                ,id_apinv   int       
                ,up_inv    decimal(16, 6)       
                ,invoice_no   char(15)       
                ,stat_accounting tinyint       
                ,stat_costvh  tinyint       
                ,stat_apvh   tinyint       
                ,id_iqcmaster  int       
                ,currency_inv  char(3)    null      
                ,dt_ap    datetime   null      
                ,qty_inv   decimal(14, 2)       
                ,id_received_match int       
                ,up_local_cost  decimal(16, 6)       
                ,currency_cost  char(3)    null      
                ,up_var_inv   decimal(14, 2)       
                ,rate_var_inv decimal(14, 8)       
                ,id_glsubject_ppvup int       
                ,id_glsubject_ppvrate int       
                ,id_admslip int       
                ,currency char(3)       
                ,stat_asset tinyint       
                ,cost_id int       
                ,location char(50)       
                ,stat_expic tinyint       
                ,iccrm_no char(15) null      
                ,id_icim_comp_order int       
                ,rec_rate decimal(14, 8)       
                ,custom_apply_no varchar(20) null      
                ,part_no varchar(30)         
                ,partners_reference_no varchar(30) null      
                ,model_no varchar(30)       
                ,description varchar(60)       
                ,brand varchar(20) null      
                ,goods_code varchar(10) null      
                ,comments varchar(40) null      
				,receive_iqc_type varchar(20)
                ,rohs_need_iqc int
)

   IF Object_id ('tempdb.dbo.#ictr') is not null DROP TABLE #ictr
   CREATE TABLE #ictr(
 	             id_ictr Int Identity(1, 1) NOT NULL  
 	            ,id_admcomp Int NOT NULL  
 	            ,id_admslip Int NOT NULL  
 	            ,id_admuser_applier Int NOT NULL  
 	            ,id_admuser_processer Int NOT NULL  
 	            ,cost_id Int NOT NULL  
 	            ,ref_no Varchar(20) NULL  
 	            ,source_code Varchar(2) NOT NULL  
 	            ,id_reference Int NOT NULL  
 	            ,id_project Int Default 0  
 	            ,id_glvh Int Default 0  
 	            ,dt_glvh Datetime NULL  
 	            ,currency Varchar(3) NULL  
 	            ,id_rate_type Int NOT NULL  
 	            ,dt_exchange Datetime NULL  
 	            ,tran_type Varchar(10) NOT NULL  
 	            ,apply_no Varchar(20) NOT NULL  
 	            ,dt_apply Datetime NOT NULL  
 	            ,dt_process Datetime NULL  
 	            ,create_by Varchar(20) NOT NULL  
 	            ,custom_type TinyInt Default 0  
 	            ,custom_apply_no Varchar(30) NULL  
 	            ,print_count TinyInt Default 0  
 	            ,id_shipment Int NULL  
 	            ,id_tmp_admslip_ictr Int NULL                 
)

   IF Object_id ('tempdb.dbo.#ictrd') is not null DROP TABLE #ictrd
   CREATE TABLE #ictrd(
   	             id_ictrd Int Identity(1, 1) NOT NULL  
   	            ,id_icim_comp Int NOT NULL  
   	            ,id_ictr Int NULL
   	            ,id_icstockroom Int NOT NULL  
   	            ,id_reference Int NOT NULL  
   	            ,qty_apply Decimal(14, 2) NOT NULL  
   	            ,qty_actual Decimal(14, 2) NOT NULL  
   	            ,up Decimal(16, 6) NOT NULL  
   	            ,up_cost Decimal(16, 6) NOT NULL  
   	            ,sign SmallInt NOT NULL  
   	            ,partno Varchar(20) NULL  
   	            ,descrip Varchar(60) NULL  
   	            ,id_admslip_reason Int NOT NULL  
   	            ,id_glsubject_db Int NOT NULL  
   	            ,id_glsubject_cr Int NOT NULL  
   	            ,location Varchar(10) NOT NULL  
   	            ,bond_mark Varchar(1) NULL  
   	            ,create_by Varchar(20) NOT NULL  
   	            ,bto_id_receive Int NOT NULL  
   	            ,qty_persale Int NULL  
   	            ,id_iqcmaster Int NULL  
   	            ,source_id Int NULL  
   	            ,quantity Decimal(14, 2) NULL  
   	            ,id_shipment Int NULL  
   	            ,id_admreason Int NULL  
)


/*----------------------------------------------------------------------------------------------------
[ 3.Data Prepare (Only INSERT/Update #Temp Table ]
*/----------------------------------------------------------------------------------------------------

-------1. #expect_receive, #expect_received, #expect_received_extension-------------------------------

    EXEC zp_getslipno @id_admslip_expic ,@dt_today ,@exp_no OUTPUT
 --SELECT '@exp_no' = @exp_no

   INSERT intO #expect_receive(
                id_admcomp ,id_admslip ,id_admfacility_apply ,id_admfacility_receive
			   ,id_business_partner ,id_applier ,cost_id ,id_rate_type ,id_paymenterm ,id_priceterm
			   ,receive_type ,expect_receive_no ,source_code ,source_id ,dt_apply
			   ,dt_receiveschedule ,currency ,amt_receive ,status_receive ,dt_create ,create_by
			   ,ref_po_no ,id_admcomp_FROM ,id_business_partner_order
)
   SELECT id_admcomp                = @id_admcomp --xxxx
         ,id_admslip                = @id_admslip_expic --xxxx
         ,id_admfacility_apply      = 0 --xxxx
         ,id_admfacility_receive    = 1 --xxxx
         ,id_business_partner       = a.id_vendor
         ,id_applier                = @id_admuser
         ,cost_id                   = @cost_id
         ,id_rate_type              = 0 
         ,id_paymenterm             = 0 
         ,id_priceterm              = 0 
         ,receive_type              = 0 
         ,expect_receive_no         = @exp_no --TBD
         ,source_code               = 'CS'
	     ,source_id                 = a.id_Gedi_preasn_head
         ,dt_apply                  = a.dt_create
         ,dt_receiveschedule        = a.dt_need
         ,currency                  = b.currency --TBD Gedi_preasn_head.currency
         ,amt_receive               = 0 --Gedi_preasn_detail.qty_received????
		 ,status_receive            = 1
         ,dt_create                 = @dt_today
         ,create_by                 = @user_id --xxxx
         ,ref_po_no                 = a.delivery_no
         ,id_admcomp_FROM           = 2 --xxxx
         ,id_business_partner_order = a.id_vendor
     FROM #tmp_Gedi_preasn_hub a with(nolock)
         ,vendor b with(nolock)
    WHERE a.id_vendor = b.id_vendor
	  AND a.id_Gedi_preasn_head = @id_Gedi_preasn_head
      AND b.stat_void = 0
	GROUP BY a.id_vendor
	        ,a.id_Gedi_preasn_head
			,a.dt_create
			,a.dt_need
			,a.delivery_no
			,b.currency

 --SELECT '1??' = '#expect_receive', * FROM #expect_receive


   SELECT @exp_admreason = min(admslip_reason .id_admslip_reason)
     FROM admslip_reason admslip_reason  
	     ,admslip 
    WHERE admslip_reason.id_admslip_reason_group = admslip.id_admslip_reason_group
      AND admslip.id_admslip = @id_admslip_expic
      AND admslip_reason.stat_void = 0    
      AND admslip_reason.stat_active = 1
 --SELECT '@exp_admreason ' = @exp_admreason 

    INSERT intO #expect_received(
                 id_expect_receive ,source_id ,id_icim_comp ,id_icstkroom 
			    ,qty_expect_receive ,qty_received ,qty_pass ,qty_iqc ,qty_reject ,up ,um 
			    ,id_admreason ,status_received ,dt_create ,create_by ,dt_schedule ,id_icim_comp_order
                ,part_no ,partners_reference_no ,model_no ,description ,receive_iqc_type
)
    SELECT id_expect_receive     = d.id_expect_receive
          ,source_id             = a.id_Gedi_preasn_dn
          ,id_icim_comp          = c.id_icim_comp
          ,id_icstkroom          = @id_icstockroom
          ,qty_expect_receive    = a.qty_received
          ,qty_received          = a.qty_received
          ,qty_pass              = 0
          ,qty_iqc               = a.qty_received
          ,qty_reject            = 0
          ,up                    = a.up
          ,um                    = a.unit_meas
          ,id_admreason          = @exp_admreason --OK
		  ,status_received       = 1
          ,dt_create             = @dt_today
          ,create_by             = @user_id 
          ,dt_schedule           = d.dt_receiveschedule
          ,id_icim_comp_order    = b.id_icim_comp
          ,part_no               = b.part_no
          ,partners_reference_no = ''
          ,model_no              = c.model_no
          ,description           = a.descrip
		  ,receive_iqc_type      = a.iqc_type
      FROM #tmp_Gedi_preasn_hub a with(nolock)
          ,icim_comp b with(nolock)
		  ,icim_sale c with(nolock)
          ,#expect_receive d with(nolock)
		  ,admcomp f with(nolock)
     WHERE a.id_Gedi_preasn_head = @id_Gedi_preasn_head
	   AND a.buyer_part_no = b.part_no 
	   AND b.id_icim_comp = c.id_icim_comp
	   AND b.id_admcomp = f.id_admcomp
	   AND a.delivery_no = d.ref_po_no
	   AND b.stat_void = 0 -- AND e.stat_void = 0
	   AND f.stat_isheadquarter = 1 AND f.stat_active = 1

   SELECT @id_icim_comp = id_icim_comp FROM #expect_received
 --SELECT '2??' = '#expect_received', * FROM #expect_received


-------2. #receive_invoice, #receive, #received, #received_extension----------------------------------

    EXEC @id_admslip_rcinv = zp_get_next_admslip @id_admcomp, @id_admslip_expic, 'RCV_INV'
 --SELECT '@id_admslip_rcinv' = @id_admslip_rcinv 
    EXEC zp_getslipno @id_admslip_rcinv ,@dt_today ,@rcv_no OUTPUT
 --SELECT '@rcv_no' = @rcv_no

   INSERT intO #receive_invoice(
                id_vendor ,amt_invoice ,amt_tax ,invoice_type ,tax_type ,receive_no ,create_by
               ,dt_create ,receive_type ,dt_receive_invoice ,delivery_no ,id_admslip ,ref_id ,buf_no
)
   SELECT id_vendor          = a.id_business_partner
         ,amt_invoice        = 0
         ,amt_tax            = 0
         ,invoice_type       = 0
         ,tax_type           = 0
		 ,receive_no         = @rcv_no --TBD
		 ,create_by          = @user_id 
		 ,dt_create          = @dt_today  
         ,receive_type       = 2 --xxxx
         ,dt_receive_invoice = @dt_today
		 ,delivery_no        = @dn_no
         ,id_admslip         = @id_admslip_rcinv
         ,ref_id             = a.id_expect_receive
		 ,buf_no             = '' --TBD ictr.apply_no
     FROM #expect_receive a with(nolock)
		 ,admuser b with(nolock)
    WHERE a.id_applier = b.id_admuser
	  
 --SELECT '3??' = '#receive_invoice', * FROM #receive_invoice


   INSERT intO #receive(
                id_expect_receive ,id_expect_received ,id_admcomp ,id_admslip ,id_admfacility_apply
 			   ,id_admfacility_receive ,cost_id ,id_business_partner ,id_receiver
 			   ,id_rate_type ,id_paymenterm ,id_priceterm ,receive_type ,receive_no
               ,source_code ,source_no ,source_id ,dt_received ,invoice_no ,currency ,amt_receive 
			   ,status_receive ,dt_create ,create_by ,id_ictr ,id_accounting_reference
			   ,bto_id_stockroom ,bto_id_ictr ,iccrm_no ,print_counter ,vendor_deliver_no
               ,id_receive_invoice ,id_icim_comp ,qty_receive ,qty_inspect ,qty_reject ,model_no 
			   ,descrip ,receive_iqc_type ,part_no ,id_admcomp_FROM ,id_business_partner_order  
)
   SELECT id_expect_receive         = a.id_expect_receive
         ,id_expect_received        = b.id_expect_received
         ,id_admcomp                = a.id_admcomp
         ,id_admslip                = a.id_admslip
         ,id_admfacility_apply      = a.id_admfacility_apply
         ,id_admfacility_receive    = a.id_admfacility_receive
         ,cost_id                   = a.cost_id
         ,id_business_partner       = a.id_business_partner
         ,id_receiver               = a.id_applier
         ,id_rate_type              = a.id_rate_type
         ,id_paymenterm             = a.id_paymenterm
         ,id_priceterm              = a.id_priceterm   
         ,receive_type              = a.receive_type 
         ,receive_no                = '' --TBD --receive_invoice.receive_no + '_' +'1..' @rcinv_no
         ,source_code               = a.source_code
         ,source_no                 = 0
         ,source_id                 = b.source_id
         ,dt_received               = @dt_today
         ,invoice_no                = ''
         ,currency                  = a.currency
         ,amt_receive               = a.amt_receive
		 ,status_receive            = 1
         ,dt_create                 = @dt_today
         ,create_by                 = b.create_by  
         ,id_ictr                   = 0   
         ,id_accounting_reference   = 0
         ,bto_id_stockroom          = 0    
         ,bto_id_ictr               = 0
         ,iccrm_no                  = ''
         ,print_counter             = 0   
         ,vendor_deliver_no         = 0  
         ,id_receive_invoice        = c.id_receive_invoice
         ,id_icim_comp              = b.id_icim_comp
         ,qty_receive               = b.qty_received
         ,qty_inspect               = b.qty_received
         ,qty_reject                = 0
         ,model_no                  = b.model_no
         ,descrip                   = b.description
		 ,receive_iqc_type          = b.receive_iqc_type
         ,part_no                   = b.part_no
         ,id_admcomp_FROM           = a.id_admcomp_FROM
         ,id_business_partner_order = a.id_business_partner_order
     FROM #expect_receive a with(nolock)
	     ,#expect_received b with(nolock)
		 ,#receive_invoice c with(nolock)
    WHERE a.id_expect_receive = b.id_expect_receive
	  AND b.id_expect_receive = c.ref_id

 --SELECT '4??' = '#receive', * FROM #receive
 

  -- Re-dispatch the receive_no at Table -- receive
  UPDATE #receive
     SET receive_no =  LTRIM(RTRIM(@rcv_no)) + '-' + LTRIM(RTRIM(CONVERT(VARCHAR(3),id_receive)))
    FROM #receive

    EXEC @id_admslip_rcvic = zp_get_next_admslip @id_admcomp, @id_admslip_expic, 'RCV'
 --SELECT '@id_admslip_rcvic' = @id_admslip_rcvic

    EXEC @rcv_admreason = zp_get_next_admreason @id_admcomp, @id_admslip_expic, @exp_admreason,'RCV' 
 --SELECT '@rcv_admreason' = @rcv_admreason 

    EXEC @id_glsubject_db = zp_pub_get_dr_subject @id_admslip_rcvic,@rcv_admreason,@id_icim_comp,1,1
    EXEC @id_glsubject_cr = zp_pub_get_cr_subject @id_admslip_rcvic,@rcv_admreason,@id_icim_comp,1,1
 --SELECT '@id_glsubject_db' = @id_glsubject_db, '@id_glsubject_cr' = @id_glsubject_cr

   INSERT intO #received(
                id_receive ,id_expect_received ,id_icstkroom ,source_id ,id_icim_comp
 			   ,quantity ,qty_pass ,qty_iqc ,qty_reject ,qty_un_receive ,up ,um
			   ,id_admreason ,amt_local_ap ,dt_create ,create_by ,id_glsubject_db ,subject_no_db 
               ,id_glsubject_cr ,subject_no_cr ,id_apinv ,up_inv ,id_iqcmaster ,qty_inv
			   ,up_local_cost ,up_var_inv ,rate_var_inv ,id_glsubject_ppvup ,id_glsubject_ppvrate
			   ,id_admslip ,currency ,cost_id ,location ,stat_expic ,id_icim_comp_order
			   ,rec_rate ,part_no ,model_no ,description ,receive_iqc_type
)
   SELECT id_receive            = a.id_receive
         ,id_expect_received    = a.id_expect_received
         ,id_icstkroom          = @id_icstockroom 
         ,source_id             = c.id_Gedi_preasn_dn
         ,id_icim_comp          = a.id_icim_comp
         ,quantity              = a.qty_receive
         ,qty_pass              = 0
         ,qty_iqc               = a.qty_receive
         ,qty_reject            = 0
         ,qty_un_receive        = 0
         ,up                    = c.up
         ,um                    = c.unit_meas
         ,id_admreason          = @rcv_admreason --TBD
         ,amt_local_ap          = 0  
         ,dt_create             = @dt_today
         ,create_by             = a.create_by
         ,id_glsubject_db       = @id_glsubject_db --TBD
         ,subject_no_db         = 0 --TBD
         ,id_glsubject_cr       = @id_glsubject_cr --TBD
         ,subject_no_cr         = 0 --TBD
         ,id_apinv              = 0 
         ,up_inv                = 0.000000
         ,id_iqcmaster          = 0
         ,qty_inv               = 0
         ,up_local_cost         = 0.000000
         ,up_var_inv            = 0.00
         ,rate_var_inv          = 0.00
         ,id_glsubject_ppvup    = 0 --????
         ,id_glsubject_ppvrate  = 0 --????
         ,id_admslip            = @id_admslip_rcvic 
         ,currency              = a.currency
         ,cost_id               = a.cost_id
         ,location              = NULL
         ,stat_expic            = 1 --????
         ,id_icim_comp_order    = a.id_icim_comp
         ,rec_rate              = 0.00000000 --????
         ,part_no               = a.part_no
         ,model_no              = a.model_no
         ,description           = c.descrip
         ,receive_iqc_type      = a.receive_iqc_type
     FROM #receive a with(nolock)
		 ,#tmp_Gedi_preasn_hub c with(nolock)
	WHERE a.part_no = c.buyer_part_no

 --SELECT '5??' = '#received', * FROM #received


-------3. #ictr, #ictrd-------------------------------------------------------------------------------

    EXEC @id_admslip_ictr = zp_get_next_admslip @id_admcomp, @id_admslip_expic, 'RCV'
 --SELECT '@id_admslip_ictr' = @id_admslip_ictr
    EXEC zp_getslipno @id_admslip_ictr ,@dt_today ,@ictr_no OUTPUT
 --SELECT '@ictr_no' = @ictr_no

   INSERT intO #ictr(
                id_admcomp ,id_admslip ,id_admuser_applier ,id_admuser_processer ,cost_id 
               ,ref_no ,source_code ,id_reference ,id_project ,id_glvh ,currency ,id_rate_type
               ,dt_exchange ,tran_type ,apply_no ,dt_apply ,dt_process ,create_by
)
   SELECT id_admcomp           = @id_admcomp
         ,id_admslip           = @id_admslip_ictr
         ,id_admuser_applier   = @id_admuser
         ,id_admuser_processer = @id_admuser
         ,cost_id              = @cost_id
         ,ref_no               = @rcv_no --TBD --receive_invoice.receive_no
         ,source_code          = 'CS'
         ,id_reference         = a.id_receive_invoice --(SELECT top 1 id_receive FROM #receive)
         ,id_project           = 0
         ,id_glvh              = 0
         ,currency             = b.currency
         ,id_rate_type         = b.id_rate_type
         ,dt_exchange          = getdate()
         ,tran_type            = 'EXPIC'
         ,apply_no             = @dn_no --TBD
         ,dt_apply             = getdate()
         ,dt_process           = getdate()
         ,create_by            = a.create_by
     FROM #receive_invoice a with(nolock)
	     ,#expect_receive b with(nolock)
	WHERE a.ref_id = b.id_expect_receive

 --SELECT '6??' = '#ictr', * FROM #ictr


   SELECT @id_icstockroom = a.id_icstockroom 
     FROM icstockroom a with(nolock)
	     ,#tmp_Gedi_preasn_hub b with(nolock)
    WHERE a.id_vendor = b.id_vendor
	  AND b.id_Gedi_preasn_head = @id_Gedi_preasn_head
	  AND a.stat_void = 0 AND a.stat_active = 1

   INSERT intO #ictrd(
   	            id_icim_comp ,id_ictr ,id_icstockroom ,id_reference ,qty_apply ,qty_actual 
   	           ,up ,up_cost ,sign ,partno ,descrip ,id_admslip_reason ,id_glsubject_db 
   	           ,id_glsubject_cr ,location ,bond_mark ,create_by ,bto_id_receive
)
   SELECT id_icim_comp      = a.id_icim_comp
   	     ,id_ictr           = b.id_ictr
   	     ,id_icstockroom    = @id_buffer  --OK
   	     ,id_reference      = a.id_received
   	     ,qty_apply         = a.quantity
   	     ,qty_actual        = a.quantity
   	     ,up                = a.up
   	     ,up_cost           = 0 --????
   	     ,sign              = 1
   	     ,partno            = a.part_no
   	     ,descrip           = a.description
   	     ,id_admslip_reason = @rcv_admreason --TBD
   	     ,id_glsubject_db   = @id_glsubject_db  --TBD
   	     ,id_glsubject_cr   = @id_glsubject_cr --TBD
		 ,location          = ''
   	     ,bond_mark         = '' --????
   	     ,create_by         = a.create_by
   	     ,bto_id_receive    = 0
     FROM #received a with(nolock)
         ,#ictr b with(nolock)
    WHERE b.apply_no = @dn_no

 --SELECT '7??' = '#ictrd', * FROM #ictrd
 --RETURN

/*----------------------------------------------------------------------------------------------------
[ 4.Data VerIFy ]
*/----------------------------------------------------------------------------------------------------

 -- Get @adm_table & @adm_id        
   SELECT @adm_table = 'expect_receive,expect_received,receive_invoice,receive,received,ictr,ictrd'
         ,@adm_id    = 'id_expect_receive,id_expect_received,id_receive_invoice,id_receive,id_received,id_ictr,id_ictrd'
         ,@booking_id = '#expect_receive,#expect_received,#receive_invoice,#receive,#received,#ictr,#ictrd'
       
    EXEC zp_frame_GetIdentityvalue_multi_new @adm_table, @adm_id, @booking_id, @output OUTPUT

 --SELECT '@output' = CAST(@output AS XML)

   SELECT @id_expect_receive   = dbo.fn_find_tag ( @output, 'id_expect_receive' )
         ,@id_expect_received  = dbo.fn_find_tag ( @output, 'id_expect_received' )
         ,@id_receive_invoice  = dbo.fn_find_tag ( @output, 'id_receive_invoice' )        
         ,@id_receive          = dbo.fn_find_tag ( @output, 'id_receive' )        
         ,@id_received         = dbo.fn_find_tag ( @output, 'id_received' )        
         ,@id_ictr             = dbo.fn_find_tag ( @output, 'id_ictr' )        
		 ,@id_ictrd            = dbo.fn_find_tag ( @output, 'id_ictrd' )              


/*----------------------------------------------------------------------------------------------------
[ 5.Data Transaction ]
*/----------------------------------------------------------------------------------------------------
--/*
-- 1. INSERT intO expect_receive----------------------------------------------------------------------
   IF ISNULL(@id_expect_receive, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
                  ,@ERROR_MSG  = '5.1.2 - Get expect_receive identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END

   INSERT intO expect_receive(
               id_expect_receive ,id_admcomp ,id_admslip ,id_admfacility_apply ,id_admfacility_receive
              ,id_business_partner ,id_applier ,cost_id ,id_rate_type ,id_paymenterm ,id_priceterm
              ,receive_type ,expect_receive_no ,source_code ,source_id ,dt_apply
              ,dt_receiveschedule ,currency ,amt_receive ,status_receive ,dt_create ,create_by 
			  ,ref_po_no ,id_admcomp_FROM ,id_business_partner_order
)
   SELECT id_expect_receive + @id_expect_receive 
         ,id_admcomp 
		 ,id_admslip 
		 ,id_admfacility_apply 
         ,id_admfacility_receive 
		 ,id_business_partner 
		 ,id_applier 
		 ,cost_id 
		 ,id_rate_type 
		 ,id_paymenterm 
         ,id_priceterm 
		 ,receive_type 
		 ,expect_receive_no 
		 ,source_code 
		 ,source_id 
		 ,dt_apply
         ,dt_receiveschedule 
		 ,currency 
		 ,amt_receive 
		 ,status_receive 
		 ,dt_create 
		 ,create_by 
		 ,ref_po_no 
		 ,id_admcomp_FROM 
		 ,id_business_partner_order
     FROM #expect_receive

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to expect_receive Failed !!', 16, 101)
       END

-- 2. INSERT intO expect_received + expect_receive_extension------------------------------------------
   IF ISNULL(@id_expect_received, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
                  ,@ERROR_MSG  = '5.1.2 - Get expect_received + expect_receive_extension identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END

    INSERT intO expect_received(
                id_expect_received ,id_expect_receive ,source_id ,id_icim_comp ,id_icstkroom 
			   ,qty_expect_receive ,qty_received ,qty_pass ,qty_iqc ,qty_reject ,up ,um 
			   ,id_admreason ,status_received ,dt_create ,create_by ,dt_schedule ,id_icim_comp_order
)
    SELECT id_expect_received + @id_expect_received 
          ,id_expect_receive + @id_expect_receive 
          ,source_id
          ,id_icim_comp 
          ,id_icstkroom 
          ,qty_expect_receive 
          ,qty_received 
          ,qty_pass 
          ,qty_iqc 
          ,qty_reject 
          ,up 
          ,um 
          ,id_admreason
		  ,status_received 
          ,dt_create 
          ,create_by 
          ,dt_schedule 
          ,id_icim_comp_order
     FROM #expect_received

   INSERT intO expect_received_extension(
               id_expect_received ,part_no ,model_no ,description
)
   SELECT id_expect_received + @id_expect_received  ,part_no ,model_no ,description
     FROM #expect_received

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to expect_received + expect_receive_extension Failed !!', 16, 101)
       END

-- 3. INSERT intO receive_invoice---------------------------------------------------------------------
   IF ISNULL(@id_receive_invoice, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
                  ,@ERROR_MSG  = '5.1.2 - Get receive_invoice identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END

   INSERT intO receive_invoice(
               id_receive_invoice ,id_vendor ,amt_invoice ,amt_tax ,invoice_type ,tax_type ,receive_no
              ,create_by ,dt_create ,receive_type ,dt_receive_invoice ,delivery_no ,id_admslip ,ref_id
			  ,buf_no
)
   SELECT id_receive_invoice + @id_receive_invoice 
         ,id_vendor 
		 ,amt_invoice 
		 ,amt_tax 
		 ,invoice_type
         ,tax_type 
		 ,receive_no 
		 ,create_by 
		 ,dt_create 
		 ,receive_type 
		 ,dt_receive_invoice 
		 ,delivery_no 
		 ,id_admslip 
		 ,ref_id + @id_expect_receive 
		 ,buf_no
     FROM #receive_invoice

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to receive_invoice Failed !!', 16, 101)
       END

-- 4. INSERT intO receive-----------------------------------------------------------------------------
   IF ISNULL(@id_receive, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
              ,@ERROR_MSG  = '5.1.2 - Get receive identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END
	   
   INSERT intO receive(
               id_receive ,id_expect_receive ,id_admcomp ,id_admslip ,id_admfacility_apply
			  ,id_admfacility_receive ,cost_id ,id_business_partner ,id_receiver ,id_rate_type 
              ,id_paymenterm ,id_priceterm ,receive_type ,receive_no ,source_code ,source_no
			  ,source_id ,dt_received ,invoice_no ,currency ,amt_receive ,status_receive ,dt_create 
			  ,create_by ,id_ictr ,id_accounting_reference ,bto_id_stockroom ,bto_id_ictr ,iccrm_no 
			  ,print_counter ,vendor_deliver_no ,id_receive_invoice ,id_icim_comp ,qty_receive 
			  ,qty_inspect ,qty_reject ,model_no ,descrip ,part_no ,id_admcomp_FROM 
			  ,id_business_partner_order,status_sfis
)
   SELECT id_receive + @id_receive 
         ,id_expect_receive + @id_expect_receive 
         ,id_admcomp 
         ,id_admslip 
         ,id_admfacility_apply 
         ,id_admfacility_receive 
         ,cost_id 
         ,id_business_partner 
         ,id_receiver 
         ,id_rate_type 
         ,id_paymenterm 
         ,id_priceterm 
         ,receive_type 
         ,receive_no 
         ,source_code 
         ,source_no  
         ,source_id 
         ,dt_received 
         ,invoice_no 
         ,currency 
         ,amt_receive
		 ,status_receive  
         ,dt_create 
         ,create_by 
         ,id_ictr
         ,id_accounting_reference 
         ,bto_id_stockroom 
         ,bto_id_ictr 
         ,iccrm_no 
         ,print_counter 
         ,vendor_deliver_no 
         ,id_receive_invoice + @id_receive_invoice 
         ,id_icim_comp 
         ,qty_receive 
         ,qty_inspect 
         ,qty_reject ,model_no ,descrip 
         ,part_no 
         ,id_admcomp_FROM 
         ,id_business_partner_order
		 ,status_sfis = 1
     FROM #receive

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to receive Failed !!', 16, 101)
       END

-- 5. INSERT intO received + received_extension-------------------------------------------------------
   IF ISNULL(@id_received, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
              ,@ERROR_MSG  = '5.1.2 - Get received + received_extension identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END

   INSERT intO received(
               id_received ,id_receive ,id_expect_received ,id_icstkroom ,source_id ,id_icim_comp
 			  ,quantity ,qty_pass ,qty_iqc ,qty_reject ,qty_un_receive ,up ,um
			  ,id_admreason ,amt_local_ap ,dt_create ,create_by ,id_glsubject_db ,subject_no_db 
              ,id_glsubject_cr ,subject_no_cr ,id_apinv ,up_inv ,id_iqcmaster ,qty_inv
		      ,up_local_cost ,up_var_inv ,rate_var_inv ,id_glsubject_ppvup ,id_glsubject_ppvrate
		      ,id_admslip ,currency ,cost_id ,location ,stat_expic ,id_icim_comp_order ,rec_rate
)
   SELECT id_received + @id_received 
         ,id_receive + @id_receive 
		 ,id_expect_received + @id_expect_received
         ,id_icstkroom 
		 ,source_id 
		 ,id_icim_comp 
		 ,quantity 
		 ,qty_pass 
		 ,qty_iqc 
		 ,qty_reject 
		 ,qty_un_receive 
		 ,up 
		 ,um 
		 ,id_admreason 
		 ,amt_local_ap 
		 ,dt_create 
		 ,create_by 
		 ,id_glsubject_db 
		 ,subject_no_db 
		 ,id_glsubject_cr 
		 ,subject_no_cr 
		 ,id_apinv 
		 ,up_inv 
		 ,id_iqcmaster 
		 ,qty_inv 
		 ,up_local_cost 
		 ,up_var_inv 
		 ,rate_var_inv 
		 ,id_glsubject_ppvup 
		 ,id_glsubject_ppvrate 
		 ,id_admslip 
		 ,currency 
		 ,cost_id 
		 ,location 
		 ,stat_expic 
		 ,id_icim_comp_order 
		 ,rec_rate 
     FROM #received

   INSERT intO received_extension(
               id_received ,part_no ,model_no ,description ,receive_iqc_type
)
   SELECT id_received + @id_received ,part_no ,model_no ,description ,receive_iqc_type
     FROM #received

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to received + received_extension Failed !!', 16, 101)
       END

-- 6. INSERT intO ictr--------------------------------------------------------------------------------
   IF ISNULL(@id_ictr, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
                  ,@ERROR_MSG  = '5.1.2 - Get ictr identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END

   INSERT intO ictr(
               id_ictr ,id_admcomp ,id_admslip ,id_admuser_applier ,id_admuser_processer ,cost_id 
              ,ref_no ,source_code ,id_reference ,id_project ,id_glvh ,currency ,id_rate_type
              ,dt_exchange ,tran_type ,apply_no ,dt_apply ,dt_process ,create_by
)
   SELECT id_ictr + @id_ictr
         ,id_admcomp 
		 ,id_admslip 
		 ,id_admuser_applier 
		 ,id_admuser_processer 
		 ,cost_id 
         ,ref_no 
		 ,source_code 
		 ,id_reference + @id_receive_invoice
		 ,id_project 
		 ,id_glvh 
		 ,currency 
		 ,id_rate_type
         ,dt_exchange 
		 ,tran_type 
		 ,apply_no = @ictr_no
		 ,dt_apply 
		 ,dt_process 
		 ,create_by
     FROM #ictr

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to ictr Failed !!', 16, 101)
       END

-- 7. INSERT intO ictrd-------------------------------------------------------------------------------
   IF ISNULL(@id_ictrd, -99) < 0
      BEGIN
            SELECT @RTN_STATUS = 101
                  ,@ERROR_MSG  = '5.1.2 - Get ictrd identity value failed !!'

         RAISERROR (@ERROR_MSG, 16, @RTN_STATUS)
       END

   INSERT intO ictrd(
   	           id_ictrd ,id_icim_comp ,id_ictr ,id_icstockroom ,id_reference ,qty_apply ,qty_actual
			  ,up ,up_cost ,sign ,partno ,descrip ,id_admslip_reason ,id_glsubject_db 
   	          ,id_glsubject_cr ,location ,bond_mark ,create_by ,bto_id_receive
)
   SELECT id_ictrd + @id_ictrd
         ,id_icim_comp
		 ,id_ictr + @id_ictr 
		 ,id_icstockroom 
		 ,id_reference + @id_received 
         ,qty_apply 
         ,qty_actual
         ,up 
         ,up_cost 
         ,sign 
         ,partno 
		 ,descrip 
		 ,id_admslip_reason 
		 ,id_glsubject_db 
		 ,id_glsubject_cr 
		 ,location 
		 ,bond_mark 
		 ,create_by 
		 ,bto_id_receive
     FROM #ictrd

   IF @@ERROR <> 0
      BEGIN
            RAISERROR('5.1.3 - Error, INSERT to ictrd Failed !!', 16, 101)
       END

-- 8. update Gedi_preasn_dn---------------------------------------------------------------------------
   UPDATE Gedi_preasn_dn
      SET qty_dn_receive = #received.quantity
		 ,dt_update = getdate()
		 ,stat_receive = 2		 
	 FROM #received
	     ,#tmp_Gedi_preasn_hub
		 ,Gedi_preasn_dn
	WHERE #tmp_Gedi_preasn_hub.dn_no = @dn_no
	  AND #tmp_Gedi_preasn_hub.id_Gedi_preasn_dn = #received.source_id 
     AND Gedi_preasn_dn.id_Gedi_preasn_dn  = #tmp_Gedi_preasn_hub.id_Gedi_preasn_dn 
	 
   UPDATE Gedi_preasn_head
      SET stat_doc  = 40
	     ,update_by = 'JIT_Receive'
		 ,dt_update = getdate()	 
	WHERE Gedi_preasn_head.id_Gedi_preasn_head  = @id_Gedi_preasn_head


   INSERT intO deef_log(
               source_type
			  ,content1
			  ,content2
			  ,content3
			  ,content4
			  ,content5
	          ,content6 
			  ,dt_create
)
   SELECT source_type = 'mvc_rec'
		  ,content1   = '[Start]'
		  ,content2   = convert(varchar(20),@dt_today,120)
		  ,content3   = '[End]'
		  ,content4   = convert(varchar(20),getdate(),120)
          ,content5   = 'sp_name:mvc_receive_insert'
	      ,content6   = @id_Gedi_preasn_head
		  ,dt_create  = @dt_today

--*/
------------------------------------------------------------------------------------------------------
      
   SELECT @stat_b2b_next = 1  
   SELECT @actioncode    = CASE WHEN @stat_b2b_next = 1 THEN 'A' ELSE 'P' END
	 


   SELECT @RTNPARAMETER = ''
	 
   SELECT @RTNPARAMETER = @RTNPARAMETER
                        + '<stat_b2b_next>' 
		                +    CONVERT(VARCHAR(10),@stat_b2b_next) -- Do not next 
					    + '</stat_b2b_next>'  
                        + '<actioncode>' + @actioncode + '</actioncode>' 

------------------------------------------------------------------------------------------------------

      SET @INSERT_output = (SELECT receive_no= ISNULL(RTRIM(LTRIM(receive_no)),'')
	                          FROM #receive receive for xml auto, elements)

   SELECT @XML_OUTPUT = CAST('<rowset></rowset>'
                            + '<rtnparameter>'
							     + ISNULL(@INSERT_output,'')
                                 + ISNULL(@RTNPARAMETER,'') 
                            + '</rtnparameter>' AS XML)

   SELECT @ERROR_MSG = 'Success !!!'
	
 TransEnd:      

------------------------------------------------------------------------------------------------------

  COMMIT TRANSACTION

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
                               +    '<rtncode>'
                               +       '<code>' + LTRIM(str(@RTN_STATUS)) + '</code>'
                               +       '<msg>'  + @ERROR_MSG  + '</msg>'
                               +    '</rtncode>'    
                               +    CAST ( @XML_OUTPUT AS nvarchar(MAX) )
                               +    ISNULL(@wf_msg, '')      --> Work Flow Use
                               +    ISNULL(@inputstring, '') --> Work Flow Use
                               +'</outputstring>' AS XML )

     EXEC SourceDB.dbo.zp_GlobalSB_Set_MSG @XML_OUTPUT
  --SELECT '@XML_OUTPUT' = @XML_OUTPUT

    RETURN @RTN_STATUS

Exception:

    SELECT @XML_OUTPUT = CAST ( '<outputstring>'
                               +    '<rtncode>'
                               +       '<code>' + LTRIM(str(@RTN_STATUS)) + '</code>'
                               +       '<msg>'  + @ERROR_MSG  + '</msg>'
                               +    '</rtncode>'    
                               +    CAST ( @XML_OUTPUT AS nvarchar(MAX) )
                               +    ISNULL(@wf_msg, '')      --> Work Flow Use
                               +    ISNULL(@inputstring, '') --> Work Flow Use
                               +'</outputstring>' AS XML )

    EXEC SourceDB.dbo.zp_GlobalSB_Set_MSG @XML_OUTPUT
 --SELECT '@XML_OUTPUT' = @XML_OUTPUT

   SELECT @DOC_OUTPUT = CAST( @XML_OUTPUT AS nvarchar(MAX) )

RAISERROR ('<ERROR>PROC:[%d]%s CODE:%d</ERROR>%s)' ,@ERROR_SEVERITY ,@RTN_STATUS ,@PROCLEVEL ,@PROCNAME ,@RTN_STATUS ,@DOC_OUTPUT )

GO


