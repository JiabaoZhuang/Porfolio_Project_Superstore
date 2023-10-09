-- Container Table

create sequence seq_jz_ss_container

insert into jz_ss_container(container_id, container_name)

select seq_jz_ss_container.nextval container_id, product_container container_name
from ( 
       select product_container
       from jz_ss_stage
       minus
       select container_name
       from jz_ss_container
      )

select * from jz_ss_container



-- Top Category

create sequence seq_jz_ss_category

insert into jz_ss_category(category_id, category_name)

select seq_jz_ss_category.nextval category_id,
       product_category category_name
from ( 
       select product_category
       from jz_ss_stage
       minus
       select category_name
       from jz_ss_category
       where category_rid is null
      )
       
select * from jz_ss_category
    



-- Sup Category

insert into jz_ss_category(category_id, category_name, category_rid)

select seq_jz_ss_category.nextval category_id,
       category_name, category_rid
from ( 
       select product_sub_category category_name, jz_ss_category.category_id category_rid
       from jz_ss_stage,
            jz_ss_category
       where jz_ss_stage.product_category = jz_ss_category.category_name
       minus
       select category_name, category_rid
       from jz_ss_category
       where category_rid is not null
      )
       
select * from jz_ss_category
    



-- Product Table

create sequence seq_jz_ss_product


insert into jz_ss_product(product_id, product_name, category_id, container_id)

select seq_jz_ss_product.nextval product_id, 
       product_name, 
       category_id, 
       container_id
from ( 
       select product_name,
              category_id,
              container_id
       from  jz_ss_stage,
             jz_ss_category,
             jz_ss_container
       where jz_ss_stage.product_sub_category = jz_ss_category.category_name
       and jz_ss_stage.product_container = jz_ss_container.container_name
       minus
       select product_name, category_id, container_id
       from jz_ss_product
       )
       
select * from jz_ss_product




-- Ship Mode Table

create sequence seq_jz_ss_shipmode

insert into jz_ss_shipmode(ship_mode_id, ship_mode)

select seq_jz_ss_shipmode.nextval ship_mode_id,
       ship_mode
from (
        select ship_mode 
        from jz_ss_stage
        minus
        select ship_mode
        from jz_ss_shipmode
     )

select * from jz_ss_shipmode




-- Country Table

create sequence seq_jz_ss_country

insert into jz_ss_country(country_id, country)

select seq_jz_ss_country.nextval country_id, country
from (
        select country
        from jz_ss_stage
        minus
        select country
        from jz_ss_country
      )

select * from jz_ss_country




-- Region Table

create sequence seq_jz_ss_region


insert into jz_ss_region(region_id, region, country_id)

select seq_jz_ss_region.nextval region_id, region, country_id
from (
        select region, country_id
        from jz_ss_stage, jz_ss_country
        where jz_ss_stage.country = jz_ss_country.country
        minus
        select region, country_id
        from jz_ss_region
      )

select * from jz_ss_region




-- Manager Table

create sequence seq_jz_ss_manager

insert into jz_ss_manager(manager_id, manager, region_id)

select seq_jz_ss_manager.nextval manager_id, manager, region_id
from (
        select manager, region_id
        from jz_ss_stage_manager, jz_ss_region
        where jz_ss_stage_manager.region = jz_ss_region.region
        minus
        select manager, region_id
        from jz_ss_manager
      )

select * from jz_ss_manager




-- State Table

create sequence seq_jz_ss_state


insert into jz_ss_state(state_id, state_name, region_id)

select seq_jz_ss_state.nextval state_id, state_name, region_id
from (
        select state_or_province state_name, region_id
        from jz_ss_stage, jz_ss_region
        where jz_ss_stage.region = jz_ss_region.region
        minus
        select state_name, region_id
        from jz_ss_state
      )

select * from jz_ss_state




-- Priority Table

create sequence seq_jz_ss_priority


insert into jz_ss_priority(priority_id, priority)

select seq_jz_ss_priority.nextval priority_id, priority
from (
        select trim(order_priority) priority
        from jz_ss_stage
        minus
        select priority
        from jz_ss_priority
      )

select * from jz_ss_priority




-- Segment Table

create sequence seq_jz_ss_segment


insert into jz_ss_segment(segment_id, seg_name)

select seq_jz_ss_segment.nextval segment_id, seg_name
from (
        select customer_segment seg_name
        from jz_ss_stage
        minus
        select seg_name
        from jz_ss_segment
      )

select * from jz_ss_segment




-- Return Table

insert into jz_ss_return(order_id, status)

select order_id, status
from (
        select order_id, status
        from jz_ss_stage_return 
        minus
        select order_id, status
        from jz_ss_return
      )

select * from jz_ss_return



-- Customer Table

create sequence seq_jz_ss_customer


insert into jz_ss_customer(customer_pk, customer_id, first_name, middle_name, last_name)

select seq_jz_ss_customer.nextval customer_pk, customer_id, first_name, middle_name, last_name
from (
        select customer_id,
               initcap(regexp_substr(customer_name,'[^ ]+',1,1)) first_name,
               case when length(customer_name) - length(replace(customer_name,' ', '')) >= 2 then initcap(regexp_substr(customer_name,'[^ ]+',1,2)) else null end middle_name,
               initcap(regexp_substr(customer_name, '[^ ]+$')) last_name
        from jz_ss_stage
        minus
        select customer_id, first_name, middle_name, last_name
        from jz_ss_customer
      )

select * from jz_ss_customer





-- Address Table

create sequence seq_jz_ss_address


insert into jz_ss_address(address_id, city, postal_code, customer_fk, state_id)

select seq_jz_ss_address.nextval adress_id, city, postal_code, customer_fk, state_id
from (
        select city, postal_code, customer_pk customer_fk, state_id
        from jz_ss_stage,
             jz_ss_customer,
             jz_ss_state
        where jz_ss_stage.customer_id = jz_ss_customer.customer_id
        and jz_ss_stage.state_or_province = jz_ss_state.state_name
        minus
        select city, postal_code, customer_fk, state_id
        from jz_ss_address
      )

select * from jz_ss_address





-- Order Table
create sequence seq_jz_ss_order


insert into jz_ss_order(order_pk, order_id, order_date, customer_fk, priority_id, segment_id)

select seq_jz_ss_order.nextval order_pk, order_id, order_date, customer_fk, priority_id, segment_id
from (
        select order_id, order_date, customer_pk customer_fk, priority_id, segment_id
        from jz_ss_stage
        left join jz_ss_customer
        on jz_ss_stage.customer_id = jz_ss_customer.customer_id
        left join jz_ss_priority
        on trim(jz_ss_stage.order_priority) = jz_ss_priority.priority
        left join jz_ss_segment
        on jz_ss_stage.customer_segment = jz_ss_segment.seg_name
        minus
        select order_id, order_date, customer_fk, priority_id, segment_id
        from jz_ss_order
      )

select * from jz_ss_order


select count(*) from jz_ss_stage


-- Order_Item Table

create sequence seq_jz_ss_order_item


insert into jz_ss_order_item(order_item_id, discount, unit_price, shipping_cost, ship_date, profit, quality_ordered, sales, base_margin, ship_mode_id, product_id, order_fk)

select seq_jz_ss_order_item.nextval order_item_id, discount, unit_price, shipping_cost, ship_date, profit, quality_ordered, sales, base_margin, ship_mode_id, product_id, order_fk
from (
        select discount, unit_price, shipping_cost, ship_date, profit, quantity_ordered_new quality_ordered, sales, product_base_margin base_margin, ship_mode_id, product_id, order_pk order_fk
        from jz_ss_stage
        left join jz_ss_customer on jz_ss_stage.customer_id = jz_ss_customer.customer_id
        left join jz_ss_priority on trim(jz_ss_stage.order_priority) = jz_ss_priority.priority
        left join jz_ss_segment on jz_ss_stage.customer_segment = jz_ss_segment.seg_name
        left join jz_ss_product on jz_ss_stage.product_name = jz_ss_product.product_name
        left join jz_ss_order on jz_ss_stage.order_id = jz_ss_order.order_id
        and jz_ss_stage.order_date = jz_ss_order.order_date
        and jz_ss_customer.customer_pk = jz_ss_order.customer_fk
        and jz_ss_priority.priority_id = jz_ss_order.priority_id
        and jz_ss_segment.segment_id = jz_ss_order.segment_id
        left join jz_ss_shipmode on jz_ss_shipmode.ship_mode = jz_ss_stage.ship_mode
        minus
        select discount, unit_price, shipping_cost, ship_date, profit, quality_ordered, sales, base_margin, ship_mode_id, product_id, order_fk
        from jz_ss_order_item
      )

select count(*) from jz_ss_order_item




create view jz_ss_superstore_view
as
select p.priority order_priority, 
       oi.discount, 
       oi.unit_price, 
       oi.shipping_cost, 
       c.customer_id, 
       c.first_name||' '||middle_name||' '||last_name customer_name, 
       s.ship_mode,
       seg.seg_name customer_segment,
       ca.category_name product_category,
       ca1.category_name product_sub_category,
       con.container_name product_container,
       pro.product_name,
       oi.base_margin product_base_margin,
       co.country,
       r.region,
       st.state_name state_or_province,
       a.city,
       a.postal_code,
       o.order_date,
       oi.ship_date,
       oi.profit,
       oi.quality_ordered quantity_ordered_new,
       oi.sales,
       o.order_id
from jz_ss_order o
left join jz_ss_priority p on o.priority_id = p.priority_id
left join jz_ss_segment seg on o.segment_id = seg.segment_id
left join jz_ss_customer c on o.customer_fk = c.customer_pk
left join jz_ss_order_item oi on oi.order_fk = o.order_pk
left join jz_ss_shipmode s on oi.ship_mode_id = s.ship_mode_id
left join jz_ss_product pro on oi.product_id = pro.product_id
left join jz_ss_container con on pro.container_id = con.container_id
left join jz_ss_category ca on pro.category_id = ca.category_id
left join jz_ss_category ca1 on ca.category_rid = ca1.category_id 
left join jz_ss_address a on c.customer_pk = a.customer_fk
left join jz_ss_state st on a.state_id = st.state_id
left join jz_ss_region r on st.region_id = r.region_id
left join jz_ss_country co on r.country_id = co.country_id
left join jz_ss_return re on re.order_id = o.order_id
