-------���� ����---------------------
1. �޴��� ��ȣ ����
2. �޴��� ��ȣ �������� Ȯ��
 --��ȭ��ȣ �������� ���ν��� ����
create or replace procedure checkPhoneNum
(
    pphone in varchar
    , pcheckphone out number
)
is
begin
    select count(*) into pcheckphone
    from member
    where phone = pphone;
    
end;

variable phoncheck number;

-- �������� Ȯ���ϴ� ����
begin 
   checkPhoneNum ( :pphone , :phonecheck);
   if( :phonecheck = 1 )then
      dbms_output.put_line( '�̹� ���Ե� ��ȭ��ȣ �Դϴ�. ' );
   else
      dbms_output.put_line( '���Ե� ������ �����ϴ�. ' );
   end if;
end;

select * from member;

-------------------------
1. �޴��� �⺻���� ���
2. �޴�seq ���� ���� �ִ� �ɼ� ���
3. �ɼ� ���� �� �ֹ� �������� �� , ������ �Ѿ� ���

-- ������ �⺻�޴��� ���� �ɼǸ޴��� �� ������ ����ϴ� ���ν���
declare 
    -- �޴��� ���� �Է� �޴� ����
    vmenu_name menu_basic.menu_name%type := :pmenu_name; 
    -- �޴��� ������ ��� ����
    vmenu_price menu_basic.menu_price%type; 
begin
    select menu_price into vmenu_price
    from menu_basic
    where menu_name = vmenu_name;
    -- �޴� �⺻ ���� ���
    DBMS_OUTPUT.PUT_line(vmenu_name||' '||vmenu_price||'��'); 
    
    for vrow in ( select option_seq, option_name, option_plusprice
                        from menu_basic b join menu_option o on b.menu_seq = o.menu_seq
                        where b.menu_name = vmenu_name)
    loop
         DBMS_OUTPUT.PUT_line(vrow.option_seq||' '||vrow.option_name||' '||vrow.option_plusprice); 
    end loop;
    
end;

create sequence order_seq
increment by 1
start with 1
nomaxvalue
NOCACHE;

create sequence orderdetail_seq
increment by 1
start with 8
nomaxvalue
NOCACHE;

-- �޴����� + ���ÿɼ� ���� * ���� = �Ѿ� 
create or replace procedure calculatePrice 
(
    -- �޴� �̸�, �ɼ��̸�, ������ �Ķ���ͷ� ����
    porder_seq order_main.order_seq%type,
    pmenu_name menu_basic.menu_name%type ,
    poption_name menu_option.option_name%type ,
    porder_amount number
)
is
    vmenu_seq menu_basic.menu_seq%type;
    vmenu_name menu_basic.menu_name%type;
    voption_name menu_option.option_name%type;
    vmenu_price menu_basic.menu_price%type;
    voption_plusprice menu_option.option_plusprice%type;
    vtotal_price number(6);
    vorder_amount number(2);
    voption_seq menu_option.option_seq%type;
    
begin
    
    -- ������ �޴� �̸��� ������ ������ �����ϴ� ����
    select menu_name, menu_price, menu_seq into vmenu_name, vmenu_price, vmenu_seq
    from menu_basic
    where menu_name = pmenu_name;
    
    -- ������ �ɼ��� ������ ������ �����ϴ� ����
    select option_plusprice, option_seq into voption_plusprice, voption_seq
    from menu_basic b join menu_option o on b.menu_seq = o.menu_seq
    where menu_name = pmenu_name and option_name = poption_name;
    
    -- �Է��� ������ ������ �����ϴ� ����
    vorder_amount := porder_amount;
    -- �Ѿ� ����� ���� ���� ��
    vtotal_price := (vmenu_price+voption_plusprice)*vorder_amount;
    -- ������ �Ѿ��� ����ϴ� �������
    dbms_output.put_line('����: '||vorder_amount||'��'||' '||vtotal_price||'��');
    
    insert into order_detail values(orderdetail_seq.nextval, porder_seq, voption_seq, vmenu_seq, porder_amount);
end;
--        (select b.menu_seq
--        from order_detail d join menu_basic b on d.menu_seq = b.menu_seq
--                                        join menu_option o on d.option_seq = o.option_seq
--                                        join order_main m on d.order_seq = m.order_seq
--        where menu_name = pmenu_name and option_name = poption_name),
--        (select o.option_seq
--        from order_detail d join menu_basic b on d.menu_seq = b.menu_seq
--                                        join menu_option o on d.option_seq = o.option_seq
--                                        join order_main m on d.order_seq = m.order_seq
--        where menu_name = pmenu_name and option_name = poption_name),
--        porder_amount
--        );


-- ���ν��� �����ڵ�
exec calculatePrice(1,'������','�Ұ�� �߰�',3);

select * from order_detail;
--------------------------------------------

select * from order_detail;
select* from member;
select * from review;

-- ���� ��� ���ν���
create or replace procedure show_review
(
    pmem_seq member.mem_seq%type,
    porder_seq restaurant.restaurant_seq%type
)
is
    vid member.id%type;
    vstar review.star%type;
    vwrite_date review.write_date%type;
    vcontents review.contents%type;
    vmenu_name menu_basic.menu_name%type;
begin
    select m.id, star, write_date, contents
            into vid,vstar,vwrite_date,vcontents
    from review r join member m on r.mem_seq = m.mem_seq
    where r.mem_seq = pmem_seq and r.order_seq = porder_seq;
    DBMS_OUTPUT.PUT_line(vid);
    DBMS_OUTPUT.PUT_line(vstar||' '||vwrite_date);
    DBMS_OUTPUT.PUT_line(vcontents);
    
    for vrow in (select b.menu_name
    from review r join order_main o on r.order_seq = o.order_seq
                            join member m on r.mem_seq = m.mem_seq
                            join order_detail d on d.order_seq = o.order_seq
                            join menu_basic b on b.menu_seq = d.menu_seq
    where  r.mem_seq = pmem_seq and r.order_seq = porder_seq
                        )
    loop
      DBMS_OUTPUT.PUT_line(vrow.menu_name);
    
    end loop;
end;

-- ȸ�� seq 3���� 2�� �ֹ���ȣ�� ���� ���� ���
exec show_review(3,2);