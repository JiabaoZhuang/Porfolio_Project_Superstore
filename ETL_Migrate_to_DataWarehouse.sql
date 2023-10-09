

-- Priority Dimension


insert into jz_ss_dw_priority(priority_id, order_priority)

select priority_id, order_priority
from (
        select priority_id, priority order_priority
        from jz_ss_priority
        minus
        select priority_id, order_priority
        from jz_ss_dw_priority
      )

select * from jz_ss_dw_priority





-- Segment Dimension

insert into jz_ss_dw_segment(segment_id, seg_name)

select segment_id, seg_name
from (
        select segment_id, seg_name
        from jz_ss_segment
        minus
        select segment_id, seg_name
        from jz_ss_dw_segment
      )

select * from jz_ss_dw_segment






-- Manager Dimension



insert into jz_ss_dw_manager(manager_id, manager)

select manager_id, manager
from (
        select manager_id, manager
        from jz_ss_manager
        minus
        select manager_id, manager
        from jz_ss_dw_manager
      )

select * from jz_ss_dw_manager






-- Date Dimension

insert into jz_ss_dw_date(date_id, date_val, month_dt, quarter, year_dt)

select rownum date_id, my_date date_val, extract(month from my_date) month,
        to_char(my_date, 'yyyy "Q"q') quarter,
        extract(year from my_date) year
from (select to_date('1/1/2015', 'mm/dd/yyyy')+level-1 my_date
      from dual
      connect by level < 366)
      
      
select * from jz_ss_dw_date






-- Ship Mode Dimension



insert into jz_ss_dw_shipmode(ship_mode_id, ship_mode)

select ship_mode_id, ship_mode
from (
        select ship_mode_id, ship_mode 
        from jz_ss_shipmode
        minus
        select ship_mode_id, ship_mode 
        from jz_ss_dw_shipmode
     )

select * from jz_ss_dw_shipmode





-- Location Dimension


insert into jz_ss_dw_location(location_id, country, region, state_name, city, postal_code)

select location_id, country, region, state_name, city, postal_code
from (
        select address_id location_id, country, region, state_name, city, postal_code
        from jz_ss_address
        left join jz_ss_state on jz_ss_state.state_id = jz_ss_address.state_id
        left join jz_ss_region on jz_ss_region.region_id = jz_ss_state.region_id
        left join jz_ss_country on jz_ss_country.country_id = jz_ss_region.country_id
        minus
        select location_id, country, region, state_name, city, postal_code
        from jz_ss_dw_location
     )


select * from jz_ss_dw_location







-- Customer Dimension


insert into jz_ss_dw_customer(customer_pk, customer_id, customer_name)


select customer_pk, customer_id, customer_name
from (
        select customer_pk,
               customer_id,
               case 
                    when middle_name is null then first_name||' '||last_name 
                    else first_name||' '||middle_name||' '||last_name
               end customer_name
        from jz_ss_customer
        minus
        select customer_pk, customer_id, customer_name
        from jz_ss_dw_customer
      )

select * from jz_ss_dw_customer







-- Product Table



insert into jz_ss_dw_product(product_id, product_name, category, sub_category, container_name)

select product_id, product_name, category, sub_category, container_name
from ( 
       select jz_ss_product.product_id, jz_ss_product.product_name, category1.category_name category, jz_ss_category.category_name sub_category, jz_ss_container.container_name
       from jz_ss_product
       left join jz_ss_container on jz_ss_container.container_id = jz_ss_product.container_id
       left join jz_ss_category on jz_ss_category.category_id = jz_ss_product.category_id
       left join jz_ss_category category1 on jz_ss_category.category_rid = category1.category_id
       minus
       select product_id, product_name, category, sub_category, container_name
       from jz_ss_dw_product
       )
       
select * from jz_ss_dw_product






-- Data Table


insert into jz_ss_dw_data(data_id, return_yn, sales, discount, unit_price, shipping_cost, profit, quality_ordered, base_margin, order_id, location_id, customer_fk, segment_id, 
                          order_date_id, ship_date_id, product_id, priority_id, manager_id, ship_mode_id)

select data_id, return_yn, sales, discount, unit_price, shipping_cost, profit, quality_ordered, base_margin, order_id, location_id, customer_fk, segment_id, 
       order_date_id, ship_date_id, product_id, priority_id, manager_id, ship_mode_id
from (
        select  jz_ss_order_item.order_item_id data_id, case when jz_ss_return.status = 'Returned' then 'Y' else 'N' end return_yn, jz_ss_order_item.sales, jz_ss_order_item.discount,
                jz_ss_order_item.unit_price, jz_ss_order_item.shipping_cost, jz_ss_order_item.profit, jz_ss_order_item.quality_ordered, jz_ss_order_item.base_margin,
                jz_ss_order.order_id, jz_ss_address.address_id location_id, jz_ss_customer.customer_pk customer_fk, jz_ss_segment.segment_id, 
                jz_ss_dw_date.date_id order_date_id, date2.date_id ship_date_id, jz_ss_product.product_id, jz_ss_priority.priority_id, 
                jz_ss_manager.manager_id, jz_ss_shipmode.ship_mode_id
        from jz_ss_order_item
        left join jz_ss_order on jz_ss_order_item.order_fk = jz_ss_order.order_pk
        left join jz_ss_shipmode on jz_ss_shipmode.ship_mode_id = jz_ss_order_item.ship_mode_id
        left join jz_ss_product on jz_ss_product.product_id = jz_ss_order_item.product_id
        left join jz_ss_customer on jz_ss_customer.customer_pk = jz_ss_order.customer_fk
        left join jz_ss_priority on jz_ss_priority.priority_id = jz_ss_order.priority_id
        left join jz_ss_return on jz_ss_return.order_id = jz_ss_order.order_id
        left join jz_ss_segment on jz_ss_segment.segment_id = jz_ss_order.segment_id
        left join jz_ss_address on jz_ss_address.customer_fk = jz_ss_customer.customer_pk
        left join jz_ss_state on jz_ss_state.state_id = jz_ss_address.state_id
        left join jz_ss_region on jz_ss_region.region_id = jz_ss_state.region_id
        left join jz_ss_manager on jz_ss_region.region_id = jz_ss_manager.region_id
        left join jz_ss_dw_date on jz_ss_dw_date.date_val = jz_ss_order.order_date
        left join jz_ss_dw_date date2 on date2.date_val = jz_ss_order_item.ship_date
        minus
        select data_id, return_yn, sales, discount, unit_price, shipping_cost, profit, quality_ordered, base_margin, order_id, location_id, customer_fk, segment_id, 
               order_date_id, ship_date_id, product_id, priority_id, manager_id, ship_mode_id
        from jz_ss_dw_data
     )

select * from jz_ss_dw_data







