-- Script y demo original de Brent Ozar https://www.brentozar.com/
-- Comentado en español por Roberto Carrancio https://www.soydba.es/

-- Borramos las bases de datos en caso de que existan para iniciar de cero la demo
DROP DATABASE IF EXISTS Test;
DROP DATABASE IF EXISTS Test_ADR;
DROP DATABASE IF EXISTS Test_ADR_RCSI;
DROP DATABASE IF EXISTS Test_RCSI;

-- Creamos la base de datos de prueba con la configuración por defecto y otra con ADR activado
CREATE DATABASE Test;
CREATE DATABASE Test_ADR;
ALTER DATABASE Test_ADR SET ACCELERATED_DATABASE_RECOVERY = ON;
GO
-- Creamos la misma tabla e insertamos los mismos datos en las dos bases de datos
CREATE TABLE Test.dbo.Products 
	(Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	 ProductName NVARCHAR(100) INDEX IX_ProductName,
	 QtyInStock INT INDEX IX_QtyInStock); 
GO
CREATE TABLE Test_ADR.dbo.Products_ADR
	(Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	 ProductName NVARCHAR(100) INDEX IX_ProductName,
	 QtyInStock INT INDEX IX_QtyInStock); 
GO
WITH Cuisines AS
(
    SELECT Cuisine
	FROM (VALUES
		('Italian'), ('Mexican'), ('Chinese'), ('Japanese'),
		('Indian'), ('French'), ('Greek'), ('Spanish'), 
		('Korean'), ('Thai'), ('Cajun'), ('Cuban'), ('Moroccan'), 
		('Turkish'), ('Lebanese'), ('Vietnamese'), ('Filipino'), 
		('Ethiopian'), ('Caribbean'), ('Brazilian'), ('Peruvian'), 
		('Argentinian'), ('German'), ('Russian'), ('Polish'), 
		('Hungarian'), ('Swiss'), ('Swedish'), ('Norwegian'), 
		('Danish'), ('Portuguese'), ('Irish'), ('Scottish'), 
		('English'), ('American'), ('Hawaiian'), ('Middle Eastern'), 
		('Afghan'), ('Pakistani'), ('Bangladeshi'), ('Nepalese'), 
		('Sri Lankan'), ('Tibetan'), ('Malay'), ('Indonesian'), 
		('Singaporean'), ('Malaysian'), ('Burmese'), ('Laotian'), 
		('Cambodian'), ('Mongolian'), ('Uzbek'), ('Kazakh'), 
		('Georgian'), ('Azerbaijani'), ('Armenian'), ('Persian'), 
		('Iraqi'), ('Syrian'), ('Jordanian'), ('Saudi Arabian'), 
		('Israeli'), ('Palestinian'), ('Yemeni'), ('Sudanese'), 
		('Somali'), ('Kenyan'), ('Tanzanian'), ('Ugandan'), 
		('Zimbabwean'), ('South African'), ('Nigerian'), ('Ghanaian'), 
		('Senegalese'), ('Ivory Coast'), ('Cameroonian'), 
		('Malagasy'), ('Australian'), ('New Zealand'), ('Canadian'), 
		('Chilean'), ('Colombian'), ('Venezuelan'), ('Ecuadorian'), 
		('Paraguayan'), ('Uruguayan'), ('Bolivian'), ('Guatemalan'), 
		('Honduran'), ('Nicaraguan'), ('Salvadoran'), ('Costa Rican'), 
		('Panamanian'), ('Belizean'), ('Jamaican'), ('Trinidadian'), 
		('Barbadian'), ('Bahamian'), ('Antiguan'), ('Grenadian'),
		('Grandma''s'), ('Grandpa''s')
	) AS t(Cuisine)
),
Adjectives AS
(
    SELECT Adjective
	FROM (VALUES
		('Spicy'), ('Savory'), ('Sweet'), ('Creamy'), ('Crunchy'),
		('Zesty'), ('Tangy'), ('Hearty'), ('Fragrant'), ('Juicy'),
		('Crispy'), ('Delicious'), ('Mouthwatering'), ('Toasted'),
		('Smoky'), ('Rich'), ('Light'), ('Buttery'), ('Tender'),
		('Flaky'), ('Succulent'), ('Bitter'), ('Peppery'), ('Charred'),
		('Piquant'), ('Nutty'), ('Velvety'), ('Chewy'), ('Silky'),
		('Golden'), ('Satisfying'), ('Gooey'), ('Caramelized'), ('Luscious'),
		('Hot'), ('Cool'), ('Bold'), ('Earthy'), ('Subtle'),
		('Vibrant'), ('Doughy'), ('Garlicky'), ('Herby'), ('Tangy'),
		('Mild'), ('Spiced'), ('Infused'), ('Ripe'), ('Fresh'),
		('Citrusy'), ('Tart'), ('Pickled'), ('Fermented'), ('Umami'),
		('Wholesome'), ('Decadent'), ('Savoured'), ('Fizzy'), ('Effervescent'),
		('Melty'), ('Sticky'), ('Toothsome'), ('Crumbly'), ('Roasted'),
		('Boiled'), ('Braised'), ('Fried'), ('Baked'), ('Grilled'),
		('Steamed'), ('Seared'), ('Broiled'), ('Poached'), ('Simmered'),
		('Marinated'), ('Dusted'), ('Drizzled'), ('Glazed'), ('Charred'),
		('Seared'), ('Plated'), ('Whipped'), ('Fluffy'), ('Homemade'),
		('Comforting'), ('Heartwarming'), ('Filling'), ('Juicy'), ('Piping'),
		('Savored'), ('Seasoned'), ('Briny'), ('Doused'), ('Herbed'),
		('Basted'), ('Crusted'), ('Topped'), ('Pressed'), ('Folded'),
		('Layered'), ('Stuffed')
	) AS t(Adjective)
),
Dishes AS
(
    SELECT Dish
	FROM (VALUES
		('Pizza'), ('Taco'), ('Noodles'), ('Sushi'), ('Curry'),
		('Soup'), ('Burger'), ('Salad'), ('Sandwich'), ('Stew'),
		('Pasta'), ('Fried Rice'), ('Dumplings'), ('Wrap'),
		('Pancakes'), ('Stir Fry'), ('Casserole'), ('Quiche'), ('Ramen'),
		('Burrito'), ('Chow Mein'), ('Spring Rolls'), ('Lasagna'), ('Paella'),
		('Risotto'), ('Pho'), ('Gyoza'), ('Chili'), ('Bisque'),
		('Frittata'), ('Toast'), ('Nachos'), ('Bagel'), ('Croissant'),
		('Waffles'), ('Crepes'), ('Omelette'), ('Tart'), ('Brownies'),
		('Cupcakes'), ('Muffins'), ('Samosa'), ('Enchiladas'), ('Tikka Masala'),
		('Shawarma'), ('Kebab'), ('Falafel'), ('Meatballs'), ('Casserole'),
		('Pot Pie'), ('Fajitas'), ('Ravioli'), ('Calzone'), ('Empanadas'),
		('Bruschetta'), ('Ciabatta'), ('Donuts'), ('Macaroni'), ('Clam Chowder'),
		('Gazpacho'), ('Gnocchi'), ('Ratatouille'), ('Poke Bowl'), ('Hotdog'),
		('Fried Chicken'), ('Churros'), ('Stuffed Peppers'), ('Fish Tacos'), ('Kabobs'),
		('Mashed Potatoes'), ('Pad Thai'), ('Bibimbap'), ('Kimchi Stew'), ('Tteokbokki'),
		('Tamales'), ('Meatloaf'), ('Cornbread'), ('Cheesecake'), ('Gelato'),
		('Sorbet'), ('Ice Cream'), ('Pavlova'), ('Tiramisu'), ('Custard'),
		('Flan'), ('Bread Pudding'), ('Trifle'), ('Cobbler'), ('Shortcake'),
		('Soufflé'), ('Eclairs'), ('Cannoli'), ('Baklava'), ('Pecan Pie'),
		('Apple Pie'), ('Focaccia'), ('Stromboli'), ('Beignets'), ('Yorkshire Pudding')
	) AS t(Dish)
)
INSERT INTO Test.dbo.Products (ProductName, QtyInStock)
	SELECT TOP 1000000 a.Adjective + ' ' + c.Cuisine + ' ' + d.Dish, 1
	FROM Cuisines c
	CROSS JOIN Adjectives a
	CROSS JOIN Dishes d
	ORDER BY NEWID();

;WITH Cuisines AS
(
    SELECT Cuisine
	FROM (VALUES
		('Italian'), ('Mexican'), ('Chinese'), ('Japanese'),
		('Indian'), ('French'), ('Greek'), ('Spanish'), 
		('Korean'), ('Thai'), ('Cajun'), ('Cuban'), ('Moroccan'), 
		('Turkish'), ('Lebanese'), ('Vietnamese'), ('Filipino'), 
		('Ethiopian'), ('Caribbean'), ('Brazilian'), ('Peruvian'), 
		('Argentinian'), ('German'), ('Russian'), ('Polish'), 
		('Hungarian'), ('Swiss'), ('Swedish'), ('Norwegian'), 
		('Danish'), ('Portuguese'), ('Irish'), ('Scottish'), 
		('English'), ('American'), ('Hawaiian'), ('Middle Eastern'), 
		('Afghan'), ('Pakistani'), ('Bangladeshi'), ('Nepalese'), 
		('Sri Lankan'), ('Tibetan'), ('Malay'), ('Indonesian'), 
		('Singaporean'), ('Malaysian'), ('Burmese'), ('Laotian'), 
		('Cambodian'), ('Mongolian'), ('Uzbek'), ('Kazakh'), 
		('Georgian'), ('Azerbaijani'), ('Armenian'), ('Persian'), 
		('Iraqi'), ('Syrian'), ('Jordanian'), ('Saudi Arabian'), 
		('Israeli'), ('Palestinian'), ('Yemeni'), ('Sudanese'), 
		('Somali'), ('Kenyan'), ('Tanzanian'), ('Ugandan'), 
		('Zimbabwean'), ('South African'), ('Nigerian'), ('Ghanaian'), 
		('Senegalese'), ('Ivory Coast'), ('Cameroonian'), 
		('Malagasy'), ('Australian'), ('New Zealand'), ('Canadian'), 
		('Chilean'), ('Colombian'), ('Venezuelan'), ('Ecuadorian'), 
		('Paraguayan'), ('Uruguayan'), ('Bolivian'), ('Guatemalan'), 
		('Honduran'), ('Nicaraguan'), ('Salvadoran'), ('Costa Rican'), 
		('Panamanian'), ('Belizean'), ('Jamaican'), ('Trinidadian'), 
		('Barbadian'), ('Bahamian'), ('Antiguan'), ('Grenadian'),
		('Grandma''s'), ('Grandpa''s')
	) AS t(Cuisine)
),
Adjectives AS
(
    SELECT Adjective
	FROM (VALUES
		('Spicy'), ('Savory'), ('Sweet'), ('Creamy'), ('Crunchy'),
		('Zesty'), ('Tangy'), ('Hearty'), ('Fragrant'), ('Juicy'),
		('Crispy'), ('Delicious'), ('Mouthwatering'), ('Toasted'),
		('Smoky'), ('Rich'), ('Light'), ('Buttery'), ('Tender'),
		('Flaky'), ('Succulent'), ('Bitter'), ('Peppery'), ('Charred'),
		('Piquant'), ('Nutty'), ('Velvety'), ('Chewy'), ('Silky'),
		('Golden'), ('Satisfying'), ('Gooey'), ('Caramelized'), ('Luscious'),
		('Hot'), ('Cool'), ('Bold'), ('Earthy'), ('Subtle'),
		('Vibrant'), ('Doughy'), ('Garlicky'), ('Herby'), ('Tangy'),
		('Mild'), ('Spiced'), ('Infused'), ('Ripe'), ('Fresh'),
		('Citrusy'), ('Tart'), ('Pickled'), ('Fermented'), ('Umami'),
		('Wholesome'), ('Decadent'), ('Savoured'), ('Fizzy'), ('Effervescent'),
		('Melty'), ('Sticky'), ('Toothsome'), ('Crumbly'), ('Roasted'),
		('Boiled'), ('Braised'), ('Fried'), ('Baked'), ('Grilled'),
		('Steamed'), ('Seared'), ('Broiled'), ('Poached'), ('Simmered'),
		('Marinated'), ('Dusted'), ('Drizzled'), ('Glazed'), ('Charred'),
		('Seared'), ('Plated'), ('Whipped'), ('Fluffy'), ('Homemade'),
		('Comforting'), ('Heartwarming'), ('Filling'), ('Juicy'), ('Piping'),
		('Savored'), ('Seasoned'), ('Briny'), ('Doused'), ('Herbed'),
		('Basted'), ('Crusted'), ('Topped'), ('Pressed'), ('Folded'),
		('Layered'), ('Stuffed')
	) AS t(Adjective)
),
Dishes AS
(
    SELECT Dish
	FROM (VALUES
		('Pizza'), ('Taco'), ('Noodles'), ('Sushi'), ('Curry'),
		('Soup'), ('Burger'), ('Salad'), ('Sandwich'), ('Stew'),
		('Pasta'), ('Fried Rice'), ('Dumplings'), ('Wrap'),
		('Pancakes'), ('Stir Fry'), ('Casserole'), ('Quiche'), ('Ramen'),
		('Burrito'), ('Chow Mein'), ('Spring Rolls'), ('Lasagna'), ('Paella'),
		('Risotto'), ('Pho'), ('Gyoza'), ('Chili'), ('Bisque'),
		('Frittata'), ('Toast'), ('Nachos'), ('Bagel'), ('Croissant'),
		('Waffles'), ('Crepes'), ('Omelette'), ('Tart'), ('Brownies'),
		('Cupcakes'), ('Muffins'), ('Samosa'), ('Enchiladas'), ('Tikka Masala'),
		('Shawarma'), ('Kebab'), ('Falafel'), ('Meatballs'), ('Casserole'),
		('Pot Pie'), ('Fajitas'), ('Ravioli'), ('Calzone'), ('Empanadas'),
		('Bruschetta'), ('Ciabatta'), ('Donuts'), ('Macaroni'), ('Clam Chowder'),
		('Gazpacho'), ('Gnocchi'), ('Ratatouille'), ('Poke Bowl'), ('Hotdog'),
		('Fried Chicken'), ('Churros'), ('Stuffed Peppers'), ('Fish Tacos'), ('Kabobs'),
		('Mashed Potatoes'), ('Pad Thai'), ('Bibimbap'), ('Kimchi Stew'), ('Tteokbokki'),
		('Tamales'), ('Meatloaf'), ('Cornbread'), ('Cheesecake'), ('Gelato'),
		('Sorbet'), ('Ice Cream'), ('Pavlova'), ('Tiramisu'), ('Custard'),
		('Flan'), ('Bread Pudding'), ('Trifle'), ('Cobbler'), ('Shortcake'),
		('Soufflé'), ('Eclairs'), ('Cannoli'), ('Baklava'), ('Pecan Pie'),
		('Apple Pie'), ('Focaccia'), ('Stromboli'), ('Beignets'), ('Yorkshire Pudding')
	) AS t(Dish)
)
INSERT INTO Test_ADR.dbo.Products_ADR (ProductName, QtyInStock)
	SELECT TOP 1000000 a.Adjective + ' ' + c.Cuisine + ' ' + d.Dish, 1
	FROM Cuisines c
	CROSS JOIN Adjectives a
	CROSS JOIN Dishes d
	ORDER BY NEWID();
GO
-- SELECCIONAMOS 100 registros de la tablas
SELECT TOP 100 * FROM Test.dbo.Products;
SELECT TOP 100 * FROM Test_ADR.dbo.Products_ADR;

-- Comprobamos en espacio ocupado por los índices
EXEC sp_BlitzIndex @DatabaseName = 'Test', @TableName = 'Products';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR', @TableName = 'Products_ADR';
GO
-- En este punto podemos comprobar que los índices de la tabla en la base de datos con ADR ocupan más.
-- Esto es porque ADR añade una marca de tiempo que no vemos para el seguimiento de las filas.
-- Podriamos pensar que esta marca de tiempo ocupa espacio extra.

-- Vamos a reconstruir los índices para ordenar los datos tras las inserciones y liberar el espacio disponible
ALTER INDEX ALL ON Test.dbo.Products REBUILD;
ALTER INDEX ALL ON Test_ADR.dbo.Products_ADR REBUILD;
GO

-- Ahora volvemos a verificar el espacio ocupado
EXEC sp_BlitzIndex @DatabaseName = 'Test', @TableName = 'Products';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR', @TableName = 'Products_ADR';
GO
-- Los índices de la base de datos con ADR ocupan lo mismo que los de la base de datos sin ADR
-- Descartamos entonces la teoría del espacio extra de la marca de tiempo.

-- Repitamos ahora la prueba con una base de datos con ADR + RCSI y con una solo con RCSI
CREATE DATABASE Test_ADR_RCSI;
ALTER DATABASE Test_ADR_RCSI SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE Test_ADR_RCSI SET READ_COMMITTED_SNAPSHOT ON;
GO

CREATE TABLE Test_ADR_RCSI.dbo.Products_ADR_RCSI
	(Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	 ProductName NVARCHAR(100) INDEX IX_ProductName,
	 QtyInStock INT INDEX IX_QtyInStock); 
GO
WITH Cuisines AS
(
    SELECT Cuisine
	FROM (VALUES
		('Italian'), ('Mexican'), ('Chinese'), ('Japanese'),
		('Indian'), ('French'), ('Greek'), ('Spanish'), 
		('Korean'), ('Thai'), ('Cajun'), ('Cuban'), ('Moroccan'), 
		('Turkish'), ('Lebanese'), ('Vietnamese'), ('Filipino'), 
		('Ethiopian'), ('Caribbean'), ('Brazilian'), ('Peruvian'), 
		('Argentinian'), ('German'), ('Russian'), ('Polish'), 
		('Hungarian'), ('Swiss'), ('Swedish'), ('Norwegian'), 
		('Danish'), ('Portuguese'), ('Irish'), ('Scottish'), 
		('English'), ('American'), ('Hawaiian'), ('Middle Eastern'), 
		('Afghan'), ('Pakistani'), ('Bangladeshi'), ('Nepalese'), 
		('Sri Lankan'), ('Tibetan'), ('Malay'), ('Indonesian'), 
		('Singaporean'), ('Malaysian'), ('Burmese'), ('Laotian'), 
		('Cambodian'), ('Mongolian'), ('Uzbek'), ('Kazakh'), 
		('Georgian'), ('Azerbaijani'), ('Armenian'), ('Persian'), 
		('Iraqi'), ('Syrian'), ('Jordanian'), ('Saudi Arabian'), 
		('Israeli'), ('Palestinian'), ('Yemeni'), ('Sudanese'), 
		('Somali'), ('Kenyan'), ('Tanzanian'), ('Ugandan'), 
		('Zimbabwean'), ('South African'), ('Nigerian'), ('Ghanaian'), 
		('Senegalese'), ('Ivory Coast'), ('Cameroonian'), 
		('Malagasy'), ('Australian'), ('New Zealand'), ('Canadian'), 
		('Chilean'), ('Colombian'), ('Venezuelan'), ('Ecuadorian'), 
		('Paraguayan'), ('Uruguayan'), ('Bolivian'), ('Guatemalan'), 
		('Honduran'), ('Nicaraguan'), ('Salvadoran'), ('Costa Rican'), 
		('Panamanian'), ('Belizean'), ('Jamaican'), ('Trinidadian'), 
		('Barbadian'), ('Bahamian'), ('Antiguan'), ('Grenadian'),
		('Grandma''s'), ('Grandpa''s')
	) AS t(Cuisine)
),
Adjectives AS
(
    SELECT Adjective
	FROM (VALUES
		('Spicy'), ('Savory'), ('Sweet'), ('Creamy'), ('Crunchy'),
		('Zesty'), ('Tangy'), ('Hearty'), ('Fragrant'), ('Juicy'),
		('Crispy'), ('Delicious'), ('Mouthwatering'), ('Toasted'),
		('Smoky'), ('Rich'), ('Light'), ('Buttery'), ('Tender'),
		('Flaky'), ('Succulent'), ('Bitter'), ('Peppery'), ('Charred'),
		('Piquant'), ('Nutty'), ('Velvety'), ('Chewy'), ('Silky'),
		('Golden'), ('Satisfying'), ('Gooey'), ('Caramelized'), ('Luscious'),
		('Hot'), ('Cool'), ('Bold'), ('Earthy'), ('Subtle'),
		('Vibrant'), ('Doughy'), ('Garlicky'), ('Herby'), ('Tangy'),
		('Mild'), ('Spiced'), ('Infused'), ('Ripe'), ('Fresh'),
		('Citrusy'), ('Tart'), ('Pickled'), ('Fermented'), ('Umami'),
		('Wholesome'), ('Decadent'), ('Savoured'), ('Fizzy'), ('Effervescent'),
		('Melty'), ('Sticky'), ('Toothsome'), ('Crumbly'), ('Roasted'),
		('Boiled'), ('Braised'), ('Fried'), ('Baked'), ('Grilled'),
		('Steamed'), ('Seared'), ('Broiled'), ('Poached'), ('Simmered'),
		('Marinated'), ('Dusted'), ('Drizzled'), ('Glazed'), ('Charred'),
		('Seared'), ('Plated'), ('Whipped'), ('Fluffy'), ('Homemade'),
		('Comforting'), ('Heartwarming'), ('Filling'), ('Juicy'), ('Piping'),
		('Savored'), ('Seasoned'), ('Briny'), ('Doused'), ('Herbed'),
		('Basted'), ('Crusted'), ('Topped'), ('Pressed'), ('Folded'),
		('Layered'), ('Stuffed')
	) AS t(Adjective)
),
Dishes AS
(
    SELECT Dish
	FROM (VALUES
		('Pizza'), ('Taco'), ('Noodles'), ('Sushi'), ('Curry'),
		('Soup'), ('Burger'), ('Salad'), ('Sandwich'), ('Stew'),
		('Pasta'), ('Fried Rice'), ('Dumplings'), ('Wrap'),
		('Pancakes'), ('Stir Fry'), ('Casserole'), ('Quiche'), ('Ramen'),
		('Burrito'), ('Chow Mein'), ('Spring Rolls'), ('Lasagna'), ('Paella'),
		('Risotto'), ('Pho'), ('Gyoza'), ('Chili'), ('Bisque'),
		('Frittata'), ('Toast'), ('Nachos'), ('Bagel'), ('Croissant'),
		('Waffles'), ('Crepes'), ('Omelette'), ('Tart'), ('Brownies'),
		('Cupcakes'), ('Muffins'), ('Samosa'), ('Enchiladas'), ('Tikka Masala'),
		('Shawarma'), ('Kebab'), ('Falafel'), ('Meatballs'), ('Casserole'),
		('Pot Pie'), ('Fajitas'), ('Ravioli'), ('Calzone'), ('Empanadas'),
		('Bruschetta'), ('Ciabatta'), ('Donuts'), ('Macaroni'), ('Clam Chowder'),
		('Gazpacho'), ('Gnocchi'), ('Ratatouille'), ('Poke Bowl'), ('Hotdog'),
		('Fried Chicken'), ('Churros'), ('Stuffed Peppers'), ('Fish Tacos'), ('Kabobs'),
		('Mashed Potatoes'), ('Pad Thai'), ('Bibimbap'), ('Kimchi Stew'), ('Tteokbokki'),
		('Tamales'), ('Meatloaf'), ('Cornbread'), ('Cheesecake'), ('Gelato'),
		('Sorbet'), ('Ice Cream'), ('Pavlova'), ('Tiramisu'), ('Custard'),
		('Flan'), ('Bread Pudding'), ('Trifle'), ('Cobbler'), ('Shortcake'),
		('Soufflé'), ('Eclairs'), ('Cannoli'), ('Baklava'), ('Pecan Pie'),
		('Apple Pie'), ('Focaccia'), ('Stromboli'), ('Beignets'), ('Yorkshire Pudding')
	) AS t(Dish)
)
INSERT INTO Test_ADR_RCSI.dbo.Products_ADR_RCSI (ProductName, QtyInStock)
	SELECT TOP 1000000 a.Adjective + ' ' + c.Cuisine + ' ' + d.Dish, 1
	FROM Cuisines c
	CROSS JOIN Adjectives a
	CROSS JOIN Dishes d
	ORDER BY NEWID();
GO



CREATE DATABASE Test_RCSI;
ALTER DATABASE Test_RCSI SET READ_COMMITTED_SNAPSHOT ON;
GO

CREATE TABLE Test_RCSI.dbo.Products_RCSI
	(Id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	 ProductName NVARCHAR(100) INDEX IX_ProductName,
	 QtyInStock INT INDEX IX_QtyInStock); 
GO
WITH Cuisines AS
(
    SELECT Cuisine
	FROM (VALUES
		('Italian'), ('Mexican'), ('Chinese'), ('Japanese'),
		('Indian'), ('French'), ('Greek'), ('Spanish'), 
		('Korean'), ('Thai'), ('Cajun'), ('Cuban'), ('Moroccan'), 
		('Turkish'), ('Lebanese'), ('Vietnamese'), ('Filipino'), 
		('Ethiopian'), ('Caribbean'), ('Brazilian'), ('Peruvian'), 
		('Argentinian'), ('German'), ('Russian'), ('Polish'), 
		('Hungarian'), ('Swiss'), ('Swedish'), ('Norwegian'), 
		('Danish'), ('Portuguese'), ('Irish'), ('Scottish'), 
		('English'), ('American'), ('Hawaiian'), ('Middle Eastern'), 
		('Afghan'), ('Pakistani'), ('Bangladeshi'), ('Nepalese'), 
		('Sri Lankan'), ('Tibetan'), ('Malay'), ('Indonesian'), 
		('Singaporean'), ('Malaysian'), ('Burmese'), ('Laotian'), 
		('Cambodian'), ('Mongolian'), ('Uzbek'), ('Kazakh'), 
		('Georgian'), ('Azerbaijani'), ('Armenian'), ('Persian'), 
		('Iraqi'), ('Syrian'), ('Jordanian'), ('Saudi Arabian'), 
		('Israeli'), ('Palestinian'), ('Yemeni'), ('Sudanese'), 
		('Somali'), ('Kenyan'), ('Tanzanian'), ('Ugandan'), 
		('Zimbabwean'), ('South African'), ('Nigerian'), ('Ghanaian'), 
		('Senegalese'), ('Ivory Coast'), ('Cameroonian'), 
		('Malagasy'), ('Australian'), ('New Zealand'), ('Canadian'), 
		('Chilean'), ('Colombian'), ('Venezuelan'), ('Ecuadorian'), 
		('Paraguayan'), ('Uruguayan'), ('Bolivian'), ('Guatemalan'), 
		('Honduran'), ('Nicaraguan'), ('Salvadoran'), ('Costa Rican'), 
		('Panamanian'), ('Belizean'), ('Jamaican'), ('Trinidadian'), 
		('Barbadian'), ('Bahamian'), ('Antiguan'), ('Grenadian'),
		('Grandma''s'), ('Grandpa''s')
	) AS t(Cuisine)
),
Adjectives AS
(
    SELECT Adjective
	FROM (VALUES
		('Spicy'), ('Savory'), ('Sweet'), ('Creamy'), ('Crunchy'),
		('Zesty'), ('Tangy'), ('Hearty'), ('Fragrant'), ('Juicy'),
		('Crispy'), ('Delicious'), ('Mouthwatering'), ('Toasted'),
		('Smoky'), ('Rich'), ('Light'), ('Buttery'), ('Tender'),
		('Flaky'), ('Succulent'), ('Bitter'), ('Peppery'), ('Charred'),
		('Piquant'), ('Nutty'), ('Velvety'), ('Chewy'), ('Silky'),
		('Golden'), ('Satisfying'), ('Gooey'), ('Caramelized'), ('Luscious'),
		('Hot'), ('Cool'), ('Bold'), ('Earthy'), ('Subtle'),
		('Vibrant'), ('Doughy'), ('Garlicky'), ('Herby'), ('Tangy'),
		('Mild'), ('Spiced'), ('Infused'), ('Ripe'), ('Fresh'),
		('Citrusy'), ('Tart'), ('Pickled'), ('Fermented'), ('Umami'),
		('Wholesome'), ('Decadent'), ('Savoured'), ('Fizzy'), ('Effervescent'),
		('Melty'), ('Sticky'), ('Toothsome'), ('Crumbly'), ('Roasted'),
		('Boiled'), ('Braised'), ('Fried'), ('Baked'), ('Grilled'),
		('Steamed'), ('Seared'), ('Broiled'), ('Poached'), ('Simmered'),
		('Marinated'), ('Dusted'), ('Drizzled'), ('Glazed'), ('Charred'),
		('Seared'), ('Plated'), ('Whipped'), ('Fluffy'), ('Homemade'),
		('Comforting'), ('Heartwarming'), ('Filling'), ('Juicy'), ('Piping'),
		('Savored'), ('Seasoned'), ('Briny'), ('Doused'), ('Herbed'),
		('Basted'), ('Crusted'), ('Topped'), ('Pressed'), ('Folded'),
		('Layered'), ('Stuffed')
	) AS t(Adjective)
),
Dishes AS
(
    SELECT Dish
	FROM (VALUES
		('Pizza'), ('Taco'), ('Noodles'), ('Sushi'), ('Curry'),
		('Soup'), ('Burger'), ('Salad'), ('Sandwich'), ('Stew'),
		('Pasta'), ('Fried Rice'), ('Dumplings'), ('Wrap'),
		('Pancakes'), ('Stir Fry'), ('Casserole'), ('Quiche'), ('Ramen'),
		('Burrito'), ('Chow Mein'), ('Spring Rolls'), ('Lasagna'), ('Paella'),
		('Risotto'), ('Pho'), ('Gyoza'), ('Chili'), ('Bisque'),
		('Frittata'), ('Toast'), ('Nachos'), ('Bagel'), ('Croissant'),
		('Waffles'), ('Crepes'), ('Omelette'), ('Tart'), ('Brownies'),
		('Cupcakes'), ('Muffins'), ('Samosa'), ('Enchiladas'), ('Tikka Masala'),
		('Shawarma'), ('Kebab'), ('Falafel'), ('Meatballs'), ('Casserole'),
		('Pot Pie'), ('Fajitas'), ('Ravioli'), ('Calzone'), ('Empanadas'),
		('Bruschetta'), ('Ciabatta'), ('Donuts'), ('Macaroni'), ('Clam Chowder'),
		('Gazpacho'), ('Gnocchi'), ('Ratatouille'), ('Poke Bowl'), ('Hotdog'),
		('Fried Chicken'), ('Churros'), ('Stuffed Peppers'), ('Fish Tacos'), ('Kabobs'),
		('Mashed Potatoes'), ('Pad Thai'), ('Bibimbap'), ('Kimchi Stew'), ('Tteokbokki'),
		('Tamales'), ('Meatloaf'), ('Cornbread'), ('Cheesecake'), ('Gelato'),
		('Sorbet'), ('Ice Cream'), ('Pavlova'), ('Tiramisu'), ('Custard'),
		('Flan'), ('Bread Pudding'), ('Trifle'), ('Cobbler'), ('Shortcake'),
		('Soufflé'), ('Eclairs'), ('Cannoli'), ('Baklava'), ('Pecan Pie'),
		('Apple Pie'), ('Focaccia'), ('Stromboli'), ('Beignets'), ('Yorkshire Pudding')
	) AS t(Dish)
)
INSERT INTO Test_RCSI.dbo.Products_RCSI (ProductName, QtyInStock)
	SELECT TOP 1000000 a.Adjective + ' ' + c.Cuisine + ' ' + d.Dish, 1
	FROM Cuisines c
	CROSS JOIN Adjectives a
	CROSS JOIN Dishes d
	ORDER BY NEWID();
GO

-- Veamos los resultados de estas dos nuevas bases de datos
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR_RCSI', @TableName = 'Products_ADR_RCSI';
EXEC sp_BlitzIndex @DatabaseName = 'Test_RCSI', @TableName = 'Products_RCSI';
-- Nos recuerdan mucho al caso de ADR solo. 
-- No importa si es solo ADR, RCSI o ADR + RCSI sino el hecho de usar versinado de filas (Persistent Version Store o PVS).

-- Probamos nuevamente a reconstruir índices y comparamos tamaños
ALTER INDEX ALL ON Test_ADR_RCSI.dbo.Products_ADR_RCSI REBUILD;
ALTER INDEX ALL ON Test_RCSI.dbo.Products_RCSI REBUILD;
GO

EXEC sp_BlitzIndex @DatabaseName = 'Test', @TableName = 'Products';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR', @TableName = 'Products_ADR';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR_RCSI', @TableName = 'Products_ADR_RCSI';
EXEC sp_BlitzIndex @DatabaseName = 'Test_RCSI', @TableName = 'Products_RCSI';
GO
-- Vemos que todas las tablas ocupan lo mismo practicamente

-- Vamos a probar ahora a actualizar un 10% de las filas modificando el orden del índice nonclustered y ver que pasa
UPDATE Test.dbo.Products SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 0;
UPDATE Test_ADR.dbo.Products_ADR SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 0;
UPDATE Test_ADR_RCSI.dbo.Products_ADR_RCSI SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 0;
UPDATE Test_RCSI.dbo.Products_RCSI SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 0;
GO

EXEC sp_BlitzIndex @DatabaseName = 'Test', @TableName = 'Products';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR', @TableName = 'Products_ADR';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR_RCSI', @TableName = 'Products_ADR_RCSI';
EXEC sp_BlitzIndex @DatabaseName = 'Test_RCSI', @TableName = 'Products_RCSI';
GO
-- En la tabla sin PVS mantiene el tamaño del índice clustered, SQL ha sido capaz de organizar las filas en su sitio
-- El índice nonclustered IX_QtyInStock para esta tabla ha crecido un 10%. Ha habido movimiento de filas a páginas nuevas (Page Split)
-- En el resto de bases de datos tanto el índice clustered como el nonclustered IX_QtyInStock han duplicado su tamaño
-- SQL no ha sido capaz de actulizar en el sitio y ha tenido que hacer Page Split 


-- Ahora otra vez y volvemos a revisar
UPDATE Test.dbo.Products SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 1;
UPDATE Test_ADR.dbo.Products_ADR SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 1;
UPDATE Test_ADR_RCSI.dbo.Products_ADR_RCSI SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 1;
UPDATE Test_RCSI.dbo.Products_RCSI SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = 1;
GO

EXEC sp_BlitzIndex @DatabaseName = 'Test', @TableName = 'Products';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR', @TableName = 'Products_ADR';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR_RCSI', @TableName = 'Products_ADR_RCSI';
EXEC sp_BlitzIndex @DatabaseName = 'Test_RCSI', @TableName = 'Products_RCSI';
GO
-- Esto es curioso. El índice IX_QtyInStock de todas las tablas ha crecido un 10%


-- Repitamos el proceso varias (16) veces y veamos los resultados
DECLARE @Remainder INT = 2;
WHILE @Remainder <= 9
	BEGIN
	UPDATE Test.dbo.Products SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = @Remainder;
	UPDATE Test_ADR.dbo.Products_ADR SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = @Remainder;
	UPDATE Test_ADR_RCSI.dbo.Products_ADR_RCSI SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = @Remainder;
	UPDATE Test_RCSI.dbo.Products_RCSI SET QtyInStock = QtyInStock + 1 WHERE Id % 10 = @Remainder;
	SET @Remainder = @Remainder + 1;
	END
GO 2

EXEC sp_BlitzIndex @DatabaseName = 'Test', @TableName = 'Products';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR', @TableName = 'Products_ADR';
EXEC sp_BlitzIndex @DatabaseName = 'Test_ADR_RCSI', @TableName = 'Products_ADR_RCSI';
EXEC sp_BlitzIndex @DatabaseName = 'Test_RCSI', @TableName = 'Products_RCSI';
GO
-- En las bases de datos con ADR o RCSI el tamaño del índice clustered se ha estabilizado en torno al doble de su tamaño
-- El crecimiento del índice nonclustered sigue siendo "normal" en todas


-- APORTE DE ROBERTO CARRANCIO (soydba.es)
-- Comprobar estado de los índices
USE test			; SELECT * FROM  sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Products'), NULL, NULL, 'LIMITED') ips
USE test_ADR		; SELECT * FROM  sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Products_ADR'), NULL, NULL, 'LIMITED') ips
USE test_ADR_RCSI	; SELECT * FROM  sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Products_ADR_RCSI'), NULL, NULL, 'LIMITED') ips
USE test_RCSI		; SELECT * FROM  sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Products_RCSI'), NULL, NULL, 'LIMITED') ips
-- Vemos como el espacio extra que se estaba reduciendo al reconstruir los índices está sin usar, es pura fragmentación
-- El almacén de versiones usa espacio de la base de datos para las versiones de fila
-- Según la documentación oficial esto solo debería pasar en las bases de datos con ADR habilitado
-- Si solo habilitas RCSI no debería pasar según esto:
-- https://learn.microsoft.com/es-es/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-ver16#Row_versioning

