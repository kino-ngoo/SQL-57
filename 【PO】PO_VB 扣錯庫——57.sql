
--Jill【kevin_lee】RE: (Released) Notification (VB1710006, kevin_lee/李達凱) for Buy - Return to Vendor, Amount=15175.51

select * from popo where po_no = 'VB1710006'
select id_icstockroom_ship,dt_update,* from popod where id_popo = 812709
select dt_create,* from shipmentd where id_shipmentd in (2017386,2017387)

select * from icidf_allocate_list where source_id in (1937706)
select * from icidf_allocate_list where source_id in (2017386,2017387)

select * from icstockroom where id_icstockroom in (12,118)


select * from admuser  where user_logon like 'kevin%lee'


select a.dt_create,b.* 
from shipmentd a
        ,shipping_picking b
where a.id_shipmentd in (2017386,2017387)
and a.id_shipping_picking  = b.id_shipping_picking 



--57【kevin_lee】FW: (Released) Notification (VB1711012, kevin_lee/李達凱) for Buy - Return to Vendor, Amount=116717.00

--Ok
   select * from popo where po_no = 'VB1711012'
   select id_icstockroom_ship ,dt_update ,id_shipmentd ,* from popod where id_popo = 821942
   select dt_create ,id_icstockroom ,* from shipmentd
    where id_shipmentd in ('2032274','2032276','2032275')

   select id_icstockroom ,* from icidf_allocate_list 
    where source_id in ('1970577','1970578','1970579') --id_popod
   select * from icidf_allocate_list
    where source_id in ('2032274','2032276','2032275') --id_shipmentd X

   select * from icstockroom where id_icstockroom in (12,118)

   select * from admuser  where user_logon like 'kevin%lee'


   select a.dt_create,b.* 
     from shipmentd a
         ,shipping_picking b
    where a.id_shipmentd in ('2032274','2032276','2032275')
      and a.id_shipping_picking  = b.id_shipping_picking --??


--Not Ok
/*
[DR004]kan room_code dui bu dui
[DT080]kan liao hao zai qu [DR153] qu zhao you mei you bei allocated zhu
*/
   select * from popo where po_no = 'VB1711011'
   select id_icstockroom_ship ,dt_update ,id_shipmentd ,* from popod where id_popo = 821941
   select dt_create ,id_icstockroom ,* from shipmentd
    where source_id in ('1970575','1970576')

   select id_icstockroom ,* from icidf_allocate_list 
    where source_id in ('1970575','1970576') --id_popod
----/real_icidf_allocate_list key: id_icim_comp ,id_icstockroom
   select * from icstockroom where id_icstockroom in (118)
   select * from icim_comp where id_icim_comp in (674181,623602)

   select * from admuser  where user_logon like 'kevin%lee'


   select * from shipment where source_no = 'VB1608018'
   select * from shipmentd where id_shipment = 1583208
   select * from icidf_allocate_list where source_id in (1772891,1772892)
   select * from icidf where id_icim_comp = 623602 and id_icstockroom = 118

  --begin tran
 --update icidf set qty_shipallocate = 0.00
	where id_icim_comp = 623602 and id_icstockroom = 118

 --delete icidf_allocate_list where source_id in (1772891,1772892)
 --commit



   select a.dt_create,b.* 
     from shipmentd a
         ,shipping_picking b
    where a.id_shipmentd in ('2032274','2032276','2032275')
      and a.id_shipping_picking  = b.id_shipping_picking --??


