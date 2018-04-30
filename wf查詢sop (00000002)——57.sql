
--查詢三天內 WorkFlow 的執行狀況及資料
/*--
	若要將wf給cancel掉需要到WT004以及mail底下的cancel指令==>會將整筆wf資料刪除
	如果要刪除wf的某一步驟僅需update wf_process 的 stage_status 為 99 以及 dt_completed = Getdate() + mail底下的cancel指令

	如果塞入 edi_process_pool但是未產生wf，可能原因:
	1.他會抓取workflow_start內的center_duns_no決定產生在哪個區域
	2.若center_duns_no沒有，則會抓取wt001上設定的duns_no
	3.若1.2都沒有，則會抓取所得到的duns_no_to
	4.若上述的都沒有，就會抓取觸發的本機端


--*/
--SELECT dt_request,b.stage_name,dt_completed,a.stage_status,a.* 
--FROM wfDB.dbo.wf_process a with(nolocK) , wfDB.dbo.wf_stage b with(nolock) 
--WHERE a.id_wf_stage = b.id_wf_stage
--AND a.id_wf_doc in ('1075854','1075855','1075856','1075867',
--'1075868','1075869','1075857','1075858',
--'1075860','1075862','1075864','1075873')-- 1075856
----AND stage_status < 99
--order by id_wf_doc

/*

SELECT * FROM ftp_information
--update ftp_information set remark = 'This is for Juniper IBP -- test : 64.43.237.233 ',ftp_server = '64.43.237.233'
WHERE job_name = 'Juniper_IBP'

*/

      use wfDB
   SELECT wf_doc.id_admcomp
	     ,wf_doc.dt_create
	     ,wf_process.dt_request
	     ,dt_completed
	     ,wf_process.id_wf_process
	     ,wf_doc.id_wf_doc
	     ,wf_doc.doc_no
	     ,wf_stage.stage_name
	     ,wf_doc.doc_status
	     ,wf_process.stage_status
       --,doc_info = CAST(wf_doc.doc_info AS XML)
	   --,wf_doc_doc_b2b_xml = wf_doc.doc_b2b_xml
	     ,wf_process_doc_b2b_xml = wf_process.doc_b2b_xml
	     ,wf_doc.doc_mainarea_xml
	     ,wf_doc.flow_code
	     ,wf_doc.doc_code
	     ,wf_doc.id_reference
	     ,wf_doc.id_request
	     ,wf_doc.doc_applier
       --,wf_process.* 
 --SELECT distinct doc_no, wf_doc.dt_create , wf_doc.doc_status
     FROM wf_doc with(nolock)
         ,wf_process with(nolock)
         ,wf_stage with(nolock)
    WHERE wf_doc.id_wf_doc = wf_process.id_wf_doc
      AND wf_process.id_wf_stage = wf_stage.id_wf_stage
      AND wf_doc.stat_void = 0

    --AND wf_doc.flow_code =  'B2BADQ'
    --AND wf_doc.doc_code= '208'
    --AND wf_doc.dt_create >= '2016-10-28 00:00:00.000' 
    --AND wf_doc.dt_create <= '2016-10-30 23:59:59.999' 
    --AND wf_doc.id_wf_doc='326638'
    --AND wf_doc.doc_no in ('PK16090645' ,'PK16090886' ,'PK16090887' ,'PK16090888' ,'PK16090889','PK16090890','PK16090891','PK16090892' ,'PK16090893' ,'PK16090894' ,'PK16090895')
      AND wf_doc.doc_no like '%B2BADQ-698-0122154535%'
    --AND stage_name='1. zp_Gedi_generate_to_gateway_3A4'
    --AND doc_status=80
    --AND id_admcomp=9
    --AND wf_doc.id_wf_doc=472387
    ORDER BY wf_doc.id_wf_doc, wf_process.id_wf_process,wf_process.dt_request DESC
------------------------------------------------------------------------------------------------------

--若複雜join查詢不到，可以使用單一table來查詢 ==>表示未產生wf_process (資料太多 忙碌時可能發生) 需要詢問平台
SELECT dt_create,dt_complete,* FROM wfDB.dbo.wf_doc with(nolocK) --WHERE doc_no = 'DemAND_Plan_20170119'
WHERE dt_complete is null

/* ***若未產生wf_process，先用查詢到id_wf_doc，把它放入 wfDB.dbo.adm_mq 查詢抓取到id_adm_mq 放入 in / out 中查詢
	1.要看 action_code為wf-root => 若sb_status = 0 表示尚未執行，可至地球查看wt001上的wait doc(需等待的B2B筆數)是否有設定值
	2.若in 有產生action_code為wf-root 且 sb_status = 1 但是out未產生，則表示可能被kill掉了，可以找Jessica或是手動重跑(只有wf-root可這樣做)
*/	
use wfDB
SELECT * FROM wfDB.dbo.adm_mq WHERE id_wf_doc=1654916
-------------------------------------------------------------------------------------------------------------
--************--
--若步驟卡在call biztalk時，可先去查詢biztalk是否有觸發被送出(下方SQL)
--若沒有觸發SP，且在測試區觸發可以查看執行步驟中的duns_no是否正確(測試區不能為0054)

--=======================================================================================================
--查詢wf與Biztalk回覆狀態(99完成/15)
--wf_bt_queue:由wf出去-->Biztalk
--bt_wf_queue:由Biztalk出去-->wf
SELECT * FROM SourceDB.dbo.wf_bt_queue with(nolock) WHERE pkey = 'D3E8EF57-9A12-44C3-B518-0F8799ED1509' 
SELECT * FROM SourceDB.dbo.bt_wf_queue with(nolock) WHERE pkey = 'D3E8EF57-9A12-44C3-B518-0F8799ED15091'
--=======================================================================================================
--簡易版搜尋
--1.先將ref_no丟入搜尋
--DT300:doc_no like '20160121105650_960070'
--dt_complete內容應與doc_status(完成99/Cancel93/執行中80)一致
SELECT dt_complete,doc_status,* 
----****update a set doc_status = 93 
FROM wfDB.dbo.wf_doc a with(nolock) 
WHERE doc_no like '%B2BADQ-698-0122154535%'
--WHERE flow_code =  'B2BISD' 
--AND dt_complete is not null 
--AND doc_status <> 99 

--2.查詢到值後，將id_wf_doc丟入搜尋
SELECT b.stage_name,a.dt_completed,a.dt_request,stage_status,a.* 
FROM wfDB.dbo.wf_process a with(nolock) , wfDB.dbo.wf_stage b with(nolock) 
WHERE a.id_wf_stage = b.id_wf_stage 
AND a.id_wf_doc = 1654916
--=======================================================================================================
--wf_doc 會塞資料到adm_mq 執行zp = zp_sb_wf_fs 往下一步驟 zp_sb_wfp

use wfDB
SELECT * FROM wfDB.dbo.adm_mq WHERE id_wf_doc = 7146723
----------------------------------------------57---------------------------------------------------------
SELECT * FROM wfDB.dbo.adm_mq with(nolock) WHERE id_wf_process=50870342
--使用id_wf_process去做搜尋

/*
  若當步驟沒有繼續走下去，可先查看Actioncode流程是否有畫
  -->若無: 補畫好流程找到 zp_sb_wfp 將狀態值重新觸發，讓他往下走

*/

SELECT mq_status, *
--UPDATE a SET mq_status = 0 --重新觸發這一步SP
  FROM wfDB.dbo.adm_mq a with(nolock)
WHERE id_wf_process =  50870342 -------------------------------------------------------------------------57
AND mq_targetobj = 'zp_sb_wf_fs'


--update adm_mq set mq_status=0 WHERE id_adm_mq=56525415
--=======================================================================================================
--A. Cancel ********
--(1) WT004 Cancel :update wf_doc&wf_process) -- 變更WF上的狀態值,不會再發Delay ***會刪除WF的流程，讓報表上不會再呈現這筆資了
--(2) Broker Cancel(exec Mail zp_GlobalSB_Cancel) : update sb_queue_out --不讓Broker再觸發(SP不再執行)  ***更改Broker上的狀態值，讓Broker不要再重新觸發

--(*)若有single整合變multi時，要看錯誤產生在哪裡，有產生錯誤的才要Broker Cancel，若有成功跑完只要在WT004刪除WF的流程就好

--B. 重新觸發這一步SP ********
--(1) update adm_mq.mq_status = 0 
	--> 再INSERT 新的sb_queue_in/sb_queue_out ; 使用時機 : SP被KILL沒有收到Resend mail時適用.
--(2) exec Broker Resend (Mail zp_GlobalSB_Resend)  
	--> update sb_queue_in 使其重新執行 ; 使用時機 : SP 執行fail有錯誤訊息,處理完畢後用Resend mail直接執行.

--C. 若Receive EDI 為收到Biztalk所以需要先到Biztalk上做查詢 查詢他的狀態才知道後續如何處理
--查詢wf與Biztalk回覆狀態(99完成/15)
--wf_bt_queue:由wf出去-->Biztalk
--bt_wf_queue:由Biztalk出去-->wf
SELECT * FROM SourceDB.dbo.wf_bt_queue with(nolock) WHERE pkey = '366b3d1c-8d00-4318-bee1-cad1b6453271' 
SELECT * FROM SourceDB.dbo.bt_wf_queue with(nolock) WHERE pkey = '366b3d1c-8d00-4318-bee1-cad1b6453271'
-----Queue in/out 紀錄只保留一天
--=======================================================================================================

--執行本機以外的zp 要在SourceDB 查詢 ex:目前執行MISSQL要搜尋JOYTECH的資料在此查
-- id_reference=id_adm_mq

-- SourceDB
SELECT TOP 20 sb_msg = CAST(sb_msg AS XML), * FROM SourceDB.dbo.sb_queue_in with(nolock) WHERE --action_code = 'wf_B2BBBOM' 
id_reference = 23241879 
ORDER BY dt_create DESC

SELECT TOP 20 sb_msg = CAST(sb_msg AS XML) , * FROM SourceDB.dbo.sb_queue_out with(nolock) WHERE  --action_code = 'wf_B2BBOM'
id_reference = 23241879
--global_id='A2ADA583-9CA2-E311-8077-0024E84BE1DD'
ORDER BY dt_create DESC

--EXEC SourceDB.dbo.zp_GlobalSB_Send 'E5F36A76-9051-E711-80F5-00155D1E1A03'     
--EXEC SourceDB.dbo.zp_GlobalSB_Cancel 'D3E8EF57-9A12-44C3-B518-0F8799ED1509'

/*
case1:若在In產生wf沒有產生wf_B2BXXX，隔了一段時間才產生新的wf與wf_B2BXXX ==>則表示可能第一次產生時被Kill掉了
****若是要刪除ADQ要記得將multi也一併刪除!!!!!!!!!!!!!!!然後將edi_process_pool狀態值做修改!!!!!!!!

--查詢ack table 是否有產生
SELECT top 100 status, * FROM wfDB.dbo.wf_ack_wait (NOLOCK)  WHERE id_wf_doc in (1654916)
 order by dt_start desc

--查詢ACK是否有成功

--STATUS =0 一塞入
--STATUS = 99 成功
--STATUS = 12 --ack broker 執行(5分鐘)
SELECT top 100 status, * FROM wfDB.dbo.wf_ack_wait (NOLOCK) WHERE id_wf_ack_wait in (6232762,6232761,6232760,6232759)

 update wfDB.dbo.wf_ack_wait set status =0,output= null
WHERE id_wf_ack_wait in (6232762,6232761,6232760,6232759)


*/
--執行本機的zp 要在wfDB 查詢 ex:目前執行MISSQL要搜尋MISSQL的資料在此查
/* In ( wf -> wf_B2BXXX ) => Out ( wf -> wf_B2BXXX ) => In (wf_ack ) => Out (wf_ack ) */
-- wfDB
--action_code : wf -> wf_B2BXXX ->wf_ack 
SELECT  sb_msg = CAST(sb_msg AS XML), action_code,sb_status,sb_msg,* 
FROM wfDB.dbo.sb_queue_in with(nolock) WHERE-- action_code = 'wf_B2BBOM' AND dt_create BETWEEN '2012-11-28 10:00:30.567' AND '2012-11-28 11:31:30.567'
 id_reference = 102692974 -------------------------------------------------------------------------------------------------------57
 --global_id='52ACFB16-A3A2-E311-8077-0024E84BE1DD'
ORDER BY dt_create DESC

--action_code : wf -> wf_B2BXXX ->wf_ack 
--IF not exists out.wf_B2BXXX , may be SP killed
SELECT  sb_msg = CAST(sb_msg AS XML) , action_code,* 
FROM wfDB.dbo.sb_queue_out with(nolock) WHERE --action_code = 'wf_B2BBOM' AND dt_create BETWEEN '2012-11-28 10:00:30.567' AND '2012-11-28 11:31:30.567'
id_reference = 102692974 -------------------------------------------------------------------------------------------------------57
ORDER BY dt_create DESC

--EXEC wfDB.dbo.zp_GlobalSB_Send 'FFBF7479-A454-E711-80D9-B8CA3A5EFFDB'     
--EXEC wfDB.dbo.zp_GlobalSB_Cancel 'B57A6458-B6B3-E711-80EC-1418773CE9D5' -------------------------------------------------------------------------------------------------------57

--=======================================================================================================
--B2BDS的部分是從MISSQL的 BROKER送到JOY的 BROKER
--所以要先SELECT MISSQL 的 SOURCE DB 的 OUT 確定資料有從MISSQL到JOY  (STATUS=3 表示完成)
SELECT CAST(message_body as xml),* FROM SourceDB.dbo.GlobalSB_OUT_Q6 WITH(NOLOCK)

--再到 JOY的SOURCE DB 的 INT 確認資料是否還在跑
--(STATUS=0 表示正在跑ZP 或是正在找ZP  STATUS=1 表示在排隊等待ZP)
--假若GlobalSB_IN_Q6的STATUS=0 但是dm_broker_activated_tasks 沒有資料(SPID) 表示資料被KILL掉了

SELECT CAST(message_body as xml),* FROM SourceDB.dbo. GlobalSB_IN_Q6 WITH(NOLOCK)


--現在正在執行的BROKER(spid)
SELECT * FROM sys.dm_broker_activated_tasks  


--=======================================================================================================

-- Broker Log (確認zp 是否真的有執行)要到ZP (一個小時update 資料一次)
SELECT TOP 200 * FROM workTemp.dbo.tmp_sp_info_log with(nolock) WHERE sp_name like '%joyDB.dbo.zp_IntCb2b_collect_to_ship%'order by dt_start desc 

--=======================================================================================================

--查詢ACK 是否有成功執行 狀態值99為執行成功
SELECT top 10 * FROM wfDB.dbo.wf_ack_wait (NOLOCK) WHERE doc_no='2791ce09-6d27-4642-adee-2a96e7d23410' order by dt_start desc
--=======================================================================================================

--Blocked 資料查詢
--ROOT 是檔人的 設定要查詢的時間
SELECT spid,blocked,hostname,loginame,cmd,root,dt_create,script,stat_kill,waittime,mins,program_name
--SELECT * 
FROM workTemp.dbo.tmp_block with(Nolock)
WHERE  root = 'ROOT'
AND dt_create between  '2014-03-07 17:00' AND '2014-03-07 17:30'
order by dt_create

--將ROOT的ID放到Blocked 裡面就可以知道有擋到那些程式

SELECT distinct spid,blocked,hostname,loginame,cmd,root,script,stat_kill,waittime,mins,program_name
FROM workTemp.dbo.tmp_block with(Nolock)
WHERE blocked = 43
AND dt_create between   '2014-03-07 17:00' AND '2014-03-07 17:30'

--=======================================================================================================
--正式區server : srv-biztalk b2b b2b
--測試區server : srv-biztalktest sa !abcd1234

--EDI位置: \\srv-doc\personal\Daily\B2B\backup
--找到EDI文件可以查看第一個值，為EDI的唯一值

USE BizCenter
--=======================================================================================================
--Biztalk 資料
-- All
SELECT JSAP_Action_Log.Message ,
 JSAP_Action_Log.Action_Name,
 JSAP_Action_Log.CreateTime,
 JSAP_Message_Log.DOC_TYPE,
 JSAP_Message_Log.ID_JSAP_Message_Log,
 JSAP_Message_Log.Status,
 JSAP_Message_Log.Message_Number
   FROM BizCenter.dbo.JSAP_Action_Log with(nolock)
      ,BizCenter.dbo.JSAP_Message_Log with(nolock) 
WHERE JSAP_Message_Log.PKey like '%4500181463%' 
   AND JSAP_Message_Log.ID_JSAP_Message_Log = JSAP_Action_Log.ID_JSAP_Message_Log 
   --AND Action_Name = 'OutBound Mapping End'
      --AND Action_Name = 'Send To CMService Start'
      --AND DOC_TYPE = 'PreShip_Cancel'
      AND JSAP_Message_Log.CreateTime > '2017-01-01'
ORDER BY JSAP_Action_Log.CreateTime DESC

-- Get XML
SELECT Message = CAST(JSAP_Action_Log.Message AS XML),
 JSAP_Message_Log.PKey,
 JSAP_Action_Log.Action_Name,
 JSAP_Action_Log.CreateTime,
 --JSAP_Message_Log.CreateTime,
 JSAP_Message_Log.DOC_TYPE,
 JSAP_Message_Log.ID_JSAP_Message_Log,
 JSAP_Message_Log.Status,
 JSAP_Message_Log.Message_Number
   FROM BizCenter.dbo.JSAP_Action_Log with(nolock)
      ,BizCenter.dbo.JSAP_Message_Log with(nolock) 
WHERE JSAP_Message_Log.PKey like '%4500181463%' 
   AND JSAP_Message_Log.ID_JSAP_Message_Log = JSAP_Action_Log.ID_JSAP_Message_Log 
   --AND Action_Name <> 'CMService SendOutBoundMessage Start'
   AND Action_Name = 'OutBound Mapping End'
      --AND Action_Name = 'Receive Error Ack'
      AND JSAP_Message_Log.CreateTime > '2016-02-01'
ORDER BY JSAP_Action_Log.CreateTime DESC
 
-- I282 
SELECT *, Message = CAST(Message AS XML) 
FROM BizCenter.dbo.JSAP_Message_Log with(nolock) 
WHERE ID_Biztalk_Partner_Info = 93 
AND CreateTime > '2016-09-30'
--AND PKey = '698ded86-fd80-4f82-a7c4-57eed7495525'
--AND --Message_Number like '%PRESHIP16081891J%'
ORDER BY CreateTime DESC

-- ack  
  SELECT  top 10 * FROM BizCenter.dbo.JSAP_Ack_Log 
  WHERE  Message_Number='4500157324' order by CreateTime desc
  
  SELECT  top 10 * FROM BizCenter.dbo.JSAP_Ack_Log WHERE Message_Number in ('PRESHIP15110002A')

SELECT  cast(AckMessage as xml),* 
FROM BizCenter.dbo.JSAP_Ack_Log 
WHERE  Message_Number in ('4500157324')
 AND STATUS = 200

  SELECT  cast(AckMessage as xml),* 
  FROM BizCenter.dbo.JSAP_Ack_Log 
  WHERE  Message_Number='PRESHIP15110002A' order by CreateTime desc


------------------------------------------------------------------------------------------------------


      use acctonDB
   SELECT b.PartnerCode,*
     FROM workTemp.dbo.question a (nolock), workTemp.dbo.wf_analysis_summery b (nolock)
    WHERE a.Category = 'System'
      AND a.flow_code = 'B2BIBP' -- "workTemp.dbo.wf_b2b_count_analysis_v3" flow_code -- ☆★☆★☆★
      AND b.Flow_code_extension = '208'  -- ☆★☆★☆★
      AND a.dt_create >= '2017-11-14'    -- ☆★☆★☆★
      AND a.id_wf_analysis_summary = b.id_wf_analysis_summary
    ORDER BY 1, 26 --b.PartnerCode


      use acctonDB
   SELECT b.PartnerCode,*
     FROM workTemp.dbo.question a (nolock), workTemp.dbo.wf_analysis_summery b (nolock)
    WHERE a.Category = 'System'
      AND a.flow_code = 'B2BVR' -- "workTemp.dbo.wf_b2b_count_analysis_v3" flow_code -- ☆★☆★☆★
      AND b.Flow_code_extension = '200'  -- ☆★☆★☆★
      AND a.dt_create >= '2017-11-20'    -- ☆★☆★☆★
      AND a.id_wf_analysis_summary = b.id_wf_analysis_summary
    ORDER BY 1, 26 --b.PartnerCode


      use acctonDB
   SELECT b.PartnerCode ,Flow_code_extension ,RootCause ,root_cause ,reason_code ,yyymmdd
    ,cause ,*
     FROM workTemp.dbo.question a (nolock), workTemp.dbo.wf_analysis_summery b (nolock)
    WHERE a.Category = 'System'
      AND a.flow_code = 'B2BADQ' -- "workTemp.dbo.wf_b2b_count_analysis_v3" flow_code -- ☆★☆★☆★
      --AND b.Flow_code_extension = '698'  -- ☆★☆★☆★
      AND a.dt_create >= '2018-01-22'    -- ☆★☆★☆★
      AND a.id_wf_analysis_summary = b.id_wf_analysis_summary
    ORDER BY 1 ,2 ,5 --b.PartnerCode


      use acctonDB --NB
   SELECT b.PartnerCode,*
     FROM workTemp.dbo.question a (nolock), workTemp.dbo.wf_analysis_summery b (nolock)
    WHERE a.Category = 'System'
      AND a.flow_code = 'B2BIHB' -- "workTemp.dbo.wf_b2b_count_analysis_v3" flow_code -- ☆★☆★☆★
      AND b.Flow_code_extension = '218'  -- ☆★☆★☆★
      AND a.dt_create >= '2018-01-02'    -- ☆★☆★☆★
      AND a.id_wf_analysis_summary = b.id_wf_analysis_summary
    ORDER BY 1, 26 --b.PartnerCode
