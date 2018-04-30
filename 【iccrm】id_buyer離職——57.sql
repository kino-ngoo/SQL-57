
/*
   select * from admuser where user_id = 'J062204' --杨艳
   select * from admuser where id_admuser = 43024  --陈佩仪 J1639494
 --select * from admdept where id_admdept = 1968
   select * from admuser where id_admuser = 46805  --沈姣姣
   select * from admuser where user_id = 'J1013626'   --郭慧云
*/
/*
| stat_approve |              |
|--------------|--------------|
| 0            | New          |
| 1            | In Approve   |
| 8            | Reject       |
| 9            | Approve      |
| 10           | Auto Approve |
*/




   select slip_no,*
 --update iccrm set id_buyer = 5085, dt_update = getdate(),update_by='micky'
     from iccrm where id_buyer = 5085 --> 13 
      and stat_void = 0 
    --and stat_iccrm = 0
	  and stat_approve = 0
	  and slip_no in ('RB16090051J', 'RB17030075J')

   select * from iccrd where -- id_buyer = 43024 --> master 2 
          stat_void = 0 
    --and stat_iccrm = 0
	--and stat_approve = 0
	  and id_iccrm in ('110172','110203','110606','111131','111339','111660','111747','112155','112346','112524','112547','112959','113844')

/*
IF
BEGIN
	aaa
	aaa
END
*/
   select * 
   from iccrm a
   where id_buyer = 43024 --> 13 
      and stat_void = 1 and stat_approve = 0 
	  and not exists(select 1 from iccrd b where a.id_iccrm = b.id_iccrm )

BEGIN Tran
   select * 
 --UPDATE a set stat_void = 1
   from iccrm a
   where id_buyer = 43024 --> 13 
      and stat_void = 0 and stat_approve = 0 
	  and not exists(select 1 from iccrd b where a.id_iccrm = b.id_iccrm )

ROLLBACK
--commit


   select * 
   from iccrm a
   where id_buyer = 43024 --> 13 
     and stat_void = 0 and stat_approve = 0 
	 and exists(select 1 from iccrd b where a.id_iccrm = b.id_iccrm ) --> id_iccrm in (110203, 113844)

   select * 
   from iccrm a, iccrd
   where id_buyer = 43024 --> 13
     and a.id_iccrm = iccrd.id_iccrm 
     and a.stat_void = 0 and a.stat_approve = 0 
	 and exists(select 1 from iccrd b where a.id_iccrm = b.id_iccrm ) --> id_iccrm in (110203, 113844)


   select iccrm.slip_no
      --, iccrm.stat_iccrm
		, iccrm.stat_approve
	  --, c.id_admuser
		, c.user_name AS ICCRMbuyer
		, iccrm.id_vendor
		, vendor.vendor_name
		, vendor.vendor_alias
		, iccrd.currency
		, iccrm.amt_iccrm
		, iccrd.qty_rec
		, iccrd.po_no
	  --, p.id_admuser
	    , p.user_name AS PObuyer
		, i.user_name AS Itembuyer
		, icim_comp.part_no
		, icim_purchase.ref_no
      --, * 
     from iccrm with(nolock)
	    , iccrd with(nolock)
	    , admuser c with(nolock)
		, admuser p with(nolock)
		, admuser i with(nolock)
		, icim_comp with(nolock)
		, icim_purchase with(nolock)
		, popo with(nolock)
		, vendor with (nolock)
    where iccrm.id_iccrm = iccrd.id_iccrm
	  and iccrm.id_buyer = c.id_admuser
	  and iccrm.id_pobuyer = p.id_admuser
	  and icim_purchase.id_pobuyer = i.id_admuser
	  and iccrd.po_no = popo.po_no
	  and iccrm.id_vendor = vendor.id_vendor
	  and iccrm.id_buyer = 43024
	  and icim_comp.id_icim_comp = iccrd.id_icim_comp
	  and icim_comp.id_icim_comp = icim_purchase.id_icim_comp
      and iccrm.stat_void = 0 
    --and stat_iccrm = 0
	  and iccrm.stat_approve not in (9, 10)
	order by 1

	select * from icim_purchase where id_icim_comp in ('411201','302414','365928','320528',
'299273','168138','217040','296563',
'377868','391270','290871','334104',
'350405','194718','224277','401303',
'382429','391312','318112','90673',
'339018','305300','382570')

   select id_buyer, id_pobuyer, id_worker, * from iccrm where slip_no = 'RB17030075J '
   select * from iccrd where po_no = 'BL1703068J'
   select flow_code,* from admslip where id_admslip = 615

   ----------
   /*
      
    select * from iccrm where slip_no = 'RB17030075J'
    select * from admuser where id_admuser = 43024

   */