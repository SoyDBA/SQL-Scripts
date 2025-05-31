--========================================
-- Habilitar llamadas API
--========================================
USE master;
GO
sp_configure 'external rest endpoint enabled', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

--========================================
-- Habilitar índices en vectores (SOLO PREVIEW)
--========================================
DBCC TRACEON(466, 474, 13981, -1)

--========================================
-- Crear credencial
--========================================
USE [AdventureWorks];
GO
-- Master Key
if not exists(select * from sys.symmetric_keys where [name] = '##MS_DatabaseMasterKey##')
begin
    create master key encryption by password = N'NoEsMiContras3ñ@';
end
go
-- Credencial
if exists(select * from sys.[database_scoped_credentials] where name = 'https://testaisoydba.openai.azure.com') -- Nombre de la credencial (Endpoint Azure OpenAI)
begin
	drop database scoped credential [https://testaisoydba.openai.azure.com]; -- Nombre de la credencial (Endpoint Azure OpenAI)
end
create database scoped credential [https://testaisoydba.openai.azure.com] -- Nombre de la credencial (Endpoint Azure OpenAI)
with identity = 'HTTPEndpointHeaders', secret = '{"api-key": "*****************************************"}'; -- API KEY Open AI
go

--========================================
-- Crear SP genera embeddings
--========================================
USE [AdventureWorks]
GO
create or alter procedure [get_embedding]
@inputText nvarchar(max),
@embedding vector(1536) output
as
begin try
    declare @retval int;
    declare @payload nvarchar(max) = json_object('input': @inputText);
    declare @response nvarchar(max)

    declare @url nvarchar(1000) = 'https://testaisoydba.openai.azure.com/openai/deployments/text-embedding-ada-002/embeddings?api-version=2023-05-15' -- URL modelo (Azure AI Foundry ADA 2)
    exec @retval = sp_invoke_external_rest_endpoint
    @url = @url,
    @method = 'POST',
    @credential = [https://testaisoydba.openai.azure.com], -- Nombre de la credencial (Endpoint Azure OpenAI)
    @payload = @payload,
    @response = @response output;
end try
begin catch
    select 
        'SQL' as error_source, 
        error_number() as error_code,
        error_message() as error_message
    return;
end catch

if (@retval != 0) begin
    select 
        'OPENAI' as error_source, 
        json_value(@response, '$.result.error.code') as error_code,
        json_value(@response, '$.result.error.message') as error_message,
        @response as error_response
    return;
end;

set @embedding = cast(json_query(@response, '$.result.data[0].embedding') as vector(1536))

return @retval
GO

--========================================
-- Crear embeddings
--========================================

USE AdventureWorks;
GO
-- Crea nueva tabla para embeddings de productos
DROP TABLE IF EXISTS Production.ProductDescriptionEmbeddings;
GO
CREATE TABLE Production.ProductDescriptionEmbeddings
( 
  ProductDescEmbeddingID INT IDENTITY NOT NULL PRIMARY KEY CLUSTERED, -- Need a single column as cl index to support vector index reqs
  ProductID INT NOT NULL,
  ProductDescriptionID INT NOT NULL,
  ProductModelID INT NOT NULL,
  CultureID nchar(6) NOT NULL,
  Embedding vector(1536)
);
-- Copiar filas relevantes de productos
-- Need to make sure and only get Products that have ProductModels
INSERT INTO Production.ProductDescriptionEmbeddings
SELECT p.ProductID, pmpdc.ProductDescriptionID, pmpdc.ProductModelID, pmpdc.CultureID, NULL
FROM Production.ProductModelProductDescriptionCulture pmpdc
JOIN Production.Product p
ON pmpdc.ProductModelID = p.ProductModelID
ORDER BY p.ProductID;
GO

-- Crear clave única alternativa
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductDescriptionEmbeddings_AlternateKey]
ON [Production].[ProductDescriptionEmbeddings]
(
    [ProductID] ASC,
    [ProductModelID] ASC,
    [ProductDescriptionID] ASC,
    [CultureID] ASC
);
GO

-- Generar Embeddings

USE [AdventureWorks];
GO
DECLARE @ProductName NVARCHAR(50);
DECLARE @ProductModelName NVARCHAR(50);
DECLARE @Description NVARCHAR(400);
DECLARE @ProductID INT;
DECLARE @ProductModelID INT;
DECLARE @ProductDescriptionID INT;
DECLARE @CultureID NCHAR(6);
DECLARE @vector vector(1536);
DECLARE @text nvarchar(max);
DECLARE @i INT = 1;

BEGIN TRAN
-- Proceso fila a fila
DECLARE ProductCursor CURSOR FOR
SELECT p.Name, pm.Name, pd.Description, pde.ProductID, pde.ProductModelID, pde.ProductDescriptionID, pde.CultureID
FROM Production.ProductDescription pd
JOIN Production.ProductDescriptionEmbeddings pde
    ON pd.ProductDescriptionID = pde.ProductDescriptionID
JOIN Production.Product p
    ON p.ProductID = pde.ProductID
JOIN Production.ProductModel pm
    ON pm.ProductModelID = p.ProductModelID

OPEN ProductCursor;

FETCH NEXT FROM ProductCursor INTO @ProductName, @ProductModelName, @Description, @ProductID, @ProductModelID, @ProductDescriptionID, @CultureID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @text = (SELECT 'Name: ' + @ProductName + ', Description: ' + @Description);

    EXEC get_embedding @text, @vector output;

    UPDATE Production.ProductDescriptionEmbeddings SET Embedding = @vector
    WHERE ProductID = @ProductID
    AND ProductModelID = @ProductModelID
    AND ProductDescriptionID = @ProductDescriptionID
    AND CultureID = @CultureID;

    FETCH NEXT FROM ProductCursor INTO @ProductName, @ProductModelName, @Description, @ProductID, @ProductModelID, @ProductDescriptionID, @CultureID;
    PRINT cast(@i as varchar(5)) + ' || ' +  cast(@vector as varchar(max));

    if @i % 50 = 0
	BEGIN
       WAITFOR DELAY '00:1:00'; -- Esperar 1 minuto, cada 50 items (OpenAI API rate limite)
    END

    SET @i = @i + 1;
END

COMMIT TRAN;

CLOSE ProductCursor;
DEALLOCATE ProductCursor;

--========================================
-- Crear SP busqueda semantica productos
--========================================

USE [AdventureWorks];
GO

CREATE OR ALTER procedure [find_relevant_products]
@prompt nvarchar(max), -- Entrada prompt
@stock smallint = 500, -- Filtro Stock, el usaurio puede cambiarlo
@top int = 10, -- Top 10 productos, el usaurio puede cambiarlo
@min_similarity decimal(19,16) = 0.3 -- Nivel minimo similitud, el usaurio puede cambiarlo
as
if (@prompt is null) return;

declare @retval int, @vector vector(1536);

exec @retval = get_embedding @prompt, @vector output;

if (@retval != 0) return;

-- Usa la funcion vector_distance para localizar productos
-- Busqueda híbrida stock >= @stock

with cteSimilarEmbeddings as 
(
    select 
    top(@top)
        pde.ProductID, pde.ProductModelID, pde.ProductDescriptionID, pde.CultureID, 
        vector_distance('cosine', pde.[Embedding], @vector) as distance
    from 
        Production.ProductDescriptionEmbeddings pde
    order by
        distance 
)
select p.Name as ProductName, pd.Description as ProductDescription, p.SafetyStockLevel as StockQuantity
from 
  cteSimilarEmbeddings se
join
  Production.Product p
on p.ProductID = se.ProductID
join
  Production.ProductDescription pd
on pd.ProductDescriptionID = se.ProductDescriptionID
where   
 (1-distance) > @min_similarity
and
  p.SafetyStockLevel >= @stock
order by    
  distance asc;
GO

--========================================
-- DEMO
--========================================

USE [AdventureWorks];
GO
EXEC find_relevant_products 
@prompt = N'Show me the best products for riding on rough ground', 
@stock = 100, 
@top = 20;
GO

USE [AdventureWorks];
GO
EXEC find_relevant_products 
@prompt = N'Quiero una bicicleta para hacer descenso de montaña', 
@stock = 100, 
@top = 20;
GO


EXEC find_relevant_products 
@prompt = N'Quiero una bicicleta para participar en carreras de carretera', 
@stock = 100, 
@top = 20;
GO

