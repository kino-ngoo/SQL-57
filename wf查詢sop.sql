--�d�ߤT�Ѥ� WorkFlow �����檬�p�θ��
/*--
	�Y�n�Nwf��cancel���ݭn��WT004�H��mail���U��cancel���O==>�|�N�㵧wf��ƧR��
	�p�G�n�R��wf���Y�@�B�J�Ȼ�update wf_process �� stage_status �� 99 �H�� dt_completed = Getdate() + mail���U��cancel���O

	�p�G��J edi_process_pool���O������wf�A�i���]:
	1.�L�|���workflow_start����center_duns_no�M�w���ͦb���Ӱϰ�
	2.�Ycenter_duns_no�S���A�h�|���wt001�W�]�w��duns_no
	3.�Y1.2���S���A�h�|����ұo�쪺duns_no_to
	4.�Y�W�z�����S���A�N�|���Ĳ�o��������


--*/
--select dt_request,b.stage_name,dt_completed,a.stage_status,a.* 
--from wfDB.dbo.wf_process a with(nolocK) , wfDB.dbo.wf_stage b with(nolock) 
--where a.id_wf_stage = b.id_wf_stage
--and a.id_wf_doc in ('1075854','1075855','1075856','1075867',
--'1075868','1075869','1075857','1075858',
--'1075860','1075862','1075864','1075873')-- 1075856
----and stage_status < 99
--order by id_wf_doc


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
   --   ,doc_info = CAST(wf_doc.doc_info AS XML)
	  --,wf_doc_doc_b2b_xml = wf_doc.doc_b2b_xml
	  ,wf_process_doc_b2b_xml = wf_process.doc_b2b_xml
	  ,wf_doc.doc_mainarea_xml
      ,wf_doc.flow_code
	  ,wf_doc.doc_code
	  ,wf_doc.id_reference
	  ,wf_doc.id_request
	  ,wf_doc.doc_applier
      --,wf_process.* 
--select distinct doc_no, wf_doc.dt_create , wf_doc.doc_status
  FROM wf_doc with(nolock)
      ,wf_process with(nolock)
      ,wf_stage with(nolock)
 WHERE wf_doc.id_wf_doc = wf_process.id_wf_doc
   and wf_process.id_wf_stage = wf_stage.id_wf_stage
   and wf_doc.stat_void = 0

   --and wf_doc.flow_code =  'B2BAFD'
   --and wf_doc.doc_code= '223'
   --and wf_doc.dt_create >= '2016-10-28 00:00:00.000' 
   --and wf_doc.dt_create <= '2016-10-30 23:59:59.999' 
   --and wf_doc.id_wf_doc='326638'
--   and wf_doc.doc_no in ('PK16090645','PK16090886','PK16090887','PK16090888',
--'PK16090889','PK16090890','PK16090891','PK16090892',
--'PK16090893','PK16090894','PK16090895')
   and wf_doc.doc_no like'%677bd8d4-a689-4a06-ba68-7cd4a9%'
   --AND stage_name='1. zp_Gedi_generate_to_gateway_3A4'
     --and doc_status=80
   --AND id_admcomp=9
   --and wf_doc.id_wf_doc=472387
ORDER BY wf_doc.id_wf_doc, wf_process.id_wf_process,wf_process.dt_request DESC
------------------------------------------------------------------------------------------------------------
--�Y����join�d�ߤ���A�i�H�ϥγ�@table�Ӭd�� ==>��ܥ�����wf_process (��ƤӦh ���L�ɥi��o��) �ݭn�߰ݥ��x
select dt_create,dt_complete,* from wfDB.dbo.wf_doc with(nolocK) --where doc_no = 'Demand_Plan_20170119'
where dt_complete is null

/* ***�Y������wf_process�A���άd�ߨ�id_wf_doc�A�⥦��J wfDB.dbo.adm_mq �d�ߧ����id_adm_mq ��J in / out ���d��
	1.�n�� action_code��wf-root => �Ysb_status = 0 ��ܩ|������A�i�ܦa�y�d��wt001�W��wait doc(�ݵ��ݪ�B2B����)�O�_���]�w��
	2.�Yin ������action_code��wf-root �B sb_status = 1 ���Oout�����͡A�h��ܥi��Qkill���F�A�i�H��Jessica�άO��ʭ��](�u��wf-root�i�o�˰�)
*/	
use wfDB
select * from wfDB.dbo.adm_mq where id_wf_doc=5295696
-------------------------------------------------------------------------------------------------------------
--************--
--�Y�B�J�d�bcall biztalk�ɡA�i���h�d��biztalk�O�_��Ĳ�o�Q�e�X(�U��SQL)
--�Y�S��Ĳ�oSP�A�B�b���հ�Ĳ�o�i�H�d�ݰ���B�J����duns_no�O�_���T(���հϤ��ର0054)

--=======================================================================================================
--�d��wf�PBiztalk�^�Ъ��A(99����/15)
--wf_bt_queue:��wf�X�h-->Biztalk
--bt_wf_queue:��Biztalk�X�h-->wf
select * from SourceDB.dbo.wf_bt_queue with(nolock) where pkey = '366b3d1c-8d00-4318-bee1-cad1b6453271' 
select * from SourceDB.dbo.bt_wf_queue with(nolock) where pkey = '366b3d1c-8d00-4318-bee1-cad1b6453271'
--=======================================================================================================
--²�����j�M
--1.���Nref_no��J�j�M
--DT300:doc_no like '20160121105650_960070'
--dt_complete���e���Pdoc_status(����99/Cancel93/���椤80)�@�P
select dt_complete,doc_status,* 
----****update a set doc_status = 93 
from wfDB.dbo.wf_doc a with(nolock) 
where doc_no = '2791ce09-6d27-4642-adee-2a96e7d23410'
--where flow_code =  'B2BISD' 
--and dt_complete is not null 
--and doc_status <> 99 

--2.�d�ߨ�ȫ�A�Nid_wf_doc��J�j�M
select b.stage_name,a.dt_completed,a.dt_request,stage_status,a.* 
from wfDB.dbo.wf_process a with(nolock) , wfDB.dbo.wf_stage b with(nolock) 
where a.id_wf_stage = b.id_wf_stage 
and a.id_wf_doc = 13344
--=======================================================================================================
--wf_doc �|���ƨ�adm_mq ����zp = zp_sb_wf_fs ���U�@�B�J zp_sb_wfp

use wfDB
select * from wfDB.dbo.adm_mq where id_wf_doc=5295696

select * from wfDB.dbo.adm_mq with(nolock) where id_wf_process=27825760
--�ϥ�id_wf_process�h���j�M

/*
  �Y��B�J�S���~�򨫤U�h�A�i���d��Actioncode�y�{�O�_���e
  -->�Y�L: �ɵe�n�y�{��� zp_sb_wfp �N���A�ȭ��sĲ�o�A���L���U��

*/

SELECT mq_status, *
--UPDATE a SET mq_status = 0 --���sĲ�o�o�@�BSP
  FROM wfDB.dbo.adm_mq a with(nolock)
WHERE id_wf_process =  10450152   
and mq_targetobj = 'zp_sb_wf_fs'


--update adm_mq set mq_status=0 where id_adm_mq=56525415
--=======================================================================================================
--A. Cancel ********
--(1) WT004 Cancel :update wf_doc&wf_process) -- �ܧ�WF�W�����A��,���|�A�oDelay ***�|�R��WF���y�{�A������W���|�A�e�{�o����F
--(2) Broker Cancel(exec Mail zp_GlobalSB_Cancel) : update sb_queue_out --����Broker�AĲ�o(SP���A����)  ***���Broker�W�����A�ȡA��Broker���n�A���sĲ�o

--(*)�Y��single��X��multi�ɡA�n�ݿ��~���ͦb���̡A�����Ϳ��~���~�nBroker Cancel�A�Y�����\�]���u�n�bWT004�R��WF���y�{�N�n

--B. ���sĲ�o�o�@�BSP ********
--(1) update adm_mq.mq_status = 0 
	--> �Ainsert �s��sb_queue_in/sb_queue_out ; �ϥήɾ� : SP�QKILL�S������Resend mail�ɾA��.
--(2) exec Broker Resend (Mail zp_GlobalSB_Resend)  
	--> update sb_queue_in �Ϩ䭫�s���� ; �ϥήɾ� : SP ����fail�����~�T��,�B�z�������Resend mail��������.

--C. �YReceive EDI ������Biztalk�ҥH�ݭn����Biztalk�W���d�� �d�ߥL�����A�~���D����p��B�z
--�d��wf�PBiztalk�^�Ъ��A(99����/15)
--wf_bt_queue:��wf�X�h-->Biztalk
--bt_wf_queue:��Biztalk�X�h-->wf
select * from SourceDB.dbo.wf_bt_queue with(nolock) where pkey = '366b3d1c-8d00-4318-bee1-cad1b6453271' 
select * from SourceDB.dbo.bt_wf_queue with(nolock) where pkey = '366b3d1c-8d00-4318-bee1-cad1b6453271'
-----Queue in/out �����u�O�d�@��
--=======================================================================================================

--���楻���H�~��zp �n�bSourceDB �d�� ex:�ثe����MISSQL�n�j�MJOYTECH����Ʀb���d
-- id_reference=id_adm_mq

-- SourceDB
SELECT TOP 20 sb_msg = CAST(sb_msg AS XML), * FROM SourceDB.dbo.sb_queue_in with(nolock) WHERE --action_code = 'wf_B2BBBOM' 
id_reference = 20883765 
ORDER BY dt_create DESC

SELECT TOP 20 sb_msg = CAST(sb_msg AS XML) , * FROM SourceDB.dbo.sb_queue_out with(nolock) WHERE  --action_code = 'wf_B2BBOM'
id_reference = 20883765
--global_id='A2ADA583-9CA2-E311-8077-0024E84BE1DD'
ORDER BY dt_create DESC

--EXEC SourceDB.dbo.zp_GlobalSB_Send 'E5F36A76-9051-E711-80F5-00155D1E1A03'     
--EXEC SourceDB.dbo.zp_GlobalSB_Cancel '854BCEB3-BB50-E711-80D9-B8CA3A5EFFDB'

/*
case1:�Y�bIn����wf�S������wf_B2BXXX�A�j�F�@�q�ɶ��~���ͷs��wf�Pwf_B2BXXX ==>�h��ܥi��Ĥ@�����ͮɳQKill���F
****�Y�O�n�R��ADQ�n�O�o�Nmulti�]�@�֧R��!!!!!!!!!!!!!!!�M��Nedi_process_pool���A�Ȱ��ק�!!!!!!!!

--�d��ack table �O�_������
SELECT top 100 status, * FROM wfDB.dbo.wf_ack_wait (NOLOCK)  WHERE id_wf_doc in (1327182,1327183,1327185,1327069)
 order by dt_start desc

--�d��ACK�O�_�����\

--STATUS =0 �@��J
--STATUS = 99 ���\
--STATUS = 12 --ack broker ����(5����)
SELECT top 100 status, * FROM wfDB.dbo.wf_ack_wait (NOLOCK) where id_wf_ack_wait in (6232762,6232761,6232760,6232759)

 update wfDB.dbo.wf_ack_wait set status =0,output= null
where id_wf_ack_wait in (6232762,6232761,6232760,6232759)


*/
--���楻����zp �n�bwfDB �d�� ex:�ثe����MISSQL�n�j�MMISSQL����Ʀb���d
/* In ( wf -> wf_B2BXXX ) => Out ( wf -> wf_B2BXXX ) => In (wf_ack ) => Out (wf_ack ) */
-- wfDB
--action_code : wf -> wf_B2BXXX ->wf_ack 
SELECT  sb_msg = CAST(sb_msg AS XML), action_code,sb_status,sb_msg,* 
FROM wfDB.dbo.sb_queue_in with(nolock) WHERE-- action_code = 'wf_B2BBOM' AND dt_create BETWEEN '2012-11-28 10:00:30.567' AND '2012-11-28 11:31:30.567'
 id_reference = 20882849
 --global_id='52ACFB16-A3A2-E311-8077-0024E84BE1DD'
ORDER BY dt_create DESC

--action_code : wf -> wf_B2BXXX ->wf_ack 
--If not exists out.wf_B2BXXX , may be SP killed
SELECT  sb_msg = CAST(sb_msg AS XML) , action_code,* 
FROM wfDB.dbo.sb_queue_out with(nolock) WHERE --action_code = 'wf_B2BBOM' AND dt_create BETWEEN '2012-11-28 10:00:30.567' AND '2012-11-28 11:31:30.567'
id_reference = 20882849
ORDER BY dt_create DESC

--EXEC wfDB.dbo.zp_GlobalSB_Send 'FFBF7479-A454-E711-80D9-B8CA3A5EFFDB'     
--EXEC wfDB.dbo.zp_GlobalSB_Cancel 'B1A3DC84-CD4A-E711-80D9-B8CA3A5EFFDB'

--=======================================================================================================
--B2BDS�������O�qMISSQL�� BROKER�e��JOY�� BROKER
--�ҥH�n��SELECT MISSQL �� SOURCE DB �� OUT �T�w��Ʀ��qMISSQL��JOY  (STATUS=3 ��ܧ���)
select CAST(message_body as xml),* from SourceDB.dbo.GlobalSB_OUT_Q6 WITH(NOLOCK)

--�A�� JOY��SOURCE DB �� INT �T�{��ƬO�_�٦b�]
--(STATUS=0 ��ܥ��b�]ZP �άO���b��ZP  STATUS=1 ��ܦb�ƶ�����ZP)
--���YGlobalSB_IN_Q6��STATUS=0 ���Odm_broker_activated_tasks �S�����(SPID) ��ܸ�ƳQKILL���F

select CAST(message_body as xml),* from SourceDB.dbo. GlobalSB_IN_Q6 WITH(NOLOCK)


--�{�b���b���檺BROKER(spid)
select * from sys.dm_broker_activated_tasks  


--=======================================================================================================

-- Broker Log (�T�{zp �O�_�u��������)�n��ZP (�@�Ӥp��update ��Ƥ@��)
SELECT TOP 200 * FROM workTemp.dbo.tmp_sp_info_log with(nolock) WHERE sp_name like '%joyDB.dbo.zp_IntCb2b_collect_to_ship%'order by dt_start desc 

--=======================================================================================================

--�d��ACK �O�_�����\���� ���A��99�����榨�\
SELECT top 10 * FROM wfDB.dbo.wf_ack_wait (NOLOCK) where doc_no='2791ce09-6d27-4642-adee-2a96e7d23410' order by dt_start desc
--=======================================================================================================

--Blocked ��Ƭd��
--ROOT �O�ɤH�� �]�w�n�d�ߪ��ɶ�
select spid,blocked,hostname,loginame,cmd,root,dt_create,script,stat_kill,waittime,mins,program_name
--select * 
from workTemp.dbo.tmp_block with(Nolock)
where  root = 'ROOT'
and dt_create between  '2014-03-07 17:00' and '2014-03-07 17:30'
order by dt_create

--�NROOT��ID���Blocked �̭��N�i�H���D���ר쨺�ǵ{��

select distinct spid,blocked,hostname,loginame,cmd,root,script,stat_kill,waittime,mins,program_name
from workTemp.dbo.tmp_block with(Nolock)
where blocked = 43
and dt_create between   '2014-03-07 17:00' and '2014-03-07 17:30'

--=======================================================================================================
--������server : srv-biztalk b2b b2b
--���հ�server : srv-biztalktest sa !abcd1234

--EDI��m: \\srv-doc\personal\Daily\B2B\backup
--���EDI���i�H�d�ݲĤ@�ӭȡA��EDI���ߤ@��

USE BizCenter
--=======================================================================================================
--Biztalk ���
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
   and JSAP_Message_Log.ID_JSAP_Message_Log = JSAP_Action_Log.ID_JSAP_Message_Log 
   --and Action_Name = 'OutBound Mapping End'
      --and Action_Name = 'Send To CMService Start'
      --AND DOC_TYPE = 'PreShip_Cancel'
      and JSAP_Message_Log.CreateTime > '2017-01-01'
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
   and JSAP_Message_Log.ID_JSAP_Message_Log = JSAP_Action_Log.ID_JSAP_Message_Log 
   --and Action_Name <> 'CMService SendOutBoundMessage Start'
   and Action_Name = 'OutBound Mapping End'
      --and Action_Name = 'Receive Error Ack'
      and JSAP_Message_Log.CreateTime > '2016-02-01'
ORDER BY JSAP_Action_Log.CreateTime DESC
 
-- I282 
SELECT *, Message = CAST(Message AS XML) 
FROM BizCenter.dbo.JSAP_Message_Log with(nolock) 
WHERE ID_Biztalk_Partner_Info = 93 
and CreateTime > '2016-09-30'
--and PKey = '698ded86-fd80-4f82-a7c4-57eed7495525'
--and --Message_Number like '%PRESHIP16081891J%'
ORDER BY CreateTime DESC

-- ack  
  select  top 10 * from BizCenter.dbo.JSAP_Ack_Log 
  where  Message_Number='4500157324' order by CreateTime desc
  
  select  top 10 * from BizCenter.dbo.JSAP_Ack_Log where Message_Number in ('PRESHIP15110002A')

select  cast(AckMessage as xml),* 
from BizCenter.dbo.JSAP_Ack_Log 
where  Message_Number in ('4500157324')
 and STATUS = 200

  select  cast(AckMessage as xml),* 
  from BizCenter.dbo.JSAP_Ack_Log 
  where  Message_Number='PRESHIP15110002A' order by CreateTime desc