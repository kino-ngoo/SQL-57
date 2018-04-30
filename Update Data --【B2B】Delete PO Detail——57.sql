
   SELECT status_po ,dt_create,* FROM popo WHERE po_no in ('M17070845A','M17090145A')
   SELECT status_popod ,* FROM popod WHERE id_popo in ('795567','804476')

   SELECT status_receive,* FROM expect_receive WHERE source_no in ('M17070845A','M17090145A')
   SELECT status_received,* FROM expect_received WHERE id_expect_received in ('2430715','2430716','2453254')
   SELECT * FROM expect_received_extension WHERE id_expect_received in ('2430715','2430716','2453254')

 --DELETE expect_received_extension WHERE id_expect_received = 3941910


BEGIN TRAN

 --UPDATE popo set status_po = 0,UPDATE_by = 'micky',dt_UPDATE = GETDATE()
    WHERE po_no in ('M17070845A','M17090145A')

 --UPDATE popod set status_popod = 0,UPDATE_by = 'micky' ,dt_UPDATE = GETDATE() ,id_expect_received = 0 
    WHERE id_popo in ('795567','804476')

 --DELETE expect_received_extension WHERE id_expect_received in ('2430715','2430716','2453254')
 --DELETE expect_received WHERE id_expect_received in ('2430715','2430716','2453254')
 --DELETE expect_receive WHERE source_no in ('M17070845A','M17090145A')

ROLLBACK
--COMMIT

 --UPDATE expect_receive set status_receive = 0,UPDATE_by = 'jill',dt_UPDATE = GETDATE()
    WHERE source_no = 'M17080159A'

 --UPDATE expect_received set status_received = 0,UPDATE_by = 'jill',dt_UPDATE = GETDATE()
    WHERE id_expect_receive = 92911005

ROLLBACK
--COMMIT


