-- =============================================   
-- Author:  Jhon Esmael C. Agapito   
-- Create date: 3/16/2017   
-- Modified by: Von Aaron Abanes
-- Modified date: 6/15/2017
-- Description: Generate CRUD Stored Procedures 
-- for all tables of the Database provided
-- =============================================   


DECLARE @DBName VARCHAR(100)= 'UEKSDB';
DECLARE @ThisTableOnly VARCHAR(100) = '';
DECLARE @LEGEND VARCHAR(MAX) ,
    @TableSchema VARCHAR(500) ,
    @TableName VARCHAR(500);
DECLARE @MaxCount INTEGER ,
    @Count INTEGER;
DECLARE @UeksTables TABLE
    (
      RowId INT ,
      Table_Schema VARCHAR(500) ,
      Table_Name VARCHAR(500)
    );
DECLARE @TABLECOLS VARCHAR(MAX);
DECLARE @Author VARCHAR(500) ,
    @CreateDate VARCHAR(50);

SET @ThisTableOnly = '';
SET @Author = 'JHON AGAPITO'
SET @CreateDate = CAST(GETDATE() AS VARCHAR)
SET @LEGEND = ''
SET @Count = 1

-- INSERT TABLE AND SCHEMA TO TEMP TABLE
INSERT  INTO @UeksTables
        SELECT  ROW_NUMBER() OVER ( ORDER BY c.TABLE_SCHEMA ASC ) AS RowId ,
                c.TABLE_SCHEMA ,
                c.TABLE_NAME
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.TABLE_CATALOG = @DBName
                AND c.TABLE_NAME NOT IN ('__RefactorLog','tbl_Temp','sysdiagrams')
				AND t.TABLE_TYPE = 'BASE TABLE'
                AND ( @ThisTableOnly = ''
                      OR t.TABLE_NAME = @ThisTableOnly
                    )

        GROUP BY c.TABLE_SCHEMA ,
                c.TABLE_NAME

SELECT  @MaxCount = ( SELECT    MAX(RowId)
                      FROM      @UeksTables
                    ) 

PRINT ( 'use [' + @DBName + ']' )
PRINT 'GO'
WHILE @Count <= @MaxCount
    BEGIN

        SELECT TOP 1
                @TableSchema = Table_Schema ,
                @TableName = Table_Name
        FROM    @UeksTables
        WHERE   RowId = @Count

-------------------------------------------------------------------------------------------------------
-- ADD NEW RECORD SP ----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

        SELECT  @LEGEND = @LEGEND + '
-- =============================================   
-- Author: ' + @Author + '  
-- Create date: ' + @CreateDate + '   
-- Modified by: Von Aaron Abanes
-- Modified date: 6/15/2017
-- Description: Add' + @TableName + '
-- ============================================= 

'
                + IIF(EXISTS ( SELECT   1
                               FROM     sys.objects
                               WHERE    object_id = OBJECT_ID(N'Add'
                                                              + @TableName)
                                        AND type IN ( N'P', N'PC' ) ), 'ALTER PROCEDURE', 'CREATE PROCEDURE')
                + ' [' + @TableSchema + '].[Add' + @TableName + ']  
(' 
        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + ',', '') + '@'
                + c.COLUMN_NAME + ' ' + c.DATA_TYPE
                + IIF(c.CHARACTER_MAXIMUM_LENGTH IS NULL, ' = null ', IIF('('
                + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')' = '(-1)', '(MAX) = null', '('
                + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')  = null '))
                + CHAR(13)
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName
                AND c.COLUMN_NAME NOT IN ( 'Id', 'CreatedDate', 'ModifiedBy',
                                           'ModifiedDate', 'DeletedBy',
                                           'DeletedDate', 'IdentityGuid',
                                           'VersionGuid' )

        SELECT  @LEGEND = @LEGEND + @TABLECOLS 

        SELECT  @LEGEND = @LEGEND + ')
AS' + CHAR(13) + 'BEGIN' + CHAR(13) + CHAR(13);
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED '
                + CHAR(13) + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'INSERT [' + @TableSchema
                + '].[' + @TableName + ']('

        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + ', ', '') + QUOTENAME(c.COLUMN_NAME)
                + ''
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName
                AND c.COLUMN_NAME NOT IN ( 'Id', 'CreatedDate', 'ModifiedBy',
                                           'ModifiedDate', 'DeletedBy',
                                           'DeletedDate', 'IdentityGuid',
                                           'VersionGuid' )

        SELECT  @LEGEND = @LEGEND + @TABLECOLS 
        SELECT  @LEGEND = @LEGEND + ', CreatedDate)' + CHAR(13);
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'VALUES('

        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + ', ', '') + '@'
                + c.COLUMN_NAME + ''
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName
                AND c.COLUMN_NAME NOT IN ( 'Id', 'CreatedDate', 'ModifiedBy',
                                           'ModifiedDate', 'DeletedBy',
                                           'DeletedDate', 'IdentityGuid',
                                           'VersionGuid' )

        SELECT  @LEGEND = @LEGEND + @TABLECOLS 
        SELECT  @LEGEND = @LEGEND + ', GETDATE())' + CHAR(13);
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'SELECT * FROM [' + @TableSchema
                + '].[' + @TableName + '] WHERE Id = @@IDENTITY' + CHAR(13)
                + CHAR(13);
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ COMMITTED ' + CHAR(13)
                + CHAR(13)
        SELECT  @LEGEND = @LEGEND + 'END
GO' + CHAR(13)

        PRINT ( @LEGEND )
        SET @LEGEND = ''
-------------------------------------------------------------------------------------------------------
-- MODIFY RECORD SP -----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
        SELECT  @LEGEND = @LEGEND + '
-- =============================================   
-- Author: ' + @Author + '  
-- Create date: ' + @CreateDate + '   
-- Modified by: Von Aaron Abanes
-- Modified date: 6/15/2017
-- Description: Modify' + @TableName + '
-- ============================================= 
'
                + IIF(EXISTS ( SELECT   1
                               FROM     sys.objects
                               WHERE    object_id = OBJECT_ID(N'Modify'
                                                              + @TableName)
                                        AND type IN ( N'P', N'PC' ) ), 'ALTER PROCEDURE', 'CREATE PROCEDURE')
                + ' [' + @TableSchema + '].[Modify' + @TableName + ']  
(' 
        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + ',', '') + '@'
                + c.COLUMN_NAME + ' ' + c.DATA_TYPE
                + IIF(c.CHARACTER_MAXIMUM_LENGTH IS NULL, ' = null', IIF('('
                + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')' = '(-1)', '(MAX) = null', '('
                + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ') = null'))
                + CHAR(13)
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName
                AND c.COLUMN_NAME NOT IN ( 'CreatedBy', 'CreatedDate',
                                           'ModifiedDate', 'DeletedBy',
                                           'DeletedDate', 'IdentityGuid',
                                           'VersionGuid' )

        SELECT  @LEGEND = @LEGEND + @TABLECOLS 
        SELECT  @LEGEND = @LEGEND + ')
AS' + CHAR(13) + 'BEGIN' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED '
                + CHAR(13) + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'UPDATE [' + @TableSchema
                + '].[' + @TableName + ']' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'SET ' + CHAR(13)

        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + CHAR(9) + CHAR(9) + ',',
                                      CHAR(9) + CHAR(9) + '') + QUOTENAME(c.COLUMN_NAME)
                + ' = @' + c.COLUMN_NAME + CHAR(13)
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName
                AND c.COLUMN_NAME NOT IN ( 'Id', 'CreatedBy', 'CreatedDate',
                                           'ModifiedBy', 'ModifiedDate',
                                           'DeletedBy', 'DeletedDate',
                                           'IdentityGuid', 'VersionGuid' )

        SELECT  @LEGEND = @LEGEND + @TABLECOLS
        SELECT  @LEGEND = @LEGEND + CHAR(9) + CHAR(9)
                + ',ModifiedBy = @ModifiedBy' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + CHAR(9)
                + ',ModifiedDate = GETDATE()' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'WHERE Id = @Id ' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'SELECT * FROM [' + @TableSchema
                + '].[' + @TableName + '] WHERE Id = @Id' + CHAR(13) + CHAR(13);
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ COMMITTED ' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + 'END
GO' + CHAR(13)
        PRINT ( @LEGEND )
        SET @LEGEND = ''
-------------------------------------------------------------------------------------------------------
-- SOFTDELETE RECORD SP -------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

        SELECT  @LEGEND = @LEGEND + '
-- =============================================   
-- Author: ' + @Author + '  
-- Create date: ' + @CreateDate + '   
-- Modified by: Von Aaron Abanes
-- Modified date: 6/15/2017
-- Description: SoftDelete' + @TableName + '
-- ============================================= 
'
                + IIF(EXISTS ( SELECT   1
                               FROM     sys.objects
                               WHERE    object_id = OBJECT_ID(N'SoftDelete'
                                                              + @TableName)
                                        AND type IN ( N'P', N'PC' ) ), 'ALTER PROCEDURE', 'CREATE PROCEDURE')
                + ' [' + @TableSchema + '].[SoftDelete' + @TableName + ']  
(
@Id int,
@ModifiedBy nvarchar(50)
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED   
' 
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'UPDATE [' + @TableSchema
                + '].[' + @TableName + ']' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET DeletedDate = GETDATE(), DeletedBy = @ModifiedBy'
                + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'WHERE Id = @Id AND DeletedDate IS NULL' + CHAR(13)
                + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'SELECT ''Successful'''
                + CHAR(13) + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ COMMITTED' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + 'END
GO' + CHAR(13) 

        PRINT ( @LEGEND )
        SET @LEGEND = ''
-------------------------------------------------------------------------------------------------------
-- GET RECORD SP --------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
        SELECT  @LEGEND = @LEGEND + '
-- =============================================   
-- Author: ' + @Author + '  
-- Create date: ' + @CreateDate + '   
-- Modified by: Von Aaron Abanes
-- Modified date: 6/15/2017
-- Description: GetByFilter' + @TableName + '
-- ============================================= 
'
                + IIF(EXISTS ( SELECT   1
                               FROM     sys.objects
                               WHERE    object_id = OBJECT_ID(N'Get'
                                                              + @TableName
                                                              + 'ByFilter')
                                        AND type IN ( N'P', N'PC' ) ), 'ALTER PROCEDURE', 'CREATE PROCEDURE')
                + ' [' + @TableSchema + '].[Get' + @TableName + 'ByFilter]  

(' 
        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + ',', '') + '@'
                + c.COLUMN_NAME + ' ' + c.DATA_TYPE
                + IIF(c.CHARACTER_MAXIMUM_LENGTH IS NULL, ' = null', IIF('('
                + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')' = '(-1)', '(MAX) = null', '('
                + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ') = null'))
                + CHAR(13)
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName

        SELECT  @LEGEND = @LEGEND + @TABLECOLS 
        SELECT  @LEGEND = @LEGEND + ')
AS' + CHAR(13) + 'BEGIN' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED '
                + CHAR(13) + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'SELECT ' + CHAR(13)

        SET @TABLECOLS = NULL;
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + CHAR(9) + CHAR(9) + ',',
                                      CHAR(9) + CHAR(9) + '') + '['
                + c.COLUMN_NAME + ']' + CHAR(13)
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName

        SELECT  @LEGEND = @LEGEND + @TABLECOLS
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'FROM [' + @TableSchema + '].['
                + @TableName + ']' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + 'WHERE' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9) + CHAR(9)
                + '[DeletedDate] IS NULL' + CHAR(13)

        SET @TABLECOLS = ' ';
        SELECT  @TABLECOLS = COALESCE(@TABLECOLS + CHAR(9) + CHAR(9) + 'AND ',
                                      CHAR(9) + CHAR(9) + '') + '(@'
                + c.COLUMN_NAME + ' IS NULL OR [' + c.COLUMN_NAME + '] = @'
                +  c.COLUMN_NAME + ')' + CHAR(13)
        FROM    INFORMATION_SCHEMA.Columns c
                INNER JOIN INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
        WHERE   t.Table_Catalog = @DBName
                AND t.TABLE_TYPE = 'BASE TABLE'
                AND t.TABLE_NAME = @TableName

        SELECT  @LEGEND = @LEGEND + @TABLECOLS + CHAR(13)
        SELECT  @LEGEND = @LEGEND + CHAR(9)
                + 'SET TRANSACTION ISOLATION LEVEL READ COMMITTED' + CHAR(13)
        SELECT  @LEGEND = @LEGEND + 'END
GO' + CHAR(13)

        PRINT ( @LEGEND )
        SET @LEGEND = ''

        SET @Count = @Count + 1
    END

