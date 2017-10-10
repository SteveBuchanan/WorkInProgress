SET NOCOUNT ON


Declare @TableName as varchar(30)
set @TableName = 'FinHub_AdHocPayment_History'

print 'using System;'
print 'using System.Collections.Generic;'
print 'using System.Linq;'
print 'using System.Text;'
print 'using System.Threading.Tasks;'
print 'using System.IO;'
print 'using System.Data;'
print 'using System.Data.SqlClient;'
print 'using System.ComponentModel;'
print 'using System.Runtime.CompilerServices;'
print ''
print ''
print 'namespace Unum.FinanceDataLoader.BusinessObjects'
print '{'
print char(9) + 'public class ' + @TableName + ' : BaseClass'
print char(9) + '{'

-- ======================================================================
-- Get the column information for the member variables and property methods
-- ======================================================================

	SELECT    c.name as 'ColumnName',
		case 
		 when t.Name = 'nvarchar' then 'string'
		 when t.Name = 'varchar' then 'string'
		 when t.Name = 'char' then 'string'
		 when t.Name = 'smallint' then 'int'
		when t.Name = 'bit' then 'bool'	
		 when t.Name = 'real' then 'double'
		 	else t.Name end as  'Datatype',
		c.max_length 'MaxLen',
		c.precision as 'Percision' ,
		c.scale ,
		c.is_nullable,
		ISNULL(i.is_primary_key, 0) 'PrimaryKey'
							,case when t.Name = 'int' then '0;'
					 when t.Name = 'varchar' then 'string.Empty;'
					 when t.Name = 'char' then 'string.Empty;'
					 when t.Name = 'decimal' then '0m;'
					 when t.Name = 'DateTime' then 'DateTime.Now;'
					 else 'null' end as 'Initialze'
	into #ColsBase
	
	FROM   sys.columns c INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
		LEFT OUTER JOIN  sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
		LEFT OUTER JOIN  sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
	WHERE c.object_id = OBJECT_ID(@TableName)

	declare @ColumnName varchar(130)
	declare @DataType varchar(30)
	declare @MaxLen varchar(30)
	declare @Percision varchar(30)
	declare @Scale varchar(30)
	declare @IsNullable varchar(30)
	declare @PrimaryKey varchar(30)
	declare @Initialize varchar(30)
	

	Select * into #ColsTemp
	from #ColsBase

-- ======================================================================
-- Print the member variables
-- ======================================================================
    select top 1 @ColumnName = ColumnName
		, @DataType = DataType
		, @MaxLen = MaxLen
		, @Percision = Percision
		, @Scale = Scale
		,@Initialize = Initialze
	from #ColsTemp

    while @@ROWCOUNT > 0
    begin
		
		if (@DataType = 'datetime')
		begin
		  set @DataType = 'DateTime' 
		 end

		print  char(9) + char(9) + 'private ' + @DataType + ' _' + @ColumnName + ' = ' + @Initialize

		delete from #ColsTemp where columnname = @columnname

	    select top 1 @ColumnName = ColumnName
			, @DataType = DataType
			, @MaxLen = MaxLen
			, @Percision = Percision
			, @Scale = Scale
			,@Initialize = Initialze
		from #ColsTemp
    end

    print ' '
    print ' '

	insert #ColsTemp
	select * from #ColsBase

-- ======================================================================
-- print the methods
-- ======================================================================

    select top 1 @ColumnName = ColumnName
		, @DataType = DataType
		, @MaxLen = MaxLen
		, @Percision = Percision
		, @Scale = Scale
		,@Initialize = Initialze
	from #ColsTemp

    while @@ROWCOUNT > 0
    begin

			if (@DataType = 'datetime')
		begin
		  set @DataType = 'DateTime' 
		 end
--		print char(9) + '[DBBulkInsertColumn("' + @ColumnName + '")]'
        print char(9) + 'public ' + @DataType + ' ' + @ColumnName
        print char(9) + '{'
        print char(9) + char(9) + 'get { return _' + @ColumnName + '; }'
        print char(9) + char(9) +'set { _' + @ColumnName + ' = value; }'
--        print char(9) + char(9) +'set'
--        print char(9) + char(9) +'{'
        --print char(9) + char(9) + char(9) + 'if (_' + @ColumnName + ' != value)'
        --print char(9) + char(9) + char(9) + '{'
--        print char(9) + char(9) + char(9) + char(9) + '_' + @ColumnName + ' = value;'
        --print char(9) + char(9) + char(9) + char(9) + 'OnPropertyChanged();'
        --print char(9) + char(9) + char(9) + ' }'
--        print char(9) + char(9) + '}'
        print char(9) + '}'

		delete from #ColsTemp where columnname = @columnname
		
	    select top 1 @ColumnName = ColumnName
			, @DataType = DataType
			, @MaxLen = MaxLen
			, @Percision = Percision
			, @Scale = Scale
			,@Initialize = Initialze

		from #ColsTemp
    end

    print ' '
    print ' '

-- ======================================================================
-- Print the closing braces
-- ======================================================================
    print char(9) + '}'
    print '}'

    drop table #ColsBase
    drop table #ColsTemp