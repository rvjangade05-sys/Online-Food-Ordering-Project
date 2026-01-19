create database OnlineFoodOrdering;
use OnlineFoodOrdering;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    RegistrationDate DATE
);

INSERT INTO Customers (FirstName, LastName, Email, Phone, RegistrationDate)
VALUES
('Amit', 'Sharma', 'amit@gmail.com', '9876543210', '2023-01-10'),
('Neha', 'Verma', 'neha@gmail.com', '9876543211', '2023-02-05'),
('Ravi', 'Kumar', 'ravi@gmail.com', '9876543212', '2023-03-12');

select*from Customers;

CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY AUTO_INCREMENT,
    RestaurantName VARCHAR(100),
    Address VARCHAR(200),
    CuisineType VARCHAR(50)
);

INSERT INTO Restaurants (RestaurantName, Address, CuisineType)
VALUES
('Spice Hub', 'Delhi', 'Indian'),
('Pasta Palace', 'Mumbai', 'Italian'),
('Burger Town', 'Bangalore', 'Fast Food');

select*from Restaurants;


CREATE TABLE MenuItems (
    MenuItemID INT PRIMARY KEY AUTO_INCREMENT,
    RestaurantID INT,
    ItemName VARCHAR(100),
    Price DECIMAL(10,2),
    Description TEXT,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);

INSERT INTO MenuItems (RestaurantID, ItemName, Price, Description)
VALUES
(1, 'Paneer Butter Masala', 250, 'Creamy curry'),
(1, 'Naan', 50, 'Tandoor baked bread'),
(2, 'Veg Pasta', 300, 'Italian special'),
(3, 'Cheese Burger', 180, 'Classic burger with cheese'),
(3, 'Fries', 90, 'Crispy potato fries');

select*from MenuItems;

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    RestaurantID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);

INSERT INTO Orders (CustomerID, RestaurantID, OrderDate, TotalAmount)
VALUES
(1, 1, '2023-10-01', 300),
(2, 2, '2023-10-02', 300),
(1, 3, '2023-10-05', 270),
(3, 1, '2023-09-28', 250);

select*from Orders;

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    MenuItemID INT,
    Quantity INT,
    ItemPrice DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

INSERT INTO OrderDetails (OrderID, MenuItemID, Quantity, ItemPrice)
VALUES
(1, 1, 1, 250),
(1, 2, 1, 50),
(2, 3, 1, 300),
(3, 4, 1, 180),
(3, 5, 1, 90),
(4, 1, 1, 250);

select *from OrderDetails;

CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    RestaurantID INT,
    CustomerID INT,
    ReviewDate DATE,
    Rating DECIMAL(2,1),
    Comments TEXT,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Reviews (RestaurantID, CustomerID, ReviewDate, Rating, Comments)
VALUES
(1, 1, '2023-10-02', 4.5, 'Delicious and fresh food!'),
(2, 2, '2023-10-03', 4.0, 'Good pasta, could be hotter'),
(3, 1, '2023-10-06', 3.0, 'Average burger'),
(1, 3, '2023-09-29', 5.0, 'Excellent taste!');

select*from Reviews;


SELECT C.*
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE O.OrderDate < DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
   OR O.OrderID IS NULL;




SELECT C.CustomerID, C.FirstName, C.LastName, AVG(O.TotalAmount) AS AvgOrderValue
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID;

SELECT R.RestaurantName, AVG(Rev.Rating) AS AvgRating
FROM Restaurants R
JOIN Reviews Rev ON R.RestaurantID = Rev.RestaurantID
GROUP BY R.RestaurantName
ORDER BY AvgRating DESC
LIMIT 5;

SELECT R.RestaurantName, COUNT(O.OrderID) AS TotalOrders
FROM Restaurants R
LEFT JOIN Orders O ON R.RestaurantID = O.RestaurantID
GROUP BY R.RestaurantName
ORDER BY TotalOrders ASC;

SELECT R.CuisineType, COUNT(O.OrderID) AS TotalOrders
FROM Restaurants R
JOIN Orders O ON R.RestaurantID = O.RestaurantID
GROUP BY R.CuisineType
ORDER BY TotalOrders DESC;

SELECT SUM(TotalAmount) AS TotalRevenue
FROM Orders
WHERE QUARTER(OrderDate) = QUARTER(CURDATE() - INTERVAL 1 QUARTER)
  AND YEAR(OrderDate) = YEAR(CURDATE());
  
  SELECT M.ItemName, SUM(OD.Quantity) AS TotalOrdered
FROM MenuItems M
JOIN OrderDetails OD ON M.MenuItemID = OD.MenuItemID
GROUP BY M.ItemName
ORDER BY TotalOrdered DESC
LIMIT 3;

SELECT R.RestaurantName, SUM(O.TotalAmount) AS Revenue
FROM Restaurants R
JOIN Orders O ON R.RestaurantID = O.RestaurantID
GROUP BY R.RestaurantName
ORDER BY Revenue DESC;
SELECT AVG(ItemCount) AS AvgItemsPerOrder
FROM (
  SELECT O.OrderID, COUNT(OD.OrderDetailID) AS ItemCount
  FROM Orders O
  JOIN OrderDetails OD ON O.OrderID = OD.OrderID
  GROUP BY O.OrderID
) AS OrderItemCounts;


SELECT * FROM Orders WHERE TotalAmount < 200;

SELECT R.RestaurantName, COUNT(Rev.ReviewID) AS ReviewCount, AVG(Rev.Rating) AS AvgRating
FROM Restaurants R
JOIN Reviews Rev ON R.RestaurantID = Rev.RestaurantID
GROUP BY R.RestaurantName
HAVING ReviewCount > 5 AND AvgRating < 3.0;

SELECT COUNT(*) AS PositiveReviews
FROM Reviews
WHERE Rating >= 4.0;

SELECT C.FirstName, C.LastName, COUNT(Rev.ReviewID) AS LowRatings
FROM Reviews Rev
JOIN Customers C ON Rev.CustomerID = C.CustomerID
WHERE Rev.Rating < 3
GROUP BY C.CustomerID
ORDER BY LowRatings DESC;

SELECT Comments
FROM Reviews
WHERE Comments LIKE '%cold%' OR Comments LIKE '%late%' OR Comments LIKE '%bad%';

SELECT CustomerID, MAX(OrderDate) AS LastOrder
FROM Orders
GROUP BY CustomerID
HAVING DATEDIFF(CURDATE(), MAX(OrderDate)) > 90;

SELECT CASE 
    WHEN DAYOFWEEK(OrderDate) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS DayType,
  COUNT(OrderID) AS OrderCount
FROM Orders
GROUP BY DayType;
