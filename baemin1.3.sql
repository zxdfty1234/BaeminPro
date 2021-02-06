-------쿼리 시작---------------------
1. 휴대폰 번호 대조
2. 휴대폰 번호 존재유무 확인
 --전화번호 존재유무 프로시져 생성
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

-- 존재유무 확인하는 쿼리
begin 
   checkPhoneNum ( :pphone , :phonecheck);
   if( :phonecheck = 1 )then
      dbms_output.put_line( '이미 가입된 전화번호 입니다. ' );
   else
      dbms_output.put_line( '가입된 정보가 없습니다. ' );
   end if;
end;

select * from member;

-------------------------
1. 메뉴별 기본가격 출력
2. 메뉴seq 별로 갖고 있는 옵션 출력
3. 옵션 선택 후 주문 수량선택 시 , 수량과 총액 출력

-- 선택한 기본메뉴가 가진 옵션메뉴와 그 가격을 출력하는 프로시저
declare 
    -- 메뉴를 직접 입력 받는 변수
    vmenu_name menu_basic.menu_name%type := :pmenu_name; 
    -- 메뉴의 가격을 담는 변수
    vmenu_price menu_basic.menu_price%type; 
begin
    select menu_price into vmenu_price
    from menu_basic
    where menu_name = vmenu_name;
    -- 메뉴 기본 가격 출력
    DBMS_OUTPUT.PUT_line(vmenu_name||' '||vmenu_price||'원'); 
    
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

-- 메뉴가격 + 선택옵션 가격 * 수량 = 총액 
create or replace procedure calculatePrice 
(
    -- 메뉴 이름, 옵션이름, 수량을 파라미터로 받음
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
    
    -- 선택한 메뉴 이름과 가격을 변수에 저장하는 쿼리
    select menu_name, menu_price, menu_seq into vmenu_name, vmenu_price, vmenu_seq
    from menu_basic
    where menu_name = pmenu_name;
    
    -- 선택한 옵션의 가격을 변수에 저장하는 쿼리
    select option_plusprice, option_seq into voption_plusprice, voption_seq
    from menu_basic b join menu_option o on b.menu_seq = o.menu_seq
    where menu_name = pmenu_name and option_name = poption_name;
    
    -- 입력한 수량을 변수에 저장하는 쿼리
    vorder_amount := porder_amount;
    -- 총액 계산을 위한 연산 식
    vtotal_price := (vmenu_price+voption_plusprice)*vorder_amount;
    -- 수량과 총액을 출력하는 출력형식
    dbms_output.put_line('수량: '||vorder_amount||'개'||' '||vtotal_price||'원');
    
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


-- 프로시저 실행코드
exec calculatePrice(1,'마라탕','소고기 추가',3);

select * from order_detail;
--------------------------------------------

select * from order_detail;
select* from member;
select * from review;

-- 리뷰 출력 프로시저
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

-- 회원 seq 3번의 2번 주문번호에 대한 리뷰 출력
exec show_review(3,2);