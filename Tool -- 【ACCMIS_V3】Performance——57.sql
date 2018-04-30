
-- ACCMIS_V3 Performance fro weekly report
-- 名詞解是 OTD : On Time Delivery
-- 以下搜尋請使用 Server : MISSQL

/*
| Open        | 15 |
| Transaction | 10 |
| Retrieve    | 5  |
*/

--------------
-- RAW Data --
--------------
   SELECT * FROM workTemp.dbo.db_erp_log_summary(nolock)
    WHERE dt_beg >= '2017-08-06'
      AND company = 'Accton HQ'		--- Accton HQ, JoyTech
    ORDER BY dt_beg desc


----------------------------
-- Check User Information --
----------------------------
   SELECT user_domain,user_id,* FROM admuser(nolock)
    WHERE user_logon like 'eric_tsai%'
        --user_id = 'A1000260'

   SELECT * FROM wf_signer with(nolock) WHERE user_logon = 'kiki_zhang'


---------------------
-- @amber_shi ver. --
---------------------
   SELECT type = CASE type WHEN 3 THEN 'Open' WHEN 2 THEN 'Retrieve' WHEN 1 THEN 'Transaction' ELSE 'Error'  END  
          ,hostname ,user_logon
         ,spid ,mcode ,scode ,dt_beg ,dt_end ,rcn ,duration
		 ,(duration/nullif(rcn, 0)) AS once                  --➰ (總時間/總筆數)
       --,sys_id ,id_admcomp ,company ,status
 --SELECT SUM(rcn)
 --SELECT count(*)
     FROM workTemp.dbo.db_erp_log_summary WITH(NOLOCK)
    WHERE mcode = 'DT138'
    --AND dt_beg >='2016-6-13' 
    --AND dt_beg >='2015-06-04'
	--AND convert(nvarchar(10), dt_end, 112) = '20171010'
    --AND dt_beg between '2016-05-23 00:00:00' and '2016-05-23 23:59:59'
      AND dt_beg between '2017-10-08 00:00:00' and '2017-10-14 23:59:59'     
    --AND scode= 'Allocate'
  --ORDER BY dt_beg DESC
    --AND scode = 'Unclose - Retrive'
    --AND type = 2 AND duration > 5 --'Retrieve'
	--AND type = 3 AND duration > 15 --'Open'
	--AND type = 1 AND duration > 10 --'Transaction' 
      AND id_admcomp = 10
    --AND company = 'JoyTech'
    --AND type = 'Unclose - Retrive'
    ORDER BY duration DESC 


------------------------------------------------
-- 某一service處理狀況 - 依照處理時間大小排序 --
------------------------------------------------
   SELECT type = CASE type WHEN 3 THEN 'Open' WHEN 2 THEN 'Retrieve' WHEN 1 THEN 'Transaction' ELSE 'Error'  END  
         ,rcn
		 ,scode
	   --,duration
	     ,company
	     ,c.domain
         ,hostname
	     ,a.user_logon
         ,spid
		 ,mcode
	     ,dt_beg
	     ,dt_end
	     ,status
     FROM workTemp.dbo.db_erp_log_summary a WITH(NOLOCK), wf_signer c with(nolock) 
  --WHERE mcode IN ('DT274','DT174','NT021','DT088')
  --WHERE mcode IN ('DT082')
    WHERE mcode = 'DT115'						---@@@@
    --AND dt_beg >= '2016-03-17 11:00:00.000'
      AND dt_beg >= '2017-09-24 00:00:00'		---@@@@
      AND dt_beg <= '2017-09-30 23:59:59'		---@@@@
      AND a.id_admcomp = 10						--- accton 2, joytech 10
      AND a.id_admcomp = c.id_admcomp 
      AND a.user_logon = c.user_logon 
    --AND c.domain = 'joytech' --AND dt_expire_user is null 
    --AND c.domain !=  'joytech' --AND dt_expire_user is null
    --AND duration > 15
    --AND duration < 120
    --AND scode = 'Invoice Sold'
    --AND scode like '%Invoice Sold%'
    --AND a.user_logon like '%ailsa%'
    --AND type = 1								--- Retrieve 2, Transaction 1, Open 3, Error 4
      AND type != 4
    --AND rcn > 10
    --AND a.user_logon not in ('selena_peng','amber_shi')
  --ORDER BY dt_beg
  --ORDER BY dt_beg DESC
    ORDER BY rcn DESC
  --ORDER BY dt_beg


------------------------------------
-- 某一service處理狀況 - 查詢筆數 --
------------------------------------
   SELECT 'Count' = count(*)
     FROM workTemp.dbo.db_erp_log_summary WITH(NOLOCK)
  --WHERE mcode IN ('DT274','DT174','NT021','DT088')
    WHERE mcode IN ('DT115')
  --WHERE mcode IN ('DT009')
    --AND dt_beg like '2017-09-29%'
      AND dt_beg >= '2017-09-24 00:00:00'
      AND dt_beg <= '2017-09-30 23:59:59'
      AND id_admcomp = 10						--- accton 2, joytech 10
    --AND scode like '%Book%'
    --AND (user_logon = 'kiki_tsai' or user_logon ='edith_huang')
    --AND duration > 10
      AND type != 4 						    	--- Retrieve 2, Transaction 1
    --AND rcn > 10


-----------------------------------------------------------------
-- 計算平均花費秒數: by type, function_code, and date duration --
-----------------------------------------------------------------
  DECLARE @total_n decimal(14,2), @delete_n decimal(14,2), @sum_duration decimal(14,2);
  DECLARE @F_Code Varchar(20) = 'DT115'	                    ---@@@@
         ,@company int = 10	                                --- accton 2, joytech 10
		 ,@date_begin Varchar(30) = '2017-09-24'	    		---@@@@
		 ,@date_end Varchar(30) = '2017-09-30'	            ---@@@@
		 ,@F_Type int = 1								    --- Retrieve 2, Transaction 1
         ,@scode Varchar(30) = '%%' --'Ship ( By Customer ) - Retrieve'   ---@@@@

   SELECT @total_n =  count(*)
     FROM workTemp.dbo.db_erp_log_summary WITH(NOLOCK)
    WHERE mcode IN (@F_Code)
      AND dt_beg >= @date_begin
    --AND dt_beg like '2017-09-29%'
      AND dt_beg <= @date_end
      AND id_admcomp = @company
      AND type = @F_Type	
      AND scode like @scode
    --AND scode like '%Book%'

-- Logic1: general average
   SELECT @sum_duration =  sum(duration)
     FROM workTemp.dbo.db_erp_log_summary WITH(NOLOCK)
    WHERE mcode IN (@F_Code)
      AND dt_beg >=@date_begin
      AND dt_beg <=@date_end
      AND id_admcomp = @company
      AND type = @F_Type
      AND scode like @scode
    --AND scode like '%Book%'

   SELECT @sum_duration as 總秒數;
   SELECT @total_n as 總比數;
   SELECT (@sum_duration/@total_n) as 平均時間;


---------------------------------------------------------------------------
-- check deef_log (for "Release To Shipping Process" only), 1 Month Only --
---------------------------------------------------------------------------
   SELECT TOP 1000 dt_create,* from deef_log (nolock)
    WHERE source_type LIKE '%'
    --AND dt_create >='2017-07-01'
    --AND dt_create <='2017-8-02'
    --AND content5 like '%A1000260%'               
    ORDER BY deef_log.dt_create


--------------------------------------------------------
-- KPI計算: by type, function_code, and date duration --
--------------------------------------------------------
  DECLARE @ok_n decimal(14,2), @total_n decimal(14,2);
  DECLARE @F_Code Varchar(20) = 'DT115'
         ,@date_begin Varchar(20) = '2017-09-24'
         ,@date_end Varchar(20) = '2017-09-30'
         ,@F_Type int = 2										--- Retrieve 2, Transaction 1
         ,@max_dur int
         ,@company int = 2

    SET @max_dur = (case @F_Type when 1 then 15 else 10 end)	--- Retrieve 10, Transaction 15

   SELECT @ok_n =  count(*)
     FROM workTemp.dbo.db_erp_log_summary WITH(NOLOCK)
    WHERE mcode IN (@F_Code)
      AND dt_beg >= @date_begin
      AND dt_beg <= @date_end
      AND id_admcomp = @company
      AND type = @F_Type
      AND duration < @max_dur	

   SELECT @total_n =  count(*)
     FROM workTemp.dbo.db_erp_log_summary WITH(NOLOCK)
    WHERE mcode IN (@F_Code)
      AND dt_beg >= @date_begin
      AND dt_beg <= @date_end
      AND id_admcomp = @company
      AND type = @F_Type

   SELECT 'ok num'= @ok_n;
   SELECT 'total num'=@total_n;
   SELECT '%'=(@ok_n/@total_n);

