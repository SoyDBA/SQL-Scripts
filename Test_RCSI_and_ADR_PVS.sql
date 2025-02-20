use [master]
-- Drop databases if they exist to start fresh
drop database if exists Test;
drop database if exists Test_ADR;
drop database if exists Test_ADR_RCSI;
drop database if exists Test_RCSI;

go
-- Create the databases with consistent settings
create database Test;
create database Test_ADR;
alter database Test_ADR set ACCELERATED_DATABASE_RECOVERY = ON;
create database Test_RCSI;
alter database Test_RCSI set READ_COMMITTED_SNAPSHOT ON;
create database Test_ADR_RCSI;
alter database Test_ADR_RCSI set ACCELERATED_DATABASE_RECOVERY = ON;
alter database Test_ADR_RCSI set READ_COMMITTED_SNAPSHOT ON;

go
-- Create an identical table in each database
use Test;
go
create table dbo.Products 
(
    Id int identity(1,1) primary key clustered,
    ProductName nvarchar(100) not null,
    QtyInStock int not null
);
create index IX_ProductName on dbo.Products(ProductName);
create index IX_QtyInStock on dbo.Products(QtyInStock);

go
use Test_ADR;
go
create table dbo.Products 
(
    Id int identity(1,1) primary key clustered,
    ProductName nvarchar(100) not null,
    QtyInStock int not null
);
create index IX_ProductName on dbo.Products(ProductName);
create index IX_QtyInStock on dbo.Products(QtyInStock);

go
use Test_RCSI;
go
create table dbo.Products 
(
    Id int identity(1,1) primary key clustered,
    ProductName nvarchar(100) not null,
    QtyInStock int not null
);
create index IX_ProductName on dbo.Products(ProductName);
create index IX_QtyInStock on dbo.Products(QtyInStock);

go
use Test_ADR_RCSI;
go
create table dbo.Products 
(
    Id int identity(1,1) primary key clustered,
    ProductName nvarchar(100) not null,
    QtyInStock int not null
);
create index IX_ProductName on dbo.Products(ProductName);
create index IX_QtyInStock on dbo.Products(QtyInStock);

go
-- Insert 1 million rows using sys.objects and a cross join
use Test;
go
insert into dbo.Products (ProductName, QtyInStock)
select top (1000000) 'Product ' + cast(row_number() over(order by (select null)) as nvarchar(10)), abs(checksum(newid()) % 1000)
from sys.objects o1
cross join sys.objects o2
cross join sys.objects o3
cross join sys.objects o4;

go
use Test_ADR;
go
insert into dbo.Products (ProductName, QtyInStock)
select ProductName, QtyInStock from Test.dbo.Products;

go
use Test_RCSI;
go
insert into dbo.Products (ProductName, QtyInStock)
select ProductName, QtyInStock from Test.dbo.Products;

go
use Test_ADR_RCSI;
go
insert into dbo.Products (ProductName, QtyInStock)
select ProductName, QtyInStock from Test.dbo.Products;

go
-- Check page usage 
use Test;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');

-- Rebuild index
alter index all on test.dbo.Products rebuild;
alter index all on test_ADR.dbo.Products rebuild;
alter index all on test_RCSI.dbo.Products rebuild;
alter index all on test_ADR_RCSI.dbo.Products rebuild;



-- Recheck page usage after rebuild
use Test;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');



go
-- Update some rows and perform index rebuild
use Test;
go
update dbo.Products set QtyInStock = QtyInStock + 10 where Id % 100 = 0;
go
use Test_ADR;
go
update dbo.Products set QtyInStock = QtyInStock + 10 where Id % 100 = 0;
go
use Test_RCSI;
go
update dbo.Products set QtyInStock = QtyInStock + 10 where Id % 100 = 0;
go
use Test_ADR_RCSI;
go
update dbo.Products set QtyInStock = QtyInStock + 10 where Id % 100 = 0;
go


-- Recheck page usage after Updates
use Test;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');



-- Rebuild index
alter index all on test.dbo.Products rebuild;
alter index all on test_ADR.dbo.Products rebuild;
alter index all on test_RCSI.dbo.Products rebuild;
alter index all on test_ADR_RCSI.dbo.Products rebuild;



-- Recheck page usage after rebuild
use Test;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');
use Test_ADR_RCSI;
GO
select db_name(database_id) as DatabaseName, object_name(object_id) as TableName, index_id, partition_number, page_count
from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Products'), null, null, 'DETAILED');

