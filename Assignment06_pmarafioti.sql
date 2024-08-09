--*************************************************************************--
-- Title: Assignment06
-- Author: pmarafioti
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,pmarafioti,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_pmarafioti')
	 Begin 
	  Alter Database [Assignment06DB_pmarafioti] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_pmarafioti;
	 End
	Create Database Assignment06DB_pmarafioti;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_pmarafioti;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


-- Categories View
/* Create
View vCategories

Create
View vCategories
With SchemaBinding
As*/

Create
View vCategories
With SchemaBinding
As
	Select
	 [Category ID] = CategoryID 
	,[Category Name] = CategoryName
from dbo.Categories;
go

Select * from vCategories;
go

-- All other views created for this question were created the same way.
-- I've shown the work on only the first view I created above

-- Products View
Create
View vProducts
With SchemaBinding
As
	Select
	 [ProductID] = ProductID
	,[Product Name] = ProductName
	,[Category ID] = CategoryID
	,[Unit Price] = UnitPrice
From dbo.Products;
go

Select * from vProducts;
go

--Employees view

Create
View vEmployees
With Schemabinding
As
	Select
	 [Employee ID] = EmployeeID
	,[Employee First Name] = Employees.EmployeeFirstName
	,[Employee Last Name] = Employees.EmployeeLastName
	,[ManagerID] = Employees.ManagerID
From dbo.Employees
go

Select * from vEmployees;
go

--Inventories View

Create
View vInventories
With SchemaBinding
As
	Select
	 [Inventory ID] = Inventories.InventoryID
	,[Inventory Date] = Inventories.InventoryDate
	,[Employee ID] = Inventories.EmployeeID
	,[Product ID] = Inventories.ProductID
	,[Units in Inventory] = Inventories.Count
From dbo.Inventories;
go

Select * from vInventories;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_pmarafioti
Deny Select on Employees to Public;
Deny Select on Inventories to Public;
Deny Select on Products to Public;
Deny Select on Categories to Public;
go

Use Assignment06DB_pmarafioti
Grant Select on vEmployees to Public;
Grant Select on vInventories to Public;
Grant Select on vProducts to Public;
Grant Select on vCategories to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/* Create View vProductswithCategoriesandPrice
As
	Select Top 1000000 Categories.CategoryName, Products.ProductName, Products.UnitPrice

Create View vProductswithCategoriesandPrice
As
	Select Top 1000000 Categories.CategoryName, Products.ProductName, Products.UnitPrice
	From Assignment06DB_pmarafioti.dbo.Categories Join Assignment06DB_pmarafioti.dbo.Products

Create View vProductswithCategoriesandPrice
As
	Select Top 1000000 Categories.CategoryName, Products.ProductName, Products.UnitPrice
	From Assignment06DB_pmarafioti.dbo.Categories Join Assignment06DB_pmarafioti.dbo.Products
	on Categories.CategoryID = Products.CategoryID*/

Create View vProductswithCategoriesandPrice
As
	Select Top 1000000 
	   CategoryName
	 , ProductName
	 , UnitPrice
	From vCategories 
		Join vProducts
	on vCategories.CategoryID = vProducts.CategoryID
	Order by CategoryName, ProductName;
go

Select * from vProductswithCategoriesandPrice;
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/* Create View vProductsbyDatewithCounts
As
	Select top 1000000 Products.ProductName, Inventories.Count, Inventories.InventoryDate

Create View vProductsbyDatewithCounts
As
	Select top 1000000 Products.ProductName, Inventories.Count, Inventories.InventoryDate
	From Assignment06DB_pmarafioti.dbo.Products join Assignment06DB_pmarafioti.dbo.Inventories

Create View vProductsbyDatewithCounts
As
	Select top 1000000 Products.ProductName, Inventories.Count, Inventories.InventoryDate
	From Assignment06DB_pmarafioti.dbo.Products join Assignment06DB_pmarafioti.dbo.Inventories
	On Products.ProductID = Inventories.ProductID */

Create View vProductsbyDatewithCounts
As
	Select top 1000000 
	     ProductName
	   , Count
	   , InventoryDate
	From vProducts
		join vInventories
	On vProducts.ProductID = vInventories.ProductID
	Order by ProductName, InventoryDate, Count
go

Select * from vProductsbyDatewithCounts;
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/* Create View vEmployeeInventories
As
Select Top 100000 InventoryDate as [InventoryDate]

Create View vEmployeeInventories
As
Select Top 100000 InventoryDate as [InventoryDate]
	 , Employees.EmployeeLastName as [Employee Last Name]
	 , Employees.EmployeeFirstName as [Employee First Name]

Create View vEmployeeInventories
As
Select Top 100000 InventoryDate as [InventoryDate]
	 , Employees.EmployeeLastName as [Employee Last Name]
	 , Employees.EmployeeFirstName as [Employee First Name]
  From Inventories join Employees 
  On Inventories.EmployeeID = Employees.EmployeeID

Create View vEmployeeInventories
As
Select Top 100000 InventoryDate as [InventoryDate]
	 , Employees.EmployeeLastName as [Employee Last Name]
	 , Employees.EmployeeFirstName as [Employee First Name]
  From Inventories join Employees 
  On Inventories.EmployeeID = Employees.EmployeeID
  Group by InventoryDate, EmployeeLastName, EmployeeFirstName
*/
Create View vEmployeeInventories
As
Select Top 100000 InventoryDate as [InventoryDate]
	 , vEmployees.EmployeeLastName as [Employee Last Name]
	 , vEmployees.EmployeeFirstName as [Employee First Name]
  From vInventories join vEmployees 
  On vInventories.EmployeeID = vEmployees.EmployeeID
  Group by InventoryDate, EmployeeLastName, EmployeeFirstName
  Order by InventoryDate
go


Select * from vEmployeeInventories
go



-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/* Create View vProductsbyCategorywithDateandCount
As
	Select top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count

Create View vProductsbyCategorywithDateandCount
As
	Select top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count
	From Assignment06DB_pmarafioti.dbo.Products 
		join Assignment06DB_pmarafioti.dbo.Inventories
			On Products.ProductID = Inventories.ProductID

Create View vProductsbyCategorywithDateandCount
As
	Select top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count
	From Assignment06DB_pmarafioti.dbo.Products 
		join Assignment06DB_pmarafioti.dbo.Inventories
			On Products.ProductID = Inventories.ProductID
		Join Assignment06DB_pmarafioti.dbo.Categories
			on Categories.CategoryID = Products.CategoryID
			*/
Create View vProductsbyCategorywithDateandCount
As
	Select top 100000 
	  CategoryName
	, ProductName
	, InventoryDate
	, Count
	From vProducts 
		join vInventories
			On vProducts.ProductID = vInventories.ProductID
		Join vCategories
			on vCategories.CategoryID = vProducts.CategoryID
	Order by CategoryName, ProductName, InventoryDate, Count;
go

Select * from vProductsbyCategorywithDateandCount;
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*Create View vProblem7
As
	Select top 100000 Categories.CategoryName
		, Products.ProductName
		, Inventories.InventoryDate
		, Inventories.Count
		, Employees.EmployeeLastName
		, Employees.EmployeeFirstName
	From Assignment06DB_pmarafioti.dbo.Categories
		Join Assignment06DB_pmarafioti.dbo.Products
			on Categories.CategoryID = Products.CategoryID
		Join Assignment06DB_pmarafioti.dbo.Inventories
			on Products.ProductID = Inventories.ProductID
		Join Assignment06DB_pmarafioti.dbo.Employees
			on Employees.EmployeeID = Inventories.EmployeeID
	Order by Inventories.InventoryDate, Categories.CategoryName, Products.ProductName, Employees.EmployeeLastName
go

Create View vProblem7
As
	Select top 100000 Categories.CategoryName
		, Products.ProductName
		, Inventories.InventoryDate
		, Inventories.Count
		, Employees.EmployeeLastName
		, Employees.EmployeeFirstName

Create View vProblem7
As
	Select top 100000 Categories.CategoryName
		, Products.ProductName
		, Inventories.InventoryDate
		, Inventories.Count
		, Employees.EmployeeLastName
		, Employees.EmployeeFirstName
	From Assignment06DB_pmarafioti.dbo.Categories
		Join Assignment06DB_pmarafioti.dbo.Products
			on Categories.CategoryID = Products.CategoryID
		Join Assignment06DB_pmarafioti.dbo.Inventories
			on Products.ProductID = Inventories.ProductID
		Join Assignment06DB_pmarafioti.dbo.Employees
			on Employees.EmployeeID = Inventories.EmployeeID
*/
Create View vProblem7
As
	Select top 100000 
		  CategoryName
		, ProductName
		, InventoryDate
		, Count
		, EmployeeLastName
		, EmployeeFirstName
	From vCategories
		Join vProducts
			on vCategories.CategoryID = vProducts.CategoryID
		Join vInventories
			on vProducts.ProductID = vInventories.ProductID
		Join vEmployees
			on vEmployees.EmployeeID = vInventories.EmployeeID
	Order by InventoryDate, CategoryName, ProductName, EmployeeLastName
go

Select * from vProblem7;
go
	
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*
Create View vProblem8
As
	Select top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count, Employees.EmployeeLastName, Employees.EmployeeFirstName
	From Assignment06DB_pmarafioti.dbo.Categories
		join Assignment06DB_pmarafioti.dbo.Products
			on Categories.CategoryID = Products.CategoryID

Create View vProblem8
As
	Select top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count, Employees.EmployeeLastName, Employees.EmployeeFirstName
	From Assignment06DB_pmarafioti.dbo.Categories
		join Assignment06DB_pmarafioti.dbo.Products
			on Categories.CategoryID = Products.CategoryID
		Join Assignment06DB_pmarafioti.dbo.Inventories
			on Products.ProductID = Inventories.ProductID

Create View vProblem8
As
	Select top 100000 Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count, Employees.EmployeeLastName, Employees.EmployeeFirstName
	From Assignment06DB_pmarafioti.dbo.Categories
		join Assignment06DB_pmarafioti.dbo.Products
			on Categories.CategoryID = Products.CategoryID
		Join Assignment06DB_pmarafioti.dbo.Inventories
			on Products.ProductID = Inventories.ProductID
		Join Assignment06DB_pmarafioti.dbo.Employees
			on Inventories.EmployeeID = Employees.EmployeeID
*/
Create View vProblem8
As
	Select top 100000
	  CategoryName
	, ProductName
	, InventoryDate
	, Count
	, EmployeeLastName
	, EmployeeFirstName
	From vCategories
		join vProducts
			on vCategories.CategoryID = vProducts.CategoryID
		Join vInventories
			on vProducts.ProductID = vInventories.ProductID
		Join vEmployees
			on vInventories.EmployeeID = vEmployees.EmployeeID
	Where vProducts.ProductName like ('Cha[i, n]%')
go

Select * from vProblem8;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
Create View vProblem9
As
	Select Mgr.EmployeeLastName as [Manager Last Name]
		, Emp.EmployeeLastName as [Employee Last Name]

Create View vProblem9
As
	Select Mgr.EmployeeLastName as [Manager Last Name]
		, Emp.EmployeeLastName as [Employee Last Name]
	From Employees as Emp
		Left Join Employees as Mgr
*/
Create View vEmployeesByManager
As
	Select Top 100000
		  M.[Employee Last Name] + ' ' + M.[Employee First Name] as Manager
		, E.[Employee Last Name] + ' ' + E.[Employee First Name] as Employee
	From vEmployees as E
		Join vEmployees as M
	On E.[Employee ID] = M.ManagerID
	Order by 1,2;
go

Select * from vEmployeesByManager;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create
View vInventoriesByProductsByCategoriesByEmployees
As
	Select Top 1000000 
					 C.[Category ID]
				   , C.[Category Name]
				   , P.[ProductID]
				   , P.[Product Name]
				   , P.[Unit Price]
				   , V.[Inventory ID]
				   , V.[Inventory Date]
				   , V.[Count]
				   , E.[Employee ID]
				   , E.[Employee First Name] + ' ' + E.[Employee Last Name] as Employee
				   , E.ManagerID
				   , M.[Employee Last Name] + ' ' + M.[Employee First Name] as Manager
		From vCategories as C
		join vProducts as P
			on C.[Category ID] = P.[Category ID]
		Join vInventories as V
			on P.[ProductID] = V.[Product ID]
		Join vEmployees as E
			on E.[Employee ID] = V.[Employee ID]
		Join vEmployees as M
			on E.ManagerID = M.[Employee ID]
	Order by 1, 3, 6, 9;
Go

Select * from vInventoriesByProductsByCategoriesByEmployees;
go





-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/