
DECLARE @TableName VARCHAR(150) =''   --'RoomType'


SET @TableName = IIF(@TableName = '',NULL,@TableName)
DECLARE @Result AS NVARCHAR(MAX) = N''
DECLARE @TBL_Filter TABLE
    (
      id INT IDENTITY(1, 1)
             PRIMARY KEY ,
      Column_Name VARCHAR(50)
    )

INSERT  INTO @TBL_Filter
        ( Column_Name )
VALUES  ( 'CreatedBy' ),
        ( 'CreatedDate' ),
        ( 'ModifiedBy' ),
        ( 'ModifiedDate' ),
        ( 'DeletedBy' ),
        ( 'DeletedDate' ),
        ( 'IdentityGuid' ),
        ( 'VersionGuid' );
WITH    CTE
          AS ( SELECT   info.TABLE_NAME ,
                        INFO.COLUMN_NAME ,
                        DATA_TYPE ,
                        CASE DATA_TYPE
                          WHEN 'int' THEN 'Int32'
                          WHEN 'decimal' THEN 'Decimal'
                          WHEN 'money' THEN 'Decimal'
						  WHEN 'numeric' THEN 'Decimal'
                          WHEN 'char' THEN 'String'
                          WHEN 'nchar' THEN 'String'
                          WHEN 'varchar' THEN 'String'
                          WHEN 'nvarchar' THEN 'String'
                          WHEN 'uniqueidentifier' THEN 'Guid'
                          WHEN 'datetime' THEN 'DateTime'
                          WHEN 'bit' THEN 'Boolean'
                          ELSE 'String'
                        END [DotNetDataType] ,
                        ROW_NUMBER() OVER ( PARTITION BY info.TABLE_NAME ORDER BY info.TABLE_NAME ) ctr ,
                        DENSE_RANK() OVER ( ORDER BY info.TABLE_NAME ) ctr1
               FROM     INFORMATION_SCHEMA.COLUMNS INFO
               WHERE    NOT EXISTS ( SELECT 1
                                     FROM   @TBL_Filter FILT
                                     WHERE  FILT.Column_Name = INFO.COLUMN_NAME )
                        AND TABLE_NAME NOT IN ( '__RefactorLog' )
					    AND TABLE_NAME = ISNULL(@TableName,TABLE_NAME)
             ),
        CTE1
          AS ( SELECT   MAX(TABLE_NAME) TABLE_NAME ,
                        MAX(ctr) ctr ,
                        ctr1
               FROM     CTE
               GROUP BY ctr1
             ),
        CTE2
          AS ( SELECT   cte.TABLE_NAME ,
                        cte.COLUMN_NAME ,
                        cte.DATA_TYPE ,
                        cte.DotNetDataType ,
                        cte.ctr ,
                        cte1.ctr [MaxCtr] ,
                        cte1.ctr1
               FROM     CTE
                        JOIN CTE1 ON CTE1.TABLE_NAME = CTE.TABLE_NAME
             )
    SELECT   @Result = @Result +  IIF(ctr = 1, N'public class ' + TABLE_NAME + ' { [Required] ', IIF(ctr = MaxCtr, 'public '
            + DotNetDataType + ' ' + COLUMN_NAME + '  { get; set;}}
			', 'public '
            + DotNetDataType + ' ' + COLUMN_NAME + '  { get; set;}'))
    FROM    CTE2

	SELECT  @Result [Result please Copy and paste column below]