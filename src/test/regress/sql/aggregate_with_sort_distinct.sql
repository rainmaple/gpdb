drop schema if exists agg_sort_distinct_regress_schema cascade;
create schema if not exists agg_sort_distinct_regress_schema;

set search_path to agg_sort_distinct_regress_schema;

create table test_multi_order_agg(a int, b int);

insert into test_multi_order_agg values (1, 1), (1, null), (null, 1);

set gp_enable_sort_distinct to on;
select string_agg(a::text, ','), string_agg(distinct b::text, ',') from test_multi_order_agg;
select string_agg(a::text, ',' order by b), string_agg(distinct b::text, ',') from test_multi_order_agg;

set gp_enable_sort_distinct to off;
select string_agg(a::text, ','), string_agg(distinct b::text, ',') from test_multi_order_agg;
select string_agg(a::text, ',' order by b), string_agg(distinct b::text, ',') from test_multi_order_agg;
