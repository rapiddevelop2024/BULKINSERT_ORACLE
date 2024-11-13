declare 
cursor c_clm is select c.id from hld.claim c
where c.year = 1403 and c.status_id != 65 and c.bill_id is not null and c.bill_type_id = 2 and c.claim_type_id in (2,5)
and not exists (select 1 from m_dehghan.temp_nursing_report n where n.claim_id = c.id);
type clm_type is table of c_clm%rowtype index by pls_integer;
v_clm clm_type;
v_limit_in number := 50000;
begin 
  open c_clm;
  loop
    fetch c_clm  bulk collect into v_clm limit v_limit_in;
    exit when c_clm%notfound;
    
    for indx in 1 .. v_clm.count loop
    
insert into temp_nursing_report
select /*+ORDERED*/c.id as claim_id,hcp.id as hcp_id,csi.service_item_id,to_char(c.release_date , 'yyyy','nls_calendar=persian') as release_year ,
to_char(c.release_date , 'mm' ,'nls_calendar=persian') as release_month ,
stts.name as status_name , province.name as province_name , lt.name as legal_type_name , 
uni.name as university_name , hcp.name as hcp_name , sia.total_payable_amount as total_payable_amount,
sia.total_special_payble_amount as total_special_payable_amount , 
sia.total_pref_payable_amount as total_pref_payable_amount,csi.quantity
from hld.claim c
join tpa.hcp_company hcp on hcp.id = c.hcp_company_id
/*join tpa.hcp_contract hcn on hcn.hcp_company_id = hcp.id and hcn.hcp_contract_type_id = 1 
and hcn.disable_date is null and (hcn.end_date is null or trunc(hcn.end_date) >= trunc(sysdate))*/
join cor.legal_person lp on lp.id = hcp.id
join cor.legal_type lt on lt.id = lp.legal_type_id
join cor.person p on p.id = hcp.id
join cor.person_unit pu on pu.person_id = p.id and pu.unit_type_id = 99
join cor.zone province on province.id = pu.province_id
join tpa.university uni on uni.id = hcp.university_id
join hld.claim_service_group sg on sg.claim_id = c.id
join hld.claim_service_item csi on csi.claim_service_group_id = sg.id
join hld.service_item_assessment sia on sia.id = csi.id
join hld.claim_status stts on stts.id = c.status_id
where /* c.year in (1403)  and c.claim_type_id in (2,5) and c.bill_type_id = 2
and c.status_id not in (65) and c.bill_id is not null*/
c.id = v_clm(indx).id
and csi.service_item_id  in (8121,8122,8123,8124,8125,8126,8127,8128,8129,8130,8131,8132,8133,8134,8135,8136,8137);

end loop;

commit;
   end loop;
   close c_clm;
end;
