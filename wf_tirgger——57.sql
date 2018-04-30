
select * from admconfig where config_code = 'IBP_LIST'
select * from admconfigd where code like '%ibp%'


select * from scvo_openpo_snapshot


select status_edi_process_pool, dt_update, * from edi_process_pool with(nolock) where edi_type like 'IBP%' 
order by dt_create desc
select status_edi_process_pool, dt_update, * 
--update edi_process_pool set status_edi_process_pool = 70
from edi_process_pool with(nolock) where edi_type = 'IBP_OPENPO'


begin tran

--insert into edi_process_pool(
                id_admcomp
               ,edi_type
               ,ref_no
               ,ref_table
               ,ref_id
               ,cust_no
               ,status_edi_process_pool
               ,retry_count
               ,dt_create
               ,create_by
               ,stat_void
    )
    values( 10
          ,'IBP_OPENPO'
          ,'IBP_OPENPO_20171206'
          ,'scvo_openpo_snapshot'
          ,0
          ,'Juniper_IBP'
          ,0
          ,0
          ,Getdate()
          ,'micky_test'
          ,0)

--rollback

		select * from edi_process_pool where edi_type like '%ibp%'


		-------------------------------------------------------------------------------

		        select * from edi_process_pool where edi_type like 'IBP%' and dt_create > '2017-10-25' and edi_type = 'IBP_ITEM_MASTER'
          
          select * from edi_process_pool where edi_type like 'IBP%' and dt_create > '2017-10-30' and edi_type = 'IBP_INVENTORY'
          
		  select * from edi_process_pool
          --update edi_process_pool set status_edi_process_pool = 0
          where id_edi_process_pool in (5597944)

		  select * from edi_process_pool
          --update edi_process_pool set status_edi_process_pool = 0
          where id_edi_process_pool in (5614163)

